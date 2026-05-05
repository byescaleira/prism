import Foundation

public struct PrismStorageConfiguration: Sendable {
    public let identifier: String
    public let maxSize: Int?
    public let defaultTTL: TimeInterval?

    public init(
        identifier: String = "default",
        maxSize: Int? = nil,
        defaultTTL: TimeInterval? = nil
    ) {
        self.identifier = identifier
        self.maxSize = maxSize
        self.defaultTTL = defaultTTL
    }

    public static let `default` = PrismStorageConfiguration()
}
