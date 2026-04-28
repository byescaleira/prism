#if canImport(PassKit)
import PassKit

// MARK: - Payment Item Type

/// Whether a payment line item amount is final or pending.
public enum PrismPaymentItemType: Sendable {
    case final_
    case pending
}

// MARK: - Payment Item

/// A single line item in a payment request.
public struct PrismPaymentItem: Sendable {
    /// The display label for this line item.
    public let label: String
    /// The monetary amount.
    public let amount: Decimal
    /// Whether the amount is final or pending.
    public let type: PrismPaymentItemType

    public init(label: String, amount: Decimal, type: PrismPaymentItemType = .final_) {
        self.label = label
        self.amount = amount
        self.type = type
    }
}

// MARK: - Payment Network

/// Supported payment card networks for Apple Pay.
public enum PrismPaymentNetwork: Sendable, CaseIterable {
    case visa
    case mastercard
    case amex
    case discover
}

// MARK: - Payment Request

/// Configuration for an Apple Pay payment authorization request.
public struct PrismPaymentRequest: Sendable {
    /// The merchant identifier registered with Apple.
    public let merchantID: String
    /// The ISO 3166 country code.
    public let countryCode: String
    /// The ISO 4217 currency code.
    public let currencyCode: String
    /// The line items to display on the payment sheet.
    public let items: [PrismPaymentItem]
    /// The card networks accepted by the merchant.
    public let supportedNetworks: [PrismPaymentNetwork]

    public init(merchantID: String, countryCode: String, currencyCode: String, items: [PrismPaymentItem], supportedNetworks: [PrismPaymentNetwork]) {
        self.merchantID = merchantID
        self.countryCode = countryCode
        self.currencyCode = currencyCode
        self.items = items
        self.supportedNetworks = supportedNetworks
    }
}

// MARK: - Payment Result

/// The result of an Apple Pay payment authorization.
public struct PrismPaymentResult: Sendable {
    /// The transaction identifier from the payment processor.
    public let transactionID: String?
    /// The encrypted payment token data.
    public let token: Data?
    /// Whether the payment was authorized successfully.
    public let success: Bool

    public init(transactionID: String? = nil, token: Data? = nil, success: Bool) {
        self.transactionID = transactionID
        self.token = token
        self.success = success
    }
}

// MARK: - Apple Pay Client

/// Client that wraps PKPaymentAuthorizationController for Apple Pay transactions.
@MainActor
public final class PrismApplePayClient {

    public init() {}

    /// Returns whether Apple Pay is available on this device.
    public func canMakePayments() -> Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }

    /// Returns whether the device can make payments with the specified networks.
    public func canMakePayments(networks: [PrismPaymentNetwork]) -> Bool {
        let pkNetworks = networks.map { $0.pkNetwork }
        return PKPaymentAuthorizationController.canMakePayments(usingNetworks: pkNetworks)
    }

    /// Presents the Apple Pay payment sheet and returns the result.
    public func requestPayment(_ request: PrismPaymentRequest) async throws -> PrismPaymentResult {
        let pkRequest = PKPaymentRequest()
        pkRequest.merchantIdentifier = request.merchantID
        pkRequest.countryCode = request.countryCode
        pkRequest.currencyCode = request.currencyCode
        pkRequest.supportedNetworks = request.supportedNetworks.map { $0.pkNetwork }
        pkRequest.merchantCapabilities = .capability3DS
        pkRequest.paymentSummaryItems = request.items.map { item in
            PKPaymentSummaryItem(
                label: item.label,
                amount: NSDecimalNumber(decimal: item.amount),
                type: item.type == .pending ? .pending : .final
            )
        }

        guard let controller = PKPaymentAuthorizationController(paymentRequest: pkRequest) else {
            return PrismPaymentResult(success: false)
        }

        return await withCheckedContinuation { continuation in
            let delegate = PaymentDelegate { result in
                continuation.resume(returning: result)
            }
            // Store delegate reference to keep it alive during presentation
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            controller.delegate = delegate
            controller.present()
        }
    }
}

// MARK: - Private Helpers

private extension PrismPaymentNetwork {
    var pkNetwork: PKPaymentNetwork {
        switch self {
        case .visa: .visa
        case .mastercard: .masterCard
        case .amex: .amex
        case .discover: .discover
        }
    }
}

private final class PaymentDelegate: NSObject, PKPaymentAuthorizationControllerDelegate, @unchecked Sendable {
    private let completion: (PrismPaymentResult) -> Void

    init(completion: @escaping (PrismPaymentResult) -> Void) {
        self.completion = completion
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        let result = PrismPaymentResult(
            transactionID: payment.token.transactionIdentifier,
            token: payment.token.paymentData,
            success: true
        )
        handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
        completion(result)
    }
}
#endif
