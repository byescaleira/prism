import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - StoreKit Tests

@Suite("PrismStoreKit")
struct PrismStoreKitTests {

    @Test("PrismProductType has 4 cases")
    func productTypeCaseCount() {
        #expect(PrismProductType.allCases.count == 4)
    }

    @Test("PrismProductType includes all expected cases")
    func productTypeCases() {
        let cases = PrismProductType.allCases
        #expect(cases.contains(.consumable))
        #expect(cases.contains(.nonConsumable))
        #expect(cases.contains(.autoRenewable))
        #expect(cases.contains(.nonRenewable))
    }

    @Test("PrismSubscriptionStatus has 5 cases")
    func subscriptionStatusCaseCount() {
        #expect(PrismSubscriptionStatus.allCases.count == 5)
    }

    @Test("PrismSubscriptionStatus includes all expected cases")
    func subscriptionStatusCases() {
        let cases = PrismSubscriptionStatus.allCases
        #expect(cases.contains(.subscribed))
        #expect(cases.contains(.expired))
        #expect(cases.contains(.revoked))
        #expect(cases.contains(.inBillingRetry))
        #expect(cases.contains(.inGracePeriod))
    }

    @Test("PrismProductInfo stores properties correctly")
    func productInfoProperties() {
        let info = PrismProductInfo(
            id: "com.test.product",
            displayName: "Test Product",
            description: "A test product",
            price: 9.99,
            type: .nonConsumable
        )
        #expect(info.id == "com.test.product")
        #expect(info.displayName == "Test Product")
        #expect(info.description == "A test product")
        #expect(info.price == 9.99)
        #expect(info.type == .nonConsumable)
    }

    @Test("PrismTransactionInfo stores properties correctly")
    func transactionInfoProperties() {
        let date = Date()
        let expiry = Date().addingTimeInterval(86400)
        let info = PrismTransactionInfo(
            id: 12345,
            productID: "com.test.sub",
            purchaseDate: date,
            expirationDate: expiry,
            isUpgraded: true,
            revocationDate: nil
        )
        #expect(info.id == 12345)
        #expect(info.productID == "com.test.sub")
        #expect(info.purchaseDate == date)
        #expect(info.expirationDate == expiry)
        #expect(info.isUpgraded == true)
        #expect(info.revocationDate == nil)
    }

    @Test("PrismTransactionInfo defaults")
    func transactionInfoDefaults() {
        let info = PrismTransactionInfo(
            id: 1,
            productID: "test",
            purchaseDate: Date()
        )
        #expect(info.expirationDate == nil)
        #expect(info.isUpgraded == false)
        #expect(info.revocationDate == nil)
    }
}

// MARK: - MetricKit Tests

@Suite("PrismMetricKit")
struct PrismMetricKitTests {

    @Test("PrismAppMetrics defaults to nil")
    func appMetricsDefaults() {
        let metrics = PrismAppMetrics()
        #expect(metrics.launchDuration == nil)
        #expect(metrics.hangDuration == nil)
        #expect(metrics.peakMemory == nil)
        #expect(metrics.cpuTime == nil)
        #expect(metrics.diskWrites == nil)
    }

    @Test("PrismAppMetrics stores provided values")
    func appMetricsProperties() {
        let metrics = PrismAppMetrics(
            launchDuration: 1.5,
            hangDuration: 0.3,
            peakMemory: 128.0,
            cpuTime: 45.2,
            diskWrites: 10.5
        )
        #expect(metrics.launchDuration == 1.5)
        #expect(metrics.hangDuration == 0.3)
        #expect(metrics.peakMemory == 128.0)
        #expect(metrics.cpuTime == 45.2)
        #expect(metrics.diskWrites == 10.5)
    }

    @Test("PrismCrashDiagnostic stores properties correctly")
    func crashDiagnosticProperties() {
        let id = UUID()
        let timestamp = Date()
        let diagnostic = PrismCrashDiagnostic(
            id: id,
            timestamp: timestamp,
            exceptionType: "EXC_BAD_ACCESS",
            signal: "SIGSEGV",
            terminationReason: "Namespace SIGNAL, Code 0xb",
            callStackTree: "{}"
        )
        #expect(diagnostic.id == id)
        #expect(diagnostic.timestamp == timestamp)
        #expect(diagnostic.exceptionType == "EXC_BAD_ACCESS")
        #expect(diagnostic.signal == "SIGSEGV")
        #expect(diagnostic.terminationReason == "Namespace SIGNAL, Code 0xb")
        #expect(diagnostic.callStackTree == "{}")
    }

