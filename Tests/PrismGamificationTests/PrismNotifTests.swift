#if canImport(SwiftData)
    import Foundation
    import Testing

    @testable import PrismGamification

    // MARK: - Trigger Tests

    @Suite("TrigTests")
    struct TrigTests {

        @Test("time interval equatable")
        func timeEq() {
            let a = PrismNotificationTrigger.timeInterval(seconds: 60, repeats: true)
            let b = PrismNotificationTrigger.timeInterval(seconds: 60, repeats: true)
            #expect(a == b)
        }

        @Test("time interval not equal")
        func timeNeq() {
            let a = PrismNotificationTrigger.timeInterval(seconds: 60, repeats: true)
            let b = PrismNotificationTrigger.timeInterval(seconds: 120, repeats: true)
            #expect(a != b)
        }

        @Test("daily equatable")
        func dailyEq() {
            let a = PrismNotificationTrigger.daily(hour: 9, minute: 30)
            let b = PrismNotificationTrigger.daily(hour: 9, minute: 30)
            #expect(a == b)
        }

        @Test("daily not equal")
        func dailyNeq() {
            let a = PrismNotificationTrigger.daily(hour: 9, minute: 0)
            let b = PrismNotificationTrigger.daily(hour: 20, minute: 0)
            #expect(a != b)
        }

        @Test("different types not equal")
        func crossNeq() {
            let a = PrismNotificationTrigger.timeInterval(seconds: 3600, repeats: false)
            let b = PrismNotificationTrigger.daily(hour: 1, minute: 0)
            #expect(a != b)
        }

        @Test("repeats matters")
        func repeatsDiff() {
            let a = PrismNotificationTrigger.timeInterval(seconds: 60, repeats: true)
            let b = PrismNotificationTrigger.timeInterval(seconds: 60, repeats: false)
            #expect(a != b)
        }
    }

    // MARK: - Request Tests

    @Suite("ReqTests")
    struct ReqTests {

        @Test("init properties")
        func initProps() {
            let req = PrismNotificationRequest(
                identifier: "test.id",
                title: "Title",
                body: "Body",
                trigger: .daily(hour: 8, minute: 0)
            )
            #expect(req.identifier == "test.id")
            #expect(req.title == "Title")
            #expect(req.body == "Body")
            if case .daily(let h, let m) = req.trigger {
                #expect(h == 8)
                #expect(m == 0)
            } else { #expect(Bool(false)) }
        }
    }

    // MARK: - Streak Reminder Tests

    @Suite("SRmTests")
    struct SRmTests {

        @Test("init properties")
        func initProps() {
            let r = PrismStreakReminder(
                streakID: "daily",
                reminderHour: 20,
                reminderMinute: 30,
                title: "Keep going!",
                body: "Don't break your streak!"
            )
            #expect(r.streakID == "daily")
            #expect(r.reminderHour == 20)
            #expect(r.reminderMinute == 30)
            #expect(r.title == "Keep going!")
            #expect(r.body == "Don't break your streak!")
        }

        @Test("notification identifier")
        func notifID() {
            let r = PrismStreakReminder(
                streakID: "daily", reminderHour: 20, reminderMinute: 0,
                title: "T", body: "B"
            )
            #expect(r.notificationIdentifier == "prism.streak.daily")
        }

        @Test("notification request")
        func notifReq() {
            let r = PrismStreakReminder(
                streakID: "weekly", reminderHour: 9, reminderMinute: 15,
                title: "Title", body: "Body"
            )
            let req = r.notificationRequest
            #expect(req.identifier == "prism.streak.weekly")
            #expect(req.title == "Title")
            #expect(req.body == "Body")
            if case .daily(let h, let m) = req.trigger {
                #expect(h == 9)
                #expect(m == 15)
            } else { #expect(Bool(false)) }
        }
    }

    // MARK: - Challenge Reminder Tests

    @Suite("CRmTests")
    struct CRmTests {

        @Test("init properties")
        func initProps() {
            let r = PrismChallengeReminder(
                challengeID: "workout",
                intervalSeconds: 3600,
                title: "Challenge!",
                body: "Complete your workout."
            )
            #expect(r.challengeID == "workout")
            #expect(r.intervalSeconds == 3600)
            #expect(r.title == "Challenge!")
            #expect(r.body == "Complete your workout.")
        }

        @Test("notification identifier")
        func notifID() {
            let r = PrismChallengeReminder(
                challengeID: "login", intervalSeconds: 60,
                title: "T", body: "B"
            )
            #expect(r.notificationIdentifier == "prism.challenge.login")
        }

        @Test("notification request")
        func notifReq() {
            let r = PrismChallengeReminder(
                challengeID: "steps", intervalSeconds: 7200,
                title: "Walk!", body: "Get moving."
            )
            let req = r.notificationRequest
            #expect(req.identifier == "prism.challenge.steps")
            #expect(req.title == "Walk!")
            #expect(req.body == "Get moving.")
            if case .timeInterval(let s, let rep) = req.trigger {
                #expect(s == 7200)
                #expect(rep == true)
            } else { #expect(Bool(false)) }
        }
    }

    // MARK: - Protocol Tests

    @Suite("SchdTests")
    struct SchdTests {

        final class MockScheduler: PrismNotificationScheduling, @unchecked Sendable {
            var scheduled: [PrismNotificationRequest] = []
            var cancelled: [String] = []
            var allCancelled = false

            func schedule(_ request: PrismNotificationRequest) async throws {
                scheduled.append(request)
            }

            func cancel(identifier: String) async {
                cancelled.append(identifier)
            }

            func cancelAll() async {
                allCancelled = true
            }
        }

        @Test("mock schedule")
        func mockSchedule() async throws {
            let sched = MockScheduler()
            let req = PrismNotificationRequest(
                identifier: "test", title: "T", body: "B",
                trigger: .timeInterval(seconds: 60, repeats: false)
            )
            try await sched.schedule(req)
            #expect(sched.scheduled.count == 1)
            #expect(sched.scheduled[0].identifier == "test")
        }

        @Test("mock cancel")
        func mockCancel() async {
            let sched = MockScheduler()
            await sched.cancel(identifier: "test.id")
            #expect(sched.cancelled == ["test.id"])
        }

        @Test("mock cancelAll")
        func mockCancelAll() async {
            let sched = MockScheduler()
            await sched.cancelAll()
            #expect(sched.allCancelled)
        }

        @Test("schedule streak reminder via mock")
        func streakVia() async throws {
            let sched = MockScheduler()
            let reminder = PrismStreakReminder(
                streakID: "daily", reminderHour: 20, reminderMinute: 0,
                title: "Streak!", body: "Keep it up"
            )
            try await sched.schedule(reminder.notificationRequest)
            #expect(sched.scheduled.count == 1)
            #expect(sched.scheduled[0].identifier == "prism.streak.daily")
        }

        @Test("schedule challenge reminder via mock")
        func challengeVia() async throws {
            let sched = MockScheduler()
            let reminder = PrismChallengeReminder(
                challengeID: "workout", intervalSeconds: 3600,
                title: "Workout", body: "Do it"
            )
            try await sched.schedule(reminder.notificationRequest)
            #expect(sched.scheduled.count == 1)
            #expect(sched.scheduled[0].identifier == "prism.challenge.workout")
        }
    }
#endif
