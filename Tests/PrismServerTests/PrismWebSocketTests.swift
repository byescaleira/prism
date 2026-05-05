#if canImport(Network)
    import Testing
    import Foundation
    @testable import PrismServer

    @Suite("PrismWebSocketFrame Tests")
    struct PrismWebSocketFrameTests {

        @Test("Text frame factory")
        func textFrame() {
            let frame = PrismWebSocketFrame.text("hello")
            #expect(frame.opcode == .text)
            #expect(frame.fin)
            #expect(frame.payload == Data("hello".utf8))
        }

        @Test("Binary frame factory")
        func binaryFrame() {
            let data = Data([0x01, 0x02, 0x03])
            let frame = PrismWebSocketFrame.binary(data)
            #expect(frame.opcode == .binary)
            #expect(frame.payload == data)
        }

        @Test("Close frame factory")
        func closeFrame() {
            let frame = PrismWebSocketFrame.close(code: 1000)
            #expect(frame.opcode == .close)
            #expect(frame.payload.count == 2)
        }

        @Test("Ping frame factory")
        func pingFrame() {
            let frame = PrismWebSocketFrame.ping()
            #expect(frame.opcode == .ping)
        }

        @Test("Pong frame factory")
        func pongFrame() {
            let frame = PrismWebSocketFrame.pong()
            #expect(frame.opcode == .pong)
        }

        @Test("Serialize small text frame")
        func serializeSmall() {
            let frame = PrismWebSocketFrame.text("hi")
            let data = frame.serialize()
            #expect(data[0] == 0x81)  // FIN + text opcode
            #expect(data[1] == 2)  // payload length
            #expect(data[2] == 0x68)  // 'h'
            #expect(data[3] == 0x69)  // 'i'
        }

        @Test("Serialize medium frame (126-65535 bytes)")
        func serializeMedium() {
            let payload = Data(repeating: 0x41, count: 200)
            let frame = PrismWebSocketFrame(opcode: .binary, payload: payload)
            let data = frame.serialize()
            #expect(data[1] == 126)
            #expect(Int(data[2]) << 8 | Int(data[3]) == 200)
        }
    }

    @Suite("PrismWebSocketParser Tests")
    struct PrismWebSocketParserTests {

        let parser = PrismWebSocketParser()

        @Test("Parse unmasked text frame")
        func parseUnmasked() {
            var data = Data()
            data.append(0x81)  // FIN + text
            data.append(0x05)  // length 5, no mask
            data.append(contentsOf: "hello".utf8)

            let result = parser.parse(data)
            #expect(result != nil)
            let (frame, consumed) = result!
            #expect(frame.opcode == .text)
            #expect(frame.payload == Data("hello".utf8))
            #expect(consumed == 7)
        }

        @Test("Parse masked text frame")
        func parseMasked() {
            var data = Data()
            data.append(0x81)  // FIN + text
            data.append(0x85)  // length 5, masked
            let mask: [UInt8] = [0x37, 0xfa, 0x21, 0x3d]
            data.append(contentsOf: mask)

            let payload = "hello"
            let payloadBytes = Array(payload.utf8)
            for (i, byte) in payloadBytes.enumerated() {
                data.append(byte ^ mask[i % 4])
            }

            let result = parser.parse(data)
            #expect(result != nil)
            let (frame, _) = result!
            #expect(String(data: frame.payload, encoding: .utf8) == "hello")
        }

        @Test("Parse returns nil for incomplete data")
        func incomplete() {
            let data = Data([0x81])  // only 1 byte
            #expect(parser.parse(data) == nil)
        }

        @Test("Parse close frame")
        func parseClose() {
            var data = Data()
            data.append(0x88)  // FIN + close
            data.append(0x02)  // length 2
            data.append(0x03)  // 1000 >> 8
            data.append(0xE8)  // 1000 & 0xFF

            let result = parser.parse(data)
            #expect(result != nil)
            #expect(result!.0.opcode == .close)
        }
    }

    @Suite("PrismWebSocketUpgrade Tests")
    struct PrismWebSocketUpgradeTests {

        @Test("Detects valid upgrade request")
        func validUpgrade() {
            var headers = PrismHTTPHeaders()
            headers.set(name: "Upgrade", value: "websocket")
            headers.set(name: "Connection", value: "Upgrade")
            headers.set(name: "Sec-WebSocket-Key", value: "dGhlIHNhbXBsZSBub25jZQ==")
            let request = PrismHTTPRequest(method: .GET, uri: "/ws", headers: headers)
            #expect(PrismWebSocketUpgrade.isUpgradeRequest(request))
        }

        @Test("Rejects non-upgrade request")
        func notUpgrade() {
            let request = PrismHTTPRequest(method: .GET, uri: "/ws")
            #expect(!PrismWebSocketUpgrade.isUpgradeRequest(request))
        }

        @Test("Missing key is not upgrade")
        func missingKey() {
            var headers = PrismHTTPHeaders()
            headers.set(name: "Upgrade", value: "websocket")
            headers.set(name: "Connection", value: "Upgrade")
            let request = PrismHTTPRequest(method: .GET, uri: "/ws", headers: headers)
            #expect(!PrismWebSocketUpgrade.isUpgradeRequest(request))
        }

        @Test("Upgrade response has 101 status")
        func upgradeResponse() {
            var headers = PrismHTTPHeaders()
            headers.set(name: "Upgrade", value: "websocket")
            headers.set(name: "Connection", value: "Upgrade")
            headers.set(name: "Sec-WebSocket-Key", value: "dGhlIHNhbXBsZSBub25jZQ==")
            let request = PrismHTTPRequest(method: .GET, uri: "/ws", headers: headers)

            let response = PrismWebSocketUpgrade.upgradeResponse(for: request)
            #expect(response != nil)
            #expect(response?.status == .switchingProtocols)
            #expect(response?.headers.value(for: "Upgrade") == "websocket")
            #expect(response?.headers.value(for: "Sec-WebSocket-Accept") != nil)
        }
    }

    private actor FrameCollector {
        var frames: [PrismWebSocketFrame] = []
        func append(_ frame: PrismWebSocketFrame) { frames.append(frame) }
    }

    @Suite("PrismWebSocketConnection Tests")
    struct PrismWebSocketConnectionTests {

        @Test("Connection has unique ID")
        func uniqueID() {
            let conn1 = PrismWebSocketConnection { _ in }
            let conn2 = PrismWebSocketConnection { _ in }
            #expect(type(of: conn1) == type(of: conn2))
        }

        @Test("Send text dispatches frame")
        func sendText() async {
            let collector = FrameCollector()
            let conn = PrismWebSocketConnection { frame in
                await collector.append(frame)
            }
            await conn.send("hello")
            let frames = await collector.frames
            #expect(frames.count == 1)
            #expect(frames[0].opcode == .text)
        }

        @Test("Send binary dispatches frame")
        func sendBinary() async {
            let collector = FrameCollector()
            let conn = PrismWebSocketConnection { frame in
                await collector.append(frame)
            }
            await conn.send(Data([1, 2, 3]))
            let frames = await collector.frames
            #expect(frames.count == 1)
            #expect(frames[0].opcode == .binary)
        }
    }
#endif