    @Test("PrismCrashDiagnostic has default nil optionals")
    func crashDiagnosticDefaults() {
        let diagnostic = PrismCrashDiagnostic(timestamp: Date())
        #expect(diagnostic.exceptionType == nil)
        #expect(diagnostic.signal == nil)
        #expect(diagnostic.terminationReason == nil)
        #expect(diagnostic.callStackTree == nil)
    }
}

// MARK: - DeviceActivity Tests

@Suite("PrismDeviceActivity")
struct PrismDeviceActivityTests {

    @Test("PrismDeviceActivitySchedule stores properties correctly")
    func scheduleProperties() {
        let schedule = PrismDeviceActivitySchedule(
            startHour: 8,
            startMinute: 30,
            endHour: 22,
            endMinute: 0,
            repeats: true
        )
        #expect(schedule.startHour == 8)
        #expect(schedule.startMinute == 30)
        #expect(schedule.endHour == 22)
        #expect(schedule.endMinute == 0)
        #expect(schedule.repeats == true)
    }

    @Test("PrismDeviceActivitySchedule defaults repeats to true")
    func scheduleDefaultRepeats() {
        let schedule = PrismDeviceActivitySchedule(startHour: 9, startMinute: 0, endHour: 17, endMinute: 0)
        #expect(schedule.repeats == true)
    }

    @Test("PrismDeviceActivityEvent stores properties correctly")
    func eventProperties() {
        let event = PrismDeviceActivityEvent(
            name: "social-limit",
            threshold: 3600,
            includesAllActivity: true
        )
        #expect(event.name == "social-limit")
        #expect(event.threshold == 3600)
        #expect(event.includesAllActivity == true)
    }

    @Test("PrismDeviceActivityEvent defaults includesAllActivity to false")
    func eventDefaultIncludesAll() {
        let event = PrismDeviceActivityEvent(name: "test", threshold: 60)
        #expect(event.includesAllActivity == false)
    }
}

// MARK: - BackgroundTasks Tests

@Suite("PrismBackgroundTasks")
struct PrismBackgroundTasksTests {

    @Test("PrismBackgroundTaskType has 2 cases")
    func taskTypeCaseCount() {
        let types: [PrismBackgroundTaskType] = [.appRefresh, .processing]
        #expect(types.count == 2)
    }

    @Test("PrismBackgroundTaskConfig stores properties correctly")
    func taskConfigProperties() {
        let date = Date()
        let config = PrismBackgroundTaskConfig(
            identifier: "com.test.refresh",
            type: .appRefresh,
            requiresNetwork: true,
            requiresCharging: false,
            earliestBeginDate: date
        )
        #expect(config.identifier == "com.test.refresh")
        #expect(config.type == .appRefresh)
        #expect(config.requiresNetwork == true)
        #expect(config.requiresCharging == false)
        #expect(config.earliestBeginDate == date)
    }

    @Test("PrismBackgroundTaskConfig has sensible defaults")
    func taskConfigDefaults() {
        let config = PrismBackgroundTaskConfig(
            identifier: "com.test.process",
            type: .processing
        )
        #expect(config.requiresNetwork == false)
        #expect(config.requiresCharging == false)
        #expect(config.earliestBeginDate == nil)
    }
}

// MARK: - Wallet / Apple Pay Tests

@Suite("PrismApplePay")
struct PrismApplePayTests {

    @Test("PrismPaymentNetwork has 4 cases")
    func paymentNetworkCaseCount() {
        #expect(PrismPaymentNetwork.allCases.count == 4)
    }

    @Test("PrismPaymentNetwork includes all expected cases")
    func paymentNetworkCases() {
        let cases = PrismPaymentNetwork.allCases
        #expect(cases.contains(.visa))
        #expect(cases.contains(.mastercard))
        #expect(cases.contains(.amex))
        #expect(cases.contains(.discover))
    }

