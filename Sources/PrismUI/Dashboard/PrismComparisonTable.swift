import SwiftUI

/// Value type for a single cell in a comparison table.
public enum PrismFeatureValue: Sendable {
    /// Feature is available (checkmark).
    case check
    /// Feature is unavailable (cross).
    case cross
    /// Arbitrary text value.
    case text(String)
    /// Numeric value.
    case number(Double)
}

/// A column definition in a comparison table.
public struct PrismComparisonColumn: Sendable, Identifiable {
    /// Unique identifier for this column.
    public let id = UUID()
    /// Column header text.
    public let header: String
    /// Ordered values for each feature row.
    public let values: [String]

    /// Creates a comparison column with a header and its row values.
    public init(header: String, values: [String]) {
        self.header = header
        self.values = values
    }
}

/// A feature row definition in a comparison table.
public struct PrismComparisonFeature: Sendable, Identifiable {
    /// Unique identifier for this feature row.
    public let id = UUID()
    /// Feature name displayed in the first column.
    public let name: String
    /// Values for each comparison column.
    public let values: [PrismFeatureValue]

    /// Creates a comparison feature row with a name and per-column values.
    public init(name: String, values: [PrismFeatureValue]) {
        self.name = name
        self.values = values
    }
}

/// Feature comparison grid with optional highlighted column.
public struct PrismComparisonTable: View {
    @Environment(\.prismTheme) private var theme

    private let columnHeaders: [String]
    private let features: [PrismComparisonFeature]
    private let highlightedColumn: Int?

    /// Creates a comparison table with column headers, features, and optional highlighted column.
    public init(
        columnHeaders: [String],
        features: [PrismComparisonFeature],
        highlightedColumn: Int? = nil
    ) {
        self.columnHeaders = columnHeaders
        self.features = features
        self.highlightedColumn = highlightedColumn
    }

    /// The comparison table view body with scrollable header and feature rows.
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                headerRow
                ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                    featureRow(feature, isEven: index.isMultiple(of: 2))
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Comparison table")
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Feature")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.color(.onBackgroundSecondary))
                .frame(width: 140, alignment: .leading)
                .padding(.horizontal, SpacingToken.sm.rawValue)

            ForEach(Array(columnHeaders.enumerated()), id: \.offset) { index, header in
                Text(header)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(
                        index == highlightedColumn
                            ? theme.color(.brand)
                            : theme.color(.onBackground)
                    )
                    .frame(width: 120)
                    .padding(.vertical, SpacingToken.sm.rawValue)
                    .background(
                        index == highlightedColumn
                            ? theme.color(.brand).opacity(0.08)
                            : Color.clear
                    )
            }
        }
        .padding(.vertical, SpacingToken.sm.rawValue)
        .background(theme.color(.surfaceSecondary))
    }

    // MARK: - Feature Rows

    private func featureRow(_ feature: PrismComparisonFeature, isEven: Bool) -> some View {
        HStack(spacing: 0) {
            Text(feature.name)
                .font(.subheadline)
                .foregroundStyle(theme.color(.onBackground))
                .frame(width: 140, alignment: .leading)
                .padding(.horizontal, SpacingToken.sm.rawValue)

            ForEach(Array(feature.values.enumerated()), id: \.offset) { index, value in
                featureValueView(value)
                    .frame(width: 120)
                    .padding(.vertical, SpacingToken.xs.rawValue)
                    .background(
                        index == highlightedColumn
                            ? theme.color(.brand).opacity(0.04)
                            : Color.clear
                    )
            }
        }
        .padding(.vertical, SpacingToken.xs.rawValue)
        .background(isEven ? theme.color(.surface) : Color.clear)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(featureAccessibilityLabel(feature))
    }

    @ViewBuilder
    private func featureValueView(_ value: PrismFeatureValue) -> some View {
        switch value {
        case .check:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(theme.color(.success))
                .font(.body)
        case .cross:
            Image(systemName: "xmark.circle")
                .foregroundStyle(theme.color(.onBackgroundTertiary))
                .font(.body)
        case .text(let text):
            Text(text)
                .font(.subheadline)
                .foregroundStyle(theme.color(.onBackground))
        case .number(let number):
            Text(String(format: "%.0f", number))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.color(.onBackground))
        }
    }

    private func featureAccessibilityLabel(_ feature: PrismComparisonFeature) -> String {
        var parts = [feature.name]
        for (index, value) in feature.values.enumerated() {
            let header = index < columnHeaders.count ? columnHeaders[index] : "Column \(index + 1)"
            switch value {
            case .check: parts.append("\(header): yes")
            case .cross: parts.append("\(header): no")
            case .text(let text): parts.append("\(header): \(text)")
            case .number(let number): parts.append("\(header): \(String(format: "%.0f", number))")
            }
        }
        return parts.joined(separator: ", ")
    }
}
