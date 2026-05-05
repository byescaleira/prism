import Foundation
import Testing

@testable import PrismServer

@Suite("PrismCronExpression Tests")
struct PrismCronExpressionTests {

    private func makeDate(
        minute: Int = 0, hour: Int = 0, day: Int = 1, month: Int = 1, year: Int = 2026, weekday: Int? = nil
    ) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps)!
    }

    @Test("Wildcard matches any date")
    func wildcardMatchesAll() throws {
        let expr = try PrismCronExpression("* * * * *")
        #expect(expr.matches(Date()))
        #expect(expr.matches(makeDate(minute: 30, hour: 14)))
    }

    @Test("Exact minute match")
    func exactMinute() throws {
        let expr = try PrismCronExpression("0 * * * *")
        #expect(expr.matches(makeDate(minute: 0)))
        #expect(!expr.matches(makeDate(minute: 5)))
    }

    @Test("Step expression */5")
    func stepExpression() throws {
        let expr = try PrismCronExpression("*/5 * * * *")
        #expect(expr.matches(makeDate(minute: 0)))
        #expect(expr.matches(makeDate(minute: 5)))
        #expect(expr.matches(makeDate(minute: 10)))
        #expect(!expr.matches(makeDate(minute: 3)))
    }

    @Test("List expression 1,15,30")
    func listExpression() throws {
        let expr = try PrismCronExpression("1,15,30 * * * *")
        #expect(expr.matches(makeDate(minute: 1)))
        #expect(expr.matches(makeDate(minute: 15)))
        #expect(expr.matches(makeDate(minute: 30)))
        #expect(!expr.matches(makeDate(minute: 2)))
    }

    @Test("Range expression 10-20")
    func rangeExpression() throws {
        let expr = try PrismCronExpression("10-20 * * * *")
        #expect(expr.matches(makeDate(minute: 10)))
        #expect(expr.matches(makeDate(minute: 15)))
        #expect(expr.matches(makeDate(minute: 20)))
        #expect(!expr.matches(makeDate(minute: 9)))
        #expect(!expr.matches(makeDate(minute: 21)))
    }

    @Test("Hour field match")
    func hourField() throws {
        let expr = try PrismCronExpression("0 14 * * *")
        #expect(expr.matches(makeDate(minute: 0, hour: 14)))
        #expect(!expr.matches(makeDate(minute: 0, hour: 13)))
    }

    @Test("Month field match")
    func monthField() throws {
        let expr = try PrismCronExpression("0 0 1 6 *")
        #expect(expr.matches(makeDate(minute: 0, hour: 0, day: 1, month: 6)))
        #expect(!expr.matches(makeDate(minute: 0, hour: 0, day: 1, month: 7)))
    }

    @Test("Invalid expression throws — wrong field count")
    func invalidFieldCount() {
        #expect(throws: PrismCronError.self) {
            _ = try PrismCronExpression("* * *")
        }
    }

    @Test("Invalid expression throws — bad value")
    func invalidValue() {
        #expect(throws: PrismCronError.self) {
            _ = try PrismCronExpression("60 * * * *")
        }
    }

    @Test("nextFire returns future date")
    func nextFire() throws {
        let expr = try PrismCronExpression("0 * * * *")
        let base = makeDate(minute: 30, hour: 10)
        let next = expr.nextFire(after: base)
        #expect(next != nil)
        let comps = Calendar.current.dateComponents([.minute], from: next!)
        #expect(comps.minute == 0)
    }
}

@Suite("PrismCronField Tests")
struct PrismCronFieldTests {

    @Test("Wildcard field matches all values")
    func wildcardField() throws {
        let field = try PrismCronField(expression: "*", min: 0, max: 59)
        #expect(field.matches(0))
        #expect(field.matches(59))
    }

    @Test("Step field")
    func stepField() throws {
        let field = try PrismCronField(expression: "*/10", min: 0, max: 59)
        #expect(field.matches(0))
        #expect(field.matches(10))
        #expect(!field.matches(5))
    }

    @Test("Exact value field")
    func exactField() throws {
        let field = try PrismCronField(expression: "42", min: 0, max: 59)
        #expect(field.matches(42))
        #expect(!field.matches(41))
    }
}

@Suite("PrismCronScheduler Tests")
struct PrismCronSchedulerTests {

    @Test("Schedule adds job")
    func scheduleJob() async throws {
        let scheduler = PrismCronScheduler()
        try await scheduler.schedule("test", expression: "* * * * *") {}
        #expect(await scheduler.jobs.contains("test"))
    }

    @Test("Unschedule removes job")
    func unscheduleJob() async throws {
        let scheduler = PrismCronScheduler()
        try await scheduler.schedule("test", expression: "* * * * *") {}
        await scheduler.unschedule("test")
        #expect(await scheduler.jobs.isEmpty)
    }

    @Test("Jobs lists all names")
    func jobsList() async throws {
        let scheduler = PrismCronScheduler()
        try await scheduler.schedule("a", expression: "* * * * *") {}
        try await scheduler.schedule("b", expression: "0 * * * *") {}
        let jobs = await scheduler.jobs
        #expect(jobs.count == 2)
    }

    @Test("isRunning tracks state")
    func isRunning() async {
        let scheduler = PrismCronScheduler()
        #expect(await scheduler.isRunning == false)
        await scheduler.start()
        #expect(await scheduler.isRunning == true)
        await scheduler.stop()
        #expect(await scheduler.isRunning == false)
    }
}
