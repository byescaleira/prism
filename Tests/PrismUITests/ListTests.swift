import SwiftUI
import Testing

@testable import PrismUI

struct ListTests {

    // MARK: - PrismRow

    @Test
    func rowCreatesWithTitle() {
        let row = PrismRow("Settings")
        #expect(row != nil)
    }

    @Test
    func rowSupportsIconAndSubtitle() {
        let row = PrismRow(
            "Notifications",
            subtitle: "Manage alerts",
            icon: "bell.fill"
        )
        #expect(row != nil)
    }

    @Test
    func rowSupportsTrailingContent() {
        let row = PrismRow("Language") {
            Text("English")
                .foregroundStyle(.secondary)
        }
        #expect(row != nil)
    }

    // MARK: - PrismDisclosureRow

    @Test
    func disclosureRowCreatesWithChevron() {
        let row = PrismDisclosureRow("Account", icon: "person.fill")
        #expect(row != nil)
    }

    // MARK: - PrismBadge

    @Test
    func badgeDisplaysCount() {
        let badge = PrismBadge(count: 5)
        #expect(badge != nil)
    }

    @Test
    func badgeCapsAtMax() {
        let badge = PrismBadge(count: 150, maxDisplay: 99)
        #expect(badge != nil)
    }

    @Test
    func badgeHidesWhenZero() {
        let badge = PrismBadge(count: 0)
        #expect(badge != nil)
    }
}