    @Test("PrismPaymentItemType has 2 cases")
    func paymentItemTypeCases() {
        let types: [PrismPaymentItemType] = [.final_, .pending]
        #expect(types.count == 2)
    }

    @Test("PrismPaymentItem stores properties correctly")
    func paymentItemProperties() {
        let item = PrismPaymentItem(label: "Widget", amount: 29.99, type: .final_)
        #expect(item.label == "Widget")
        #expect(item.amount == 29.99)
        #expect(item.type == .final_)
    }

    @Test("PrismPaymentItem defaults type to final")
    func paymentItemDefaultType() {
        let item = PrismPaymentItem(label: "Test", amount: 1.00)
        #expect(item.type == .final_)
    }

    @Test("PrismPaymentRequest stores properties correctly")
    func paymentRequestProperties() {
        let item = PrismPaymentItem(label: "Total", amount: 49.99)
        let request = PrismPaymentRequest(
            merchantID: "merchant.com.test",
            countryCode: "US",
            currencyCode: "USD",
            items: [item],
            supportedNetworks: [.visa, .mastercard]
        )
        #expect(request.merchantID == "merchant.com.test")
        #expect(request.countryCode == "US")
        #expect(request.currencyCode == "USD")
        #expect(request.items.count == 1)
        #expect(request.supportedNetworks.count == 2)
    }

    @Test("PrismPaymentResult stores properties correctly")
    func paymentResultProperties() {
        let result = PrismPaymentResult(
            transactionID: "txn_123",
            token: Data([0x01, 0x02]),
            success: true
        )
        #expect(result.transactionID == "txn_123")
        #expect(result.token == Data([0x01, 0x02]))
        #expect(result.success == true)
    }

    @Test("PrismPaymentResult defaults")
    func paymentResultDefaults() {
        let result = PrismPaymentResult(success: false)
        #expect(result.transactionID == nil)
        #expect(result.token == nil)
        #expect(result.success == false)
    }
}

// MARK: - App Clip Tests

@Suite("PrismAppClip")
struct PrismAppClipTests {

    @Test("PrismAppClipRegion stores properties correctly")
    func regionProperties() {
        let region = PrismAppClipRegion(latitude: 37.7749, longitude: -122.4194, radius: 500)
        #expect(region.latitude == 37.7749)
        #expect(region.longitude == -122.4194)
        #expect(region.radius == 500)
    }

    @Test("PrismAppClipExperience cases")
    func experienceCases() {
        let defaultExp = PrismAppClipExperience.defaultExperience
        let advancedExp = PrismAppClipExperience.advancedExperience("promo-2024")

        if case .defaultExperience = defaultExp {
            // pass
        } else {
            #expect(Bool(false), "Expected defaultExperience")
        }

        if case .advancedExperience(let id) = advancedExp {
            #expect(id == "promo-2024")
        } else {
            #expect(Bool(false), "Expected advancedExperience")
        }
    }

    @Test("PrismAppClipInvocation stores properties correctly")
    func invocationProperties() {
        let url = URL(string: "https://example.com/clip?item=123")!
        let region = PrismAppClipRegion(latitude: 40.0, longitude: -74.0, radius: 100)
        let invocation = PrismAppClipInvocation(url: url, payload: "item=123", region: region)
        #expect(invocation.url == url)
        #expect(invocation.payload == "item=123")
        #expect(invocation.region?.latitude == 40.0)
    }

    @Test("PrismAppClipInvocation defaults")
    func invocationDefaults() {
        let url = URL(string: "https://example.com")!
        let invocation = PrismAppClipInvocation(url: url)
        #expect(invocation.payload == nil)
        #expect(invocation.region == nil)
    }
}

// MARK: - Auth Tests

@Suite("PrismSignInWithApple")
struct PrismSignInWithAppleTests {

    @Test("PrismAppleIDScope has 2 cases")
    func scopeCaseCount() {
        #expect(PrismAppleIDScope.allCases.count == 2)
    }

