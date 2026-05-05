import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - CallKit Tests

@Suite("PrismCallKit")
struct PrismCallKitTests {

    @Test("PrismCallType has 3 cases")
    func callTypeCaseCount() {
        let types: [PrismCallType] = [.generic, .audio, .video]
        #expect(types.count == 3)
    }

    @Test("PrismCallType includes all expected cases")
    func callTypeCases() {
        let generic = PrismCallType.generic
        let audio = PrismCallType.audio
        let video = PrismCallType.video
        if case .generic = generic {} else { #expect(Bool(false), "Expected generic") }
        if case .audio = audio {} else { #expect(Bool(false), "Expected audio") }
        if case .video = video {} else { #expect(Bool(false), "Expected video") }
    }

    @Test("PrismCallEndReason has 5 cases")
    func callEndReasonCaseCount() {
        #expect(PrismCallEndReason.allCases.count == 5)
    }

    @Test("PrismCallEndReason includes all expected cases")
    func callEndReasonCases() {
        let cases = PrismCallEndReason.allCases
        #expect(cases.contains(.failed))
        #expect(cases.contains(.remoteEnded))
        #expect(cases.contains(.unanswered))
        #expect(cases.contains(.answeredElsewhere))
        #expect(cases.contains(.declinedElsewhere))
    }

    @Test("PrismCallInfo stores properties correctly")
    func callInfoProperties() {
        let id = UUID()
        let info = PrismCallInfo(
            id: id,
            handle: "+15551234567",
            displayName: "John Doe",
            type: .video,
            isOutgoing: true,
            hasVideo: true
        )
        #expect(info.id == id)
        #expect(info.handle == "+15551234567")
        #expect(info.displayName == "John Doe")
        #expect(info.type == .video)
        #expect(info.isOutgoing == true)
        #expect(info.hasVideo == true)
    }

    @Test("PrismCallInfo defaults")
    func callInfoDefaults() {
        let info = PrismCallInfo(handle: "+15559876543")
        #expect(info.handle == "+15559876543")
        #expect(info.displayName == nil)
        #expect(info.type == .audio)
        #expect(info.isOutgoing == false)
        #expect(info.hasVideo == false)
    }

    @Test("PrismBlockedCaller stores properties correctly")
    func blockedCallerProperties() {
        let blocked = PrismBlockedCaller(phoneNumber: "+15550001111", label: "Spam")
        #expect(blocked.phoneNumber == "+15550001111")
        #expect(blocked.label == "Spam")
    }

    @Test("PrismBlockedCaller defaults")
    func blockedCallerDefaults() {
        let blocked = PrismBlockedCaller(phoneNumber: "+15550002222")
        #expect(blocked.phoneNumber == "+15550002222")
        #expect(blocked.label == nil)
    }

    @Test("PrismCallAction start case")
    func callActionStart() {
        let info = PrismCallInfo(handle: "+15551112222", displayName: "Alice")
        let action = PrismCallAction.start(info)
        if case .start(let callInfo) = action {
            #expect(callInfo.handle == "+15551112222")
            #expect(callInfo.displayName == "Alice")
        } else {
            #expect(Bool(false), "Expected start action")
        }
    }

    @Test("PrismCallAction answer case")
    func callActionAnswer() {
        let id = UUID()
        let action = PrismCallAction.answer(id)
        if case .answer(let callID) = action {
            #expect(callID == id)
        } else {
            #expect(Bool(false), "Expected answer action")
        }
    }

    @Test("PrismCallAction end case")
    func callActionEnd() {
        let id = UUID()
        let action = PrismCallAction.end(id)
        if case .end(let callID) = action {
            #expect(callID == id)
        } else {
            #expect(Bool(false), "Expected end action")
        }
    }

    @Test("PrismCallAction hold case")
    func callActionHold() {
        let id = UUID()
        let action = PrismCallAction.hold(id, true)
        if case .hold(let callID, let onHold) = action {
            #expect(callID == id)
            #expect(onHold == true)
        } else {
            #expect(Bool(false), "Expected hold action")
        }
    }

    @Test("PrismCallAction mute case")
    func callActionMute() {
        let id = UUID()
        let action = PrismCallAction.mute(id, false)
        if case .mute(let callID, let muted) = action {
            #expect(callID == id)
            #expect(muted == false)
        } else {
            #expect(Bool(false), "Expected mute action")
        }
    }

    @Test("PrismCallInfo generates unique IDs by default")
    func callInfoUniqueIDs() {
        let info1 = PrismCallInfo(handle: "+15550000000")
        let info2 = PrismCallInfo(handle: "+15550000000")
        #expect(info1.id != info2.id)
    }
}
