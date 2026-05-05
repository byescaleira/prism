import Foundation

// MARK: - Call Type

/// The type of call being reported or initiated.
public enum PrismCallType: Sendable {
    /// A generic call with no specific media type.
    case generic
    /// An audio-only call.
    case audio
    /// A video call.
    case video
}

// MARK: - Call End Reason

/// The reason a call ended, used when reporting call termination to the system.
public enum PrismCallEndReason: Sendable, CaseIterable {
    /// The call failed due to an error.
    case failed
    /// The remote party ended the call.
    case remoteEnded
    /// The call was not answered.
    case unanswered
    /// The call was answered on another device.
    case answeredElsewhere
    /// The call was declined on another device.
    case declinedElsewhere
}

// MARK: - Call Info

/// Describes the metadata for an incoming or outgoing call.
public struct PrismCallInfo: Sendable {
    /// A unique identifier for this call session.
    public let id: UUID
    /// The phone number or contact handle for the call.
    public let handle: String
    /// An optional display name shown in the call UI.
    public let displayName: String?
    /// The classification of the call (generic, audio, or video).
    public let type: PrismCallType
    /// Whether the call was initiated by the local user.
    public let isOutgoing: Bool
    /// Whether the call includes a video channel.
    public let hasVideo: Bool

    /// Creates a new call info descriptor with the given handle and configuration.
    public init(id: UUID = UUID(), handle: String, displayName: String? = nil, type: PrismCallType = .audio, isOutgoing: Bool = false, hasVideo: Bool = false) {
        self.id = id
        self.handle = handle
        self.displayName = displayName
        self.type = type
        self.isOutgoing = isOutgoing
        self.hasVideo = hasVideo
    }
}

// MARK: - Blocked Caller

/// Represents a phone number that should be identified and blocked by the system.
public struct PrismBlockedCaller: Sendable {
    /// The phone number to block.
    public let phoneNumber: String
    /// An optional label describing why this number is blocked.
    public let label: String?

    /// Creates a new blocked caller entry with the given phone number and optional label.
    public init(phoneNumber: String, label: String? = nil) {
        self.phoneNumber = phoneNumber
        self.label = label
    }
}

// MARK: - Call Action

/// An action to perform on a call via a CallKit transaction.
public enum PrismCallAction: Sendable {
    /// Start a new call with the given info.
    case start(PrismCallInfo)
    /// Answer an incoming call identified by UUID.
    case answer(UUID)
    /// End an active call identified by UUID.
    case end(UUID)
    /// Place or resume a call on hold (UUID, on-hold flag).
    case hold(UUID, Bool)
    /// Mute or unmute a call (UUID, muted flag).
    case mute(UUID, Bool)
}

// MARK: - Call Client

#if canImport(CallKit) && (os(iOS) || os(watchOS))
import CallKit

/// Observable client that wraps CallKit for managing VoIP call reporting and transactions.
@MainActor @Observable
public final class PrismCallClient {
    private let provider: CXProvider
    private let callController: CXCallController

    /// Creates a new call client with a default CallKit provider configuration.
    public init() {
        let configuration = CXProviderConfiguration()
        configuration.supportsVideo = true
        configuration.maximumCallsPerCallGroup = 1
        self.provider = CXProvider(configuration: configuration)
        self.callController = CXCallController()
    }

    /// Reports an incoming call to the system so it displays the native call UI.
    public func reportIncomingCall(info: PrismCallInfo) async throws {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: info.handle)
        update.localizedCallerName = info.displayName
        update.hasVideo = info.hasVideo
        try await provider.reportNewIncomingCall(with: info.id, update: update)
    }

    /// Reports that an outgoing call has started connecting.
    public func reportOutgoingCall(info: PrismCallInfo) {
        provider.reportOutgoingCall(with: info.id, startedConnectingAt: Date())
    }

    /// Reports that a call has ended with the specified reason.
    public func reportCallEnded(id: UUID, reason: PrismCallEndReason) {
        let cxReason: CXCallEndedReason = switch reason {
        case .failed: .failed
        case .remoteEnded: .remoteEnded
        case .unanswered: .unanswered
        case .answeredElsewhere: .answeredElsewhere
        case .declinedElsewhere: .declinedElsewhere
        }
        provider.reportCall(with: id, endedAt: Date(), reason: cxReason)
    }

    /// Reports that an outgoing call has successfully connected.
    public func reportCallConnected(id: UUID) {
        provider.reportOutgoingCall(with: id, connectedAt: Date())
    }

    /// Requests a CallKit transaction for the specified call action.
    public func requestTransaction(action: PrismCallAction) async throws {
        let cxAction: CXAction = switch action {
        case .start(let info):
            CXStartCallAction(call: info.id, handle: CXHandle(type: .phoneNumber, value: info.handle))
        case .answer(let id):
            CXAnswerCallAction(call: id)
        case .end(let id):
            CXEndCallAction(call: id)
        case .hold(let id, let onHold):
            CXSetHeldCallAction(call: id, onHold: onHold)
        case .mute(let id, let muted):
            CXSetMutedCallAction(call: id, muted: muted)
        }
        let transaction = CXTransaction(action: cxAction)
        try await callController.request(transaction)
    }
}
#endif
