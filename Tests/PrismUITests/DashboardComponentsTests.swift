import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Dashboard Components")
struct DashboardComponentsTests {

    // MARK: - PrismTrend

    @Test("PrismTrend has exactly 3 cases")
    func trendHasThreeCases() {
        let cases = PrismTrend.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.up))
        #expect(cases.contains(.down))
        #expect(cases.contains(.flat))
    }

    @Test("PrismTrend.up maps to success color")
    func trendUpColor() {
        #expect(PrismTrend.up.colorToken == .success)
    }

    @Test("PrismTrend.down maps to error color")
    func trendDownColor() {
        #expect(PrismTrend.down.colorToken == .error)
    }

    @Test("PrismTrend.flat maps to secondary color")
    func trendFlatColor() {
        #expect(PrismTrend.flat.colorToken == .onBackgroundSecondary)
    }

    @Test("PrismTrend provides distinct system images")
    func trendSystemImages() {
        let images = PrismTrend.allCases.map(\.systemImage)
        #expect(Set(images).count == 3)
    }

    // MARK: - PrismKPICard

    @Test("PrismKPICard conforms to View")
    func kpiCardIsView() {
        let card = PrismKPICard(title: "Revenue", value: "$12,400")
        #expect(card is any View)
    }

    @Test("PrismKPICard creates with all parameters")
    func kpiCardFullInit() {
        let card = PrismKPICard(
            title: "Revenue",
            value: "$12,400",
            trend: .up,
            changePercentage: 12.5,
            icon: "dollarsign.circle",
            subtitle: "Monthly recurring revenue",
            sparklineData: [10, 12, 11, 14, 16],
            size: .expanded
        )
        #expect(card is any View)
    }

    @Test("PrismKPICard compact size creates successfully")
    func kpiCardCompactSize() {
        let card = PrismKPICard(
            title: "Users",
            value: "1,234",
            trend: .up,
            changePercentage: 5.2,
            size: .compact
        )
        #expect(card is any View)
    }

    // MARK: - PrismStatItem

    @Test("PrismStatItem stores all properties")
    func statItemProperties() {
        let item = PrismStatItem(label: "Users", value: "1,234", icon: "person.3", trend: .up)
        #expect(item.label == "Users")
        #expect(item.value == "1,234")
        #expect(item.icon == "person.3")
        #expect(item.trend == .up)
    }

    @Test("PrismStatItem has unique id")
    func statItemUniqueId() {
        let item1 = PrismStatItem(label: "A", value: "1")
        let item2 = PrismStatItem(label: "A", value: "1")
        #expect(item1.id != item2.id)
    }

    @Test("PrismStatItem defaults are nil")
    func statItemDefaults() {
        let item = PrismStatItem(label: "Test", value: "0")
        #expect(item.icon == nil)
        #expect(item.trend == nil)
    }

    // MARK: - PrismStatGrid

    @Test("PrismStatGrid conforms to View")
    func statGridIsView() {
        let grid = PrismStatGrid(items: [
            PrismStatItem(label: "Users", value: "100"),
            PrismStatItem(label: "Revenue", value: "$50k"),
        ])
        #expect(grid is any View)
    }

    @Test("PrismStatGrid accepts custom column width")
    func statGridCustomWidth() {
        let grid = PrismStatGrid(
            items: [PrismStatItem(label: "A", value: "1")],
            minimumColumnWidth: 200
        )
        #expect(grid is any View)
    }

    // MARK: - PrismActivity

    @Test("PrismActivity stores all properties")
    func activityProperties() {
        let date = Date()
        let id = UUID()
        let activity = PrismActivity(
            id: id,
            user: "Alice",
            action: "commented on",
            target: "Issue #42",
            timestamp: date,
            icon: "bubble.left"
        )
        #expect(activity.id == id)
        #expect(activity.user == "Alice")
        #expect(activity.action == "commented on")
        #expect(activity.target == "Issue #42")
        #expect(activity.timestamp == date)
        #expect(activity.icon == "bubble.left")
    }

    @Test("PrismActivity generates id when omitted")
    func activityAutoId() {
        let a1 = PrismActivity(user: "A", action: "did", target: "X", timestamp: Date())
        let a2 = PrismActivity(user: "A", action: "did", target: "X", timestamp: Date())
        #expect(a1.id != a2.id)
    }

    // MARK: - PrismActivityFeed

    @Test("PrismActivityFeed conforms to View")
    func activityFeedIsView() {
        let feed = PrismActivityFeed(activities: [
            PrismActivity(user: "Bob", action: "merged", target: "PR #7", timestamp: Date())
        ])
        #expect(feed is any View)
    }

    @Test("PrismActivityFeed supports grouped mode")
    func activityFeedGrouped() {
        let feed = PrismActivityFeed(
            activities: [
                PrismActivity(user: "Bob", action: "merged", target: "PR #7", timestamp: Date())
            ],
            groupByDate: true
        )
        #expect(feed is any View)
    }

    // MARK: - PrismActivityGroup

    @Test("PrismActivityGroup groups activities by date")
    func activityGroupGrouping() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let activities = [
            PrismActivity(user: "A", action: "did", target: "X", timestamp: today),
            PrismActivity(user: "B", action: "did", target: "Y", timestamp: yesterday),
        ]
        let groups = PrismActivityGroup.group(activities)
        #expect(groups.count == 2)
    }

    // MARK: - PrismTimelineEvent

    @Test("PrismTimelineEvent stores all properties")
    func timelineEventProperties() {
        let date = Date()
        let id = UUID()
        let event = PrismTimelineEvent(
            id: id,
            title: "Deployed",
            description: "Version 2.0",
            date: date,
            status: .completed,
            icon: "checkmark"
        )
        #expect(event.id == id)
        #expect(event.title == "Deployed")
        #expect(event.description == "Version 2.0")
        #expect(event.date == date)
        #expect(event.status == .completed)
        #expect(event.icon == "checkmark")
    }

    @Test("PrismTimelineEvent defaults are nil")
    func timelineEventDefaults() {
        let event = PrismTimelineEvent(title: "Test", date: Date(), status: .upcoming)
        #expect(event.description == nil)
        #expect(event.icon == nil)
    }

    // MARK: - PrismEventStatus

    @Test("PrismEventStatus has exactly 4 cases")
    func eventStatusHasFourCases() {
        let cases = PrismEventStatus.allCases
        #expect(cases.count == 4)
        #expect(cases.contains(.completed))
        #expect(cases.contains(.current))
        #expect(cases.contains(.upcoming))
        #expect(cases.contains(.failed))
    }

    @Test("PrismEventStatus provides distinct colors")
    func eventStatusColors() {
        let colors = PrismEventStatus.allCases.map(\.colorToken)
        #expect(Set(colors).count == 4)
    }

    @Test("PrismEventStatus provides distinct system images")
    func eventStatusImages() {
        let images = PrismEventStatus.allCases.map(\.systemImage)
        #expect(Set(images).count == 4)
    }

    // MARK: - PrismTimeline

    @Test("PrismTimeline conforms to View")
    func timelineIsView() {
        let timeline = PrismTimeline(events: [
            PrismTimelineEvent(title: "Start", date: Date(), status: .completed),
            PrismTimelineEvent(title: "Now", date: Date(), status: .current),
        ])
        #expect(timeline is any View)
    }

    // MARK: - PrismFeatureValue

    @Test("PrismFeatureValue has 4 cases")
    func featureValueHasFourCases() {
        let values: [PrismFeatureValue] = [.check, .cross, .text("Yes"), .number(42)]
        #expect(values.count == 4)
    }

    @Test("PrismFeatureValue text stores value")
    func featureValueText() {
        let value = PrismFeatureValue.text("Premium")
        if case .text(let str) = value {
            #expect(str == "Premium")
        } else {
            #expect(Bool(false), "Expected text case")
        }
    }

    @Test("PrismFeatureValue number stores value")
    func featureValueNumber() {
        let value = PrismFeatureValue.number(99.9)
        if case .number(let num) = value {
            #expect(num == 99.9)
        } else {
            #expect(Bool(false), "Expected number case")
        }
    }

    // MARK: - PrismComparisonTable

    @Test("PrismComparisonTable conforms to View")
    func comparisonTableIsView() {
        let table = PrismComparisonTable(
            columnHeaders: ["Basic", "Pro"],
            features: [
                PrismComparisonFeature(name: "Storage", values: [.text("5GB"), .text("100GB")]),
                PrismComparisonFeature(name: "Support", values: [.cross, .check]),
            ]
        )
        #expect(table is any View)
    }

    @Test("PrismComparisonTable supports highlighted column")
    func comparisonTableHighlight() {
        let table = PrismComparisonTable(
            columnHeaders: ["Free", "Pro", "Enterprise"],
            features: [
                PrismComparisonFeature(name: "API", values: [.check, .check, .check])
            ],
            highlightedColumn: 1
        )
        #expect(table is any View)
    }

    @Test("PrismComparisonFeature stores name and values")
    func comparisonFeatureStorage() {
        let feature = PrismComparisonFeature(name: "SSO", values: [.cross, .check])
        #expect(feature.name == "SSO")
        #expect(feature.values.count == 2)
    }

    @Test("PrismComparisonColumn stores header and values")
    func comparisonColumnStorage() {
        let column = PrismComparisonColumn(header: "Pro", values: ["10GB", "Unlimited"])
        #expect(column.header == "Pro")
        #expect(column.values.count == 2)
    }

    // MARK: - PrismSparklineRow

    @Test("PrismSparklineRow conforms to View")
    func sparklineRowIsView() {
        let row = PrismSparklineRow(
            label: "Revenue",
            value: "$12k",
            data: [10, 12, 11, 15, 18]
        )
        #expect(row is any View)
    }

    @Test("PrismSparklineRow accepts trend and subtitle")
    func sparklineRowFull() {
        let row = PrismSparklineRow(
            label: "Users",
            value: "1,234",
            data: [100, 120, 115, 130],
            trend: .up,
            subtitle: "Last 7 days"
        )
        #expect(row is any View)
    }
}