    @Test("PrismAppleIDScope includes all expected cases")
    func scopeCases() {
        let cases = PrismAppleIDScope.allCases
        #expect(cases.contains(.email))
        #expect(cases.contains(.fullName))
    }

    @Test("PrismAppleIDCredentialState has 4 cases")
    func credentialStateCaseCount() {
        #expect(PrismAppleIDCredentialState.allCases.count == 4)
    }

    @Test("PrismAppleIDCredentialState includes all expected cases")
    func credentialStateCases() {
        let cases = PrismAppleIDCredentialState.allCases
        #expect(cases.contains(.authorized))
        #expect(cases.contains(.revoked))
        #expect(cases.contains(.notFound))
        #expect(cases.contains(.transferred))
    }

    @Test("PrismAppleIDCredential stores properties correctly")
    func credentialProperties() {
        let tokenData = Data("token".utf8)
        let codeData = Data("code".utf8)
        let credential = PrismAppleIDCredential(
            userID: "user_001",
            email: "test@example.com",
            fullName: "John Doe",
            identityToken: tokenData,
            authorizationCode: codeData
        )
        #expect(credential.userID == "user_001")
        #expect(credential.email == "test@example.com")
        #expect(credential.fullName == "John Doe")
        #expect(credential.identityToken == tokenData)
        #expect(credential.authorizationCode == codeData)
    }

    @Test("PrismAppleIDCredential defaults")
    func credentialDefaults() {
        let credential = PrismAppleIDCredential(userID: "user_002")
        #expect(credential.email == nil)
        #expect(credential.fullName == nil)
        #expect(credential.identityToken == nil)
        #expect(credential.authorizationCode == nil)
    }
}

// MARK: - Notifications Tests

@Suite("PrismPushNotifications")
struct PrismPushNotificationsTests {

    @Test("PrismNotificationPermission has 5 cases")
    func permissionCaseCount() {
        #expect(PrismNotificationPermission.allCases.count == 5)
    }

    @Test("PrismNotificationPermission includes all expected cases")
    func permissionCases() {
        let cases = PrismNotificationPermission.allCases
        #expect(cases.contains(.notDetermined))
        #expect(cases.contains(.denied))
        #expect(cases.contains(.authorized))
        #expect(cases.contains(.provisional))
        #expect(cases.contains(.ephemeral))
    }

    @Test("PrismNotificationOption cases")
    func optionCases() {
        let options: [PrismNotificationOption] = [.alert, .badge, .sound, .provisional, .criticalAlert]
        #expect(options.count == 5)
    }

    @Test("PrismNotificationContent stores properties correctly")
    func contentProperties() {
        let content = PrismNotificationContent(
            title: "New Message",
            body: "You have a new message",
            subtitle: "From John",
            badge: 3,
            sound: .default_,
            categoryIdentifier: "MESSAGE",
            userInfo: ["key": "value"]
        )
        #expect(content.title == "New Message")
        #expect(content.body == "You have a new message")
        #expect(content.subtitle == "From John")
        #expect(content.badge == 3)
        #expect(content.categoryIdentifier == "MESSAGE")
        #expect(content.userInfo["key"] == "value")
    }

    @Test("PrismNotificationContent defaults")
    func contentDefaults() {
        let content = PrismNotificationContent(title: "Title", body: "Body")
        #expect(content.subtitle == nil)
        #expect(content.badge == nil)
        #expect(content.sound == nil)
        #expect(content.categoryIdentifier == nil)
        #expect(content.userInfo.isEmpty)
    }

