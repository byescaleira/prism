import Testing
import SwiftUI
@testable import PrismUI

#if canImport(SwiftData)
import SwiftData

@MainActor
@Suite("SwiftData Integration V2")
struct SwiftDataIntegrationTests {

    // MARK: - PrismFormField Tests

    @Suite("PrismFormField")
    struct FormFieldTests {

        @Test("PrismFormField stores label and type")
        func fieldStoresLabelAndType() {
            let field = PrismFormField(label: "Name", keyPath: "name", fieldType: .text)
            #expect(field.label == "Name")
            #expect(field.keyPath == "name")
            #expect(field.fieldType == .text)
        }

        @Test("PrismFormField stores keyPath correctly")
        func fieldStoresKeyPath() {
            let field = PrismFormField(label: "Age", keyPath: "age", fieldType: .number)
            #expect(field.keyPath == "age")
            #expect(field.label == "Age")
        }

        @Test("PrismFormField with picker options")
        func fieldWithPickerOptions() {
            let options = ["Red", "Green", "Blue"]
            let field = PrismFormField(label: "Color", keyPath: "color", fieldType: .picker(options))
            if case .picker(let stored) = field.fieldType {
                #expect(stored == options)
            } else {
                #expect(Bool(false), "Expected picker field type")
            }
        }
    }

    // MARK: - FieldType Tests

    @Suite("FieldType")
    struct FieldTypeTests {

        @Test("FieldType has all expected cases")
        func allCases() {
            let text: FieldType = .text
            let number: FieldType = .number
            let toggle: FieldType = .toggle
            let date: FieldType = .date
            let picker: FieldType = .picker(["A"])

            #expect(text == .text)
            #expect(number == .number)
            #expect(toggle == .toggle)
            #expect(date == .date)
            #expect(picker == .picker(["A"]))
        }

        @Test("FieldType equality for picker compares options")
        func pickerEquality() {
            #expect(FieldType.picker(["A", "B"]) == .picker(["A", "B"]))
            #expect(FieldType.picker(["A"]) != .picker(["B"]))
        }
    }

    // MARK: - PrismMigrationStage Tests

    @Suite("PrismMigrationStage")
    struct MigrationStageTests {

        @Test("PrismMigrationStage stores version and description")
        func stageStoresVersionAndDescription() {
            let stage = PrismMigrationStage(version: "2.0.0", description: "Add new fields")
            #expect(stage.version == "2.0.0")
            #expect(stage.description == "Add new fields")
        }

        @Test("PrismMigrationStage defaults migrationPlan to nil")
        func stageDefaultsMigrationPlan() {
            let stage = PrismMigrationStage(version: "1.0.0", description: "Initial")
            #expect(stage.migrationPlan == nil)
        }
    }

    // MARK: - PrismMigrationHelper Tests

    @Suite("PrismMigrationHelper")
    struct MigrationHelperTests {

        private var helper: PrismMigrationHelper {
            PrismMigrationHelper(stages: [
                PrismMigrationStage(version: "1.0.0", description: "Initial"),
                PrismMigrationStage(version: "1.1.0", description: "Add timestamps"),
                PrismMigrationStage(version: "2.0.0", description: "Restructure"),
                PrismMigrationStage(version: "2.1.0", description: "Add indexes"),
            ])
        }

        @Test("needsMigration returns true for older to newer version")
        func needsMigrationTrue() {
            #expect(helper.needsMigration(from: "1.0.0", to: "2.0.0") == true)
        }

        @Test("needsMigration returns false for same version")
        func needsMigrationSameVersion() {
            #expect(helper.needsMigration(from: "1.0.0", to: "1.0.0") == false)
        }

        @Test("needsMigration returns false for newer to older version")
        func needsMigrationNewerToOlder() {
            #expect(helper.needsMigration(from: "2.0.0", to: "1.0.0") == false)
        }

        @Test("migrationStages returns correct subset")
        func migrationStagesSubset() {
            let stages = helper.migrationStages(from: "1.0.0", to: "2.0.0")
            #expect(stages.count == 2)
            #expect(stages[0].version == "1.1.0")
            #expect(stages[1].version == "2.0.0")
        }

        @Test("migrationStages returns empty for invalid range")
        func migrationStagesInvalid() {
            let stages = helper.migrationStages(from: "2.0.0", to: "1.0.0")
            #expect(stages.isEmpty)
        }

        @Test("currentVersion returns last stage version")
        func currentVersion() {
            #expect(helper.currentVersion() == "2.1.0")
        }

        @Test("currentVersion returns fallback for empty stages")
        func currentVersionEmpty() {
            let empty = PrismMigrationHelper(stages: [])
            #expect(empty.currentVersion() == "0.0.0")
        }
    }

