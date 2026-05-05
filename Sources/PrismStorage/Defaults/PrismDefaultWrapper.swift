#if canImport(SwiftUI)
    import SwiftUI

    /// Property wrapper for UserDefaults-backed storage with Codable support.
    ///
    /// ```swift
    /// @PrismDefault("username") var username: String = "Guest"
    /// @PrismDefault("onboarded") var onboarded: Bool = false
    /// ```
    @propertyWrapper
    public struct PrismDefault<Value: Codable & Sendable>: DynamicProperty {
        private let key: String
        private let defaultValue: Value
        private let store: PrismDefaultsStore

        @State private var cachedValue: Value

        public init(
            wrappedValue: Value,
            _ key: String,
            store: PrismDefaultsStore = PrismDefaultsStore()
        ) {
            self.key = key
            self.defaultValue = wrappedValue
            self.store = store
            self._cachedValue = State(
                initialValue: (try? store.load(Value.self, forKey: key)) ?? wrappedValue
            )
        }

        public var wrappedValue: Value {
            get { cachedValue }
            nonmutating set {
                cachedValue = newValue
                try? store.save(newValue, forKey: key)
            }
        }

        public var projectedValue: Binding<Value> {
            Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
        }
    }
#endif
