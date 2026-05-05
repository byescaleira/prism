import Foundation

public enum PrismStorageEvent: Sendable, Equatable {
    case saved(key: String)
    case loaded(key: String)
    case deleted(key: String)
    case cleared
    case expired(key: String)
    case evicted(key: String)
}