    // MARK: - PrismSyncState Tests

    @Suite("PrismSyncState")
    struct SyncStateTests {

        @Test("PrismSyncState has all 4 cases")
        func allCases() {
            let idle: PrismSyncState = .idle
            let syncing: PrismSyncState = .syncing
            let synced: PrismSyncState = .synced
            let error: PrismSyncState = .error("fail")

            #expect(idle == .idle)
            #expect(syncing == .syncing)
            #expect(synced == .synced)
            #expect(error == .error("fail"))
        }

        @Test("PrismSyncState error carries message")
        func errorMessage() {
            let state: PrismSyncState = .error("Network timeout")
            if case .error(let message) = state {
                #expect(message == "Network timeout")
            } else {
                #expect(Bool(false), "Expected error state")
            }
        }
    }

    // MARK: - PrismCloudSyncMonitor Tests

    @Suite("PrismCloudSyncMonitor")
    struct CloudSyncMonitorTests {

        @Test("Default state is idle")
        @MainActor func defaultState() {
            let monitor = PrismCloudSyncMonitor()
            #expect(monitor.state == .idle)
            #expect(monitor.lastSyncDate == nil)
        }

        @Test("startMonitoring sets state to syncing")
        @MainActor func startMonitoring() {
            let monitor = PrismCloudSyncMonitor()
            monitor.startMonitoring()
            #expect(monitor.state == .syncing)
        }

        @Test("updateState changes state")
        @MainActor func updateState() {
            let monitor = PrismCloudSyncMonitor()
            monitor.updateState(.synced)
            #expect(monitor.state == .synced)
            #expect(monitor.lastSyncDate != nil)
        }
    }

    // MARK: - PrismFilterOperator Tests

    @Suite("PrismFilterOperator")
    struct FilterOperatorTests {

        @Test("PrismFilterOperator has all expected cases")
        func allCases() {
            let cases = PrismFilterOperator.allCases
            #expect(cases.count == 7)
            #expect(cases.contains(.equals))
            #expect(cases.contains(.contains))
            #expect(cases.contains(.greaterThan))
            #expect(cases.contains(.lessThan))
            #expect(cases.contains(.between))
            #expect(cases.contains(.isNil))
            #expect(cases.contains(.isNotNil))
        }
    }

    // MARK: - PrismPredicateBuilder Tests

    @Suite("PrismPredicateBuilder")
    struct PredicateBuilderTests {

        @Test("Chainable API builds filters")
        func chainableAPI() {
            let builder = PrismPredicateBuilder()
                .where("name", .equals, "Alice")
                .and("age", .greaterThan, 18)
                .or("status", .contains, "active")

            let filters = builder.build()
            #expect(filters.count == 3)
        }

        @Test("Build returns accumulated filters")
        func buildReturnsFilters() {
            let filters = PrismPredicateBuilder()
                .where("title", .contains, "Swift")
                .build()

            #expect(filters.count == 1)
            #expect(filters[0].name == "title")
            #expect(filters[0].operator == .contains)
        }

        @Test("Empty builder returns empty array")
        func emptyBuilder() {
            let filters = PrismPredicateBuilder().build()
            #expect(filters.isEmpty)
        }
    }

    // MARK: - PrismFilterField Tests

    @Suite("PrismFilterField")
    struct FilterFieldTests {

        @Test("PrismFilterField stores operator and name")
        func fieldStoresOperatorAndName() {
            let field = PrismFilterField(name: "email", operator: .contains, value: "@example.com")
            #expect(field.name == "email")
            #expect(field.operator == .contains)
        }

        @Test("PrismFilterField stores nil value for isNil operator")
        func fieldNilValue() {
            let field = PrismFilterField(name: "deletedAt", operator: .isNil)
            #expect(field.name == "deletedAt")
            #expect(field.operator == .isNil)
            #expect(field.value == nil)
        }
    }

    // MARK: - View Type Tests

    @Suite("View Types")
    struct ViewTypeTests {

        @Test("PrismSyncStatusView conforms to View")
        @MainActor func syncStatusViewIsView() {
            let monitor = PrismCloudSyncMonitor()
            let view = PrismSyncStatusView(monitor: monitor)
            #expect(view is any View)
        }

        @Test("PrismFilterBar conforms to View")
        @MainActor func filterBarIsView() {
            let view = PrismFilterBar(fields: ["name", "age"]) { _ in }
            #expect(view is any View)
        }

        @Test("PrismModelFormBuilder conforms to View")
        @MainActor func formBuilderIsView() {
            let fields = [PrismFormField(label: "Name", keyPath: "name", fieldType: .text)]
            let view = PrismModelFormBuilder(fields: fields) { _ in }
            #expect(view is any View)
        }
    }
}
#endif
