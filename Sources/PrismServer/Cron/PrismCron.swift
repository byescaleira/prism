import Foundation

/// Errors during cron expression parsing.
public enum PrismCronError: Error, Sendable {
    /// The cron expression could not be parsed.
    case invalidExpression(String)
    /// A specific cron field value is invalid.
    case invalidField(String, String)
}

/// A parsed cron field supporting *, */N, N, N-M, and N,M,O.
public struct PrismCronField: Sendable, Equatable {
    /// The set of integer values matched by this field.
    public let allowedValues: Set<Int>
    /// The minimum valid value for this field.
    public let min: Int
    /// The maximum valid value for this field.
    public let max: Int

    /// Parses a cron field expression within the given min/max range.
    public init(expression: String, min: Int, max: Int) throws {
        self.min = min
        self.max = max

        var values = Set<Int>()
        let parts = expression.split(separator: ",")

        for part in parts {
            let token = String(part).trimmingCharacters(in: .whitespaces)

            if token == "*" {
                values.formUnion(min...max)
            } else if token.hasPrefix("*/") {
                guard let step = Int(token.dropFirst(2)), step > 0 else {
                    throw PrismCronError.invalidField(expression, "invalid step")
                }
                for v in stride(from: min, through: max, by: step) {
                    values.insert(v)
                }
            } else if token.contains("-") {
                let rangeParts = token.split(separator: "-")
                guard rangeParts.count == 2,
                      let low = Int(rangeParts[0]),
                      let high = Int(rangeParts[1]),
                      low >= min, high <= max, low <= high else {
                    throw PrismCronError.invalidField(expression, "invalid range")
                }
                values.formUnion(low...high)
            } else {
                guard let val = Int(token), val >= min, val <= max else {
                    throw PrismCronError.invalidField(expression, "value out of range")
                }
                values.insert(val)
            }
        }

        self.allowedValues = values
    }

    /// Returns whether the given integer is in this field's allowed values.
    public func matches(_ value: Int) -> Bool {
        allowedValues.contains(value)
    }
}

/// A parsed 5-field cron expression (minute hour dayOfMonth month dayOfWeek).
public struct PrismCronExpression: Sendable {
    /// The minute field (0-59).
    public let minute: PrismCronField
    /// The hour field (0-23).
    public let hour: PrismCronField
    /// The day-of-month field (1-31).
    public let dayOfMonth: PrismCronField
    /// The month field (1-12).
    public let month: PrismCronField
    /// The day-of-week field (0-6, Sunday=0).
    public let dayOfWeek: PrismCronField
    /// The original cron expression string.
    public let raw: String

    /// Parses a 5-field cron expression string.
    public init(_ expression: String) throws {
        self.raw = expression
        let fields = expression.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard fields.count == 5 else {
            throw PrismCronError.invalidExpression("Expected 5 fields, got \(fields.count)")
        }

        self.minute = try PrismCronField(expression: fields[0], min: 0, max: 59)
        self.hour = try PrismCronField(expression: fields[1], min: 0, max: 23)
        self.dayOfMonth = try PrismCronField(expression: fields[2], min: 1, max: 31)
        self.month = try PrismCronField(expression: fields[3], min: 1, max: 12)
        self.dayOfWeek = try PrismCronField(expression: fields[4], min: 0, max: 6)
    }

    /// Checks if a date matches this cron expression.
    public func matches(_ date: Date) -> Bool {
        let cal = Calendar.current
        let comps = cal.dateComponents([.minute, .hour, .day, .month, .weekday], from: date)
        guard let min = comps.minute, let hr = comps.hour,
              let day = comps.day, let mon = comps.month,
              let wd = comps.weekday else { return false }
        let cronWeekday = (wd + 5) % 7 // Convert Sunday=1 to Sunday=0
        return minute.matches(min)
            && hour.matches(hr)
            && dayOfMonth.matches(day)
            && month.matches(mon)
            && dayOfWeek.matches(cronWeekday)
    }

    /// Finds the next date after the given date that matches this expression.
    public func nextFire(after date: Date) -> Date? {
        let cal = Calendar.current
        var candidate = cal.date(byAdding: .minute, value: 1, to: date)!
        candidate = cal.date(bySetting: .second, value: 0, of: candidate)!

        for _ in 0..<525960 {
            if matches(candidate) { return candidate }
            candidate = cal.date(byAdding: .minute, value: 1, to: candidate)!
        }
        return nil
    }
}

/// A named cron job with an expression and handler.
public struct PrismCronJob: Sendable {
    /// The human-readable name of the cron job.
    public let name: String
    /// The cron expression controlling when this job fires.
    public let expression: PrismCronExpression
    /// The async handler to execute when the job fires.
    public let handler: @Sendable () async throws -> Void

    /// Creates a cron job with the given name, schedule expression, and handler.
    public init(name: String, expression: PrismCronExpression, handler: @escaping @Sendable () async throws -> Void) {
        self.name = name
        self.expression = expression
        self.handler = handler
    }
}

/// Actor-based cron scheduler that checks jobs every 60 seconds.
public actor PrismCronScheduler {
    private var cronJobs: [String: PrismCronJob] = [:]
    private var task: Task<Void, Never>?
    private var running = false

    /// Creates a cron scheduler.
    public init() {}

    /// Schedules a job with a cron expression string.
    public func schedule(_ name: String, expression: String, handler: @escaping @Sendable () async throws -> Void) throws {
        let expr = try PrismCronExpression(expression)
        cronJobs[name] = PrismCronJob(name: name, expression: expr, handler: handler)
    }

    /// Removes a scheduled job.
    public func unschedule(_ name: String) {
        cronJobs.removeValue(forKey: name)
    }

    /// Starts the scheduler loop.
    public func start() {
        guard !running else { return }
        running = true
        task = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                guard let self else { break }
                await self.tick()
            }
        }
    }

    /// Stops the scheduler.
    public func stop() {
        running = false
        task?.cancel()
        task = nil
    }

    /// List of scheduled job names.
    public var jobs: [String] { Array(cronJobs.keys) }

    /// Whether the scheduler is running.
    public var isRunning: Bool { running }

    private func tick() async {
        let now = Date()
        for (_, job) in cronJobs {
            if job.expression.matches(now) {
                try? await job.handler()
            }
        }
    }
}
