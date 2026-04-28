#if canImport(StoreKit)
import StoreKit

// MARK: - Product Type

/// Represents the type of an in-app purchase product.
public enum PrismProductType: Sendable, CaseIterable {
    case consumable
    case nonConsumable
    case autoRenewable
    case nonRenewable
}

// MARK: - Product Info

/// Lightweight value describing a StoreKit product.
public struct PrismProductInfo: Sendable {
    /// The product identifier registered in App Store Connect.
    public let id: String
    /// The localized display name.
    public let displayName: String
    /// The localized product description.
    public let description: String
    /// The decimal price in the user's storefront currency.
    public let price: Decimal
    /// The product type classification.
    public let type: PrismProductType

    public init(id: String, displayName: String, description: String, price: Decimal, type: PrismProductType) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.price = price
        self.type = type
    }
}

// MARK: - Transaction Info

/// Snapshot of a verified StoreKit transaction.
public struct PrismTransactionInfo: Sendable {
    /// The unique transaction identifier assigned by the App Store.
    public let id: UInt64
    /// The product identifier associated with the transaction.
    public let productID: String
    /// The date the purchase was made.
    public let purchaseDate: Date
    /// The subscription expiration date, if applicable.
    public let expirationDate: Date?
    /// Whether the subscription was upgraded to a higher-tier plan.
    public let isUpgraded: Bool
    /// The date the transaction was revoked, if applicable.
    public let revocationDate: Date?

    public init(id: UInt64, productID: String, purchaseDate: Date, expirationDate: Date? = nil, isUpgraded: Bool = false, revocationDate: Date? = nil) {
        self.id = id
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.isUpgraded = isUpgraded
        self.revocationDate = revocationDate
    }
}

// MARK: - Subscription Status

/// Represents the current state of an auto-renewable subscription.
public enum PrismSubscriptionStatus: Sendable, CaseIterable {
    case subscribed
    case expired
    case revoked
    case inBillingRetry
    case inGracePeriod
}

// MARK: - StoreKit Client

/// Observable client that wraps StoreKit 2 APIs for products, purchases, and subscriptions.
@MainActor @Observable
public final class PrismStoreKitClient {
    /// The list of available products fetched from the App Store.
    public private(set) var products: [PrismProductInfo] = []
    /// The set of product identifiers the user has purchased.
    public private(set) var purchasedProductIDs: Set<String> = []

    private var transactionListener: Task<Void, Never>?

    public init() {}

    deinit {
        transactionListener?.cancel()
    }

    /// Fetches products from the App Store for the given identifiers.
    public func fetchProducts(ids: Set<String>) async throws {
        let storeProducts = try await Product.products(for: ids)
        products = storeProducts.map { product in
            let productType: PrismProductType = switch product.type {
            case .consumable: .consumable
            case .nonConsumable: .nonConsumable
            case .autoRenewable: .autoRenewable
            case .nonRenewable: .nonRenewable
            default: .nonConsumable
            }
            return PrismProductInfo(
                id: product.id,
                displayName: product.displayName,
                description: product.description,
                price: product.price,
                type: productType
            )
        }
    }

    /// Initiates a purchase for the given product identifier.
    public func purchase(productID: String) async throws -> PrismTransactionInfo? {
        guard let product = try await Product.products(for: [productID]).first else {
            return nil
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            purchasedProductIDs.insert(transaction.productID)
            return PrismTransactionInfo(
                id: transaction.id,
                productID: transaction.productID,
                purchaseDate: transaction.purchaseDate,
                expirationDate: transaction.expirationDate,
                isUpgraded: transaction.isUpgraded,
                revocationDate: transaction.revocationDate
            )
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    /// Restores previously completed purchases by scanning current entitlements.
    public func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    /// Returns the subscription status for the given subscription group identifier.
    public func subscriptionStatus(for groupID: String) async -> PrismSubscriptionStatus {
        guard let statuses = try? await Product.SubscriptionInfo.status(for: groupID),
              let status = statuses.first else {
            return .expired
        }
        switch status.state {
        case .subscribed: return .subscribed
        case .expired: return .expired
        case .revoked: return .revoked
        case .inBillingRetryPeriod: return .inBillingRetry
        case .inGracePeriod: return .inGracePeriod
        default: return .expired
        }
    }

    /// Starts a background listener for transaction updates (renewals, revocations, etc.).
    public func startTransactionListener() {
        transactionListener = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await MainActor.run {
                        self?.purchasedProductIDs.insert(transaction.productID)
                    }
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Private

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreKitError.notAvailableInStorefront
        case .verified(let value): return value
        }
    }
}
#endif