    @Test("PrismNotificationSound cases")
    func soundCases() {
        let default_ = PrismNotificationSound.default_
        let named = PrismNotificationSound.named("chime")
        let critical = PrismNotificationSound.critical

        if case .default_ = default_ {} else { #expect(Bool(false)) }
        if case .named(let name) = named { #expect(name == "chime") } else { #expect(Bool(false)) }
        if case .critical = critical {} else { #expect(Bool(false)) }
    }

    @Test("PrismNotificationTrigger cases")
    func triggerCases() {
        let immediate = PrismNotificationTrigger.immediate
        let interval = PrismNotificationTrigger.timeInterval(60)
        let calendar = PrismNotificationTrigger.calendar(DateComponents(hour: 9))
        let location = PrismNotificationTrigger.location(latitude: 37.0, longitude: -122.0, radius: 100)

        if case .immediate = immediate {} else { #expect(Bool(false)) }
        if case .timeInterval(let t) = interval { #expect(t == 60) } else { #expect(Bool(false)) }
        if case .calendar(let c) = calendar { #expect(c.hour == 9) } else { #expect(Bool(false)) }
        if case .location(let lat, let lon, let r) = location {
            #expect(lat == 37.0)
            #expect(lon == -122.0)
            #expect(r == 100)
        } else {
            #expect(Bool(false))
        }
    }
}

// MARK: - CloudKit Tests

@Suite("PrismCloudKit")
struct PrismCloudKitTests {

    @Test("PrismCloudDatabase has 3 cases")
    func databaseCases() {
        let dbs: [PrismCloudDatabase] = [.publicDB, .privateDB, .sharedDB]
        #expect(dbs.count == 3)
    }

    @Test("PrismCloudAccountStatus has 5 cases")
    func accountStatusCaseCount() {
        #expect(PrismCloudAccountStatus.allCases.count == 5)
    }

    @Test("PrismCloudAccountStatus includes all expected cases")
    func accountStatusCases() {
        let cases = PrismCloudAccountStatus.allCases
        #expect(cases.contains(.available))
        #expect(cases.contains(.noAccount))
        #expect(cases.contains(.restricted))
        #expect(cases.contains(.couldNotDetermine))
        #expect(cases.contains(.temporarilyUnavailable))
    }

    @Test("PrismCloudRecord stores properties correctly")
    func cloudRecordProperties() {
        let now = Date()
        let record = PrismCloudRecord(
            id: "record-1",
            recordType: "Note",
            fields: ["title": .string("Hello"), "count": .int(42)],
            createdAt: now,
            modifiedAt: now
        )
        #expect(record.id == "record-1")
        #expect(record.recordType == "Note")
        #expect(record.fields.count == 2)
        #expect(record.createdAt == now)
        #expect(record.modifiedAt == now)
    }

    @Test("PrismCloudRecord defaults")
    func cloudRecordDefaults() {
        let record = PrismCloudRecord(id: "r", recordType: "T", fields: [:])
        #expect(record.createdAt == nil)
        #expect(record.modifiedAt == nil)
    }

    @Test("PrismCloudValue cases")
    func cloudValueCases() {
        let stringVal = PrismCloudValue.string("hello")
        let intVal = PrismCloudValue.int(42)
        let doubleVal = PrismCloudValue.double(3.14)
        let dataVal = PrismCloudValue.data(Data([0x01]))
        let dateVal = PrismCloudValue.date(Date())
        let refVal = PrismCloudValue.reference("ref-1")
        let arrVal = PrismCloudValue.stringArray(["a", "b"])

        if case .string(let s) = stringVal { #expect(s == "hello") } else { #expect(Bool(false)) }
        if case .int(let i) = intVal { #expect(i == 42) } else { #expect(Bool(false)) }
        if case .double(let d) = doubleVal { #expect(d == 3.14) } else { #expect(Bool(false)) }
        if case .data(let d) = dataVal { #expect(d == Data([0x01])) } else { #expect(Bool(false)) }
        if case .date = dateVal {} else { #expect(Bool(false)) }
        if case .reference(let r) = refVal { #expect(r == "ref-1") } else { #expect(Bool(false)) }
        if case .stringArray(let a) = arrVal { #expect(a == ["a", "b"]) } else { #expect(Bool(false)) }
    }
}

// MARK: - HealthKit Tests

@Suite("PrismHealthKit")
struct PrismHealthKitTests {

    @Test("PrismHealthDataType has 8 cases")
    func dataTypeCaseCount() {
        #expect(PrismHealthDataType.allCases.count == 8)
    }

    @Test("PrismHealthDataType includes all expected cases")
    func dataTypeCases() {
        let cases = PrismHealthDataType.allCases
        #expect(cases.contains(.stepCount))
        #expect(cases.contains(.heartRate))
        #expect(cases.contains(.activeEnergy))
        #expect(cases.contains(.sleepAnalysis))
        #expect(cases.contains(.bodyMass))
        #expect(cases.contains(.height))
        #expect(cases.contains(.bloodOxygen))
        #expect(cases.contains(.respiratoryRate))
    }

    @Test("PrismHealthDeliveryFrequency has 4 cases")
    func deliveryFrequencyCases() {
        let frequencies: [PrismHealthDeliveryFrequency] = [.immediate, .hourly, .daily, .weekly]
        #expect(frequencies.count == 4)
    }

    @Test("PrismHealthSample stores properties correctly")
    func healthSampleProperties() {
        let start = Date()
        let end = Date().addingTimeInterval(3600)
        let sample = PrismHealthSample(
            type: .heartRate,
            value: 72.0,
            unit: "BPM",
            startDate: start,
            endDate: end
        )
        #expect(sample.type == .heartRate)
        #expect(sample.value == 72.0)
        #expect(sample.unit == "BPM")
        #expect(sample.startDate == start)
        #expect(sample.endDate == end)
    }

    @Test("PrismHealthStatistics stores properties correctly")
    func healthStatisticsProperties() {
        let stats = PrismHealthStatistics(
            type: .stepCount,
            sum: 10000,
            average: 5000,
            min: 1000,
            max: 8000,
            unit: "count"
        )
        #expect(stats.type == .stepCount)
        #expect(stats.sum == 10000)
        #expect(stats.average == 5000)
        #expect(stats.min == 1000)
        #expect(stats.max == 8000)
        #expect(stats.unit == "count")
    }

    @Test("PrismHealthStatistics defaults")
    func healthStatisticsDefaults() {
        let stats = PrismHealthStatistics(type: .bodyMass, unit: "kg")
        #expect(stats.sum == nil)
        #expect(stats.average == nil)
        #expect(stats.min == nil)
        #expect(stats.max == nil)
    }
}

// MARK: - WidgetKit Tests

@Suite("PrismWidgetKit")
struct PrismWidgetKitTests {

    @Test("PrismWidgetFamily has 7 cases")
    func widgetFamilyCaseCount() {
        #expect(PrismWidgetFamily.allCases.count == 7)
    }

    @Test("PrismWidgetFamily includes all expected cases")
    func widgetFamilyCases() {
        let cases = PrismWidgetFamily.allCases
        #expect(cases.contains(.systemSmall))
        #expect(cases.contains(.systemMedium))
        #expect(cases.contains(.systemLarge))
        #expect(cases.contains(.systemExtraLarge))
        #expect(cases.contains(.accessoryCircular))
        #expect(cases.contains(.accessoryRectangular))
        #expect(cases.contains(.accessoryInline))
    }

    @Test("PrismWidgetReloadPolicy cases")
    func reloadPolicyCases() {
        let atEnd = PrismWidgetReloadPolicy.atEnd
        let afterMinutes = PrismWidgetReloadPolicy.afterMinutes(30)
        let never = PrismWidgetReloadPolicy.never

        if case .atEnd = atEnd {} else { #expect(Bool(false)) }
        if case .afterMinutes(let m) = afterMinutes { #expect(m == 30) } else { #expect(Bool(false)) }
        if case .never = never {} else { #expect(Bool(false)) }
    }

    @Test("PrismWidgetEntry stores properties correctly")
    func widgetEntryProperties() {
        let date = Date()
        let entry = PrismWidgetEntry(date: date, relevance: 0.8, displayName: "Weather")
        #expect(entry.date == date)
        #expect(entry.relevance == 0.8)
        #expect(entry.displayName == "Weather")
    }

    @Test("PrismWidgetEntry defaults")
    func widgetEntryDefaults() {
        let entry = PrismWidgetEntry(date: Date())
        #expect(entry.relevance == nil)
        #expect(entry.displayName == nil)
    }

    @Test("PrismWidgetConfiguration stores properties correctly")
    func widgetConfigProperties() {
        let config = PrismWidgetConfiguration(kind: "com.test.widget", family: .systemMedium)
        #expect(config.kind == "com.test.widget")
        #expect(config.family == .systemMedium)
    }
}
