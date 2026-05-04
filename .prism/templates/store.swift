// MARK: - PrismArchitecture Store Template
// Usage: Copy, rename, customize.

import PrismArchitecture
import PrismFoundation

// MARK: - State

struct FeatureState: Equatable, Sendable {
    var items: [Item] = []
    var isLoading: Bool = false
    var error: PrismError?
}

// MARK: - Action

enum FeatureAction: Sendable {
    case loadItems
    case itemsLoaded([Item])
    case loadFailed(PrismError)
    case reset
}

// MARK: - Reducer

struct FeatureReducer: PrismReducer {
    func reduce(_ state: inout FeatureState, action: FeatureAction) {
        switch action {
        case .loadItems:
            state.isLoading = true
            state.error = nil
        case .itemsLoaded(let items):
            state.isLoading = false
            state.items = items
        case .loadFailed(let error):
            state.isLoading = false
            state.error = error
        case .reset:
            state = FeatureState()
        }
    }
}

// MARK: - Middleware

struct FeatureMiddleware: PrismMiddleware {
    let repository: FeatureRepositoryProtocol

    func handle(_ state: FeatureState, action: FeatureAction) async -> FeatureAction? {
        switch action {
        case .loadItems:
            do {
                let items = try await repository.fetchItems()
                return .itemsLoaded(items)
            } catch {
                return .loadFailed(PrismError(error))
            }
        default:
            return nil
        }
    }
}
