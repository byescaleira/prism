import PrismArchitecture
import SwiftUI

extension PrismStore {

    /// Creates a SwiftUI `Binding` that reads from store state and dispatches an action on write.
    public func binding<Value: Sendable>(
        for keyPath: KeyPath<State, Value>,
        send action: @escaping @Sendable (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: {
                MainActor.assumeIsolated {
                    self.state[keyPath: keyPath]
                }
            },
            set: { newValue in
                Task { @MainActor in
                    self.send(action(newValue))
                }
            }
        )
    }
}
