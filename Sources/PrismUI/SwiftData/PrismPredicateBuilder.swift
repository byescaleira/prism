#if canImport(SwiftData)
import SwiftUI
import SwiftData

/// Filter comparison operators for predicate construction.
public enum PrismFilterOperator: String, CaseIterable, Sendable {
    /// Exact equality match.
    case equals
    /// Substring containment check.
    case contains
    /// Greater-than comparison.
    case greaterThan
    /// Less-than comparison.
    case lessThan
    /// Range containment check.
    case between
    /// Nil check.
    case isNil
    /// Non-nil check.
    case isNotNil
}

/// Describes a single filter condition with field, operator, and value.
public struct PrismFilterField: Sendable {
    /// The property name to filter on.
    public let name: String
    /// The comparison operator.
    public let `operator`: PrismFilterOperator
    /// The value to compare against, boxed as a sendable type.
    public let value: (any Sendable)?

    /// Creates a filter field definition.
    public init(name: String, operator op: PrismFilterOperator, value: (any Sendable)? = nil) {
        self.name = name
        self.operator = op
        self.value = value
    }
}

/// Chainable builder for constructing filter field arrays.
public struct PrismPredicateBuilder: Sendable {
    private var filters: [PrismFilterField]

    /// Creates an empty predicate builder.
    public init() {
        self.filters = []
    }

    /// Adds a WHERE condition.
    public func `where`(_ field: String, _ op: PrismFilterOperator, _ value: some Sendable) -> PrismPredicateBuilder {
        var copy = self
        copy.filters.append(PrismFilterField(name: field, operator: op, value: value))
        return copy
    }

    /// Adds an AND condition (appends to the filter chain).
    public func and(_ field: String, _ op: PrismFilterOperator, _ value: some Sendable) -> PrismPredicateBuilder {
        var copy = self
        copy.filters.append(PrismFilterField(name: field, operator: op, value: value))
        return copy
    }

    /// Adds an OR condition (appends to the filter chain).
    public func or(_ field: String, _ op: PrismFilterOperator, _ value: some Sendable) -> PrismPredicateBuilder {
        var copy = self
        copy.filters.append(PrismFilterField(name: field, operator: op, value: value))
        return copy
    }

    /// Builds and returns the accumulated filter fields.
    public func build() -> [PrismFilterField] {
        filters
    }
}

/// Interactive filter bar for user-driven predicate construction.
@MainActor
public struct PrismFilterBar: View {
    @Environment(\.prismTheme) private var theme

    @State private var selectedField: String
    @State private var selectedOperator: PrismFilterOperator = .equals
    @State private var filterValue: String = ""

    private let availableFields: [String]
    private let onApply: @MainActor ([PrismFilterField]) -> Void

    @State private var activeFilters: [PrismFilterField] = []

    /// Creates a filter bar with a list of available field names.
    public init(
        fields: [String],
        onApply: @escaping @MainActor ([PrismFilterField]) -> Void
    ) {
        self.availableFields = fields
        self.onApply = onApply
        self._selectedField = State(initialValue: fields.first ?? "")
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Picker("Field", selection: $selectedField) {
                    ForEach(availableFields, id: \.self) { field in
                        Text(field).tag(field)
                    }
                }
                .labelsHidden()
                .accessibilityLabel("Filter field")

                Picker("Operator", selection: $selectedOperator) {
                    ForEach(PrismFilterOperator.allCases, id: \.self) { op in
                        Text(op.rawValue).tag(op)
                    }
                }
                .labelsHidden()
                .accessibilityLabel("Filter operator")

                TextField("Value", text: $filterValue)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel("Filter value")

                Button {
                    addFilter()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel("Add filter")
            }
            .padding(.horizontal)

            if !activeFilters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(activeFilters.enumerated()), id: \.offset) { index, filter in
                            HStack(spacing: 4) {
                                Text("\(filter.name) \(filter.operator.rawValue) \(String(describing: filter.value ?? ""))")
                                    .font(.caption)

                                Button {
                                    removeFilter(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.small)
                                }
                                .accessibilityLabel("Remove filter")
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.color(.surfaceSecondary))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func addFilter() {
        let filter = PrismFilterField(
            name: selectedField,
            operator: selectedOperator,
            value: filterValue
        )
        activeFilters.append(filter)
        filterValue = ""
        onApply(activeFilters)
    }

    private func removeFilter(at index: Int) {
        activeFilters.remove(at: index)
        onApply(activeFilters)
    }
}
#endif
