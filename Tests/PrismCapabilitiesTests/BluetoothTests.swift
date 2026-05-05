import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - Bluetooth State Tests

@Suite("PrismBluetoothState")
struct PrismBluetoothStateTests {

    @Test("PrismBluetoothState has 6 cases")
    func stateCaseCount() {
        #expect(PrismBluetoothState.allCases.count == 6)
    }

    @Test("PrismBluetoothState includes all expected cases")
    func stateCases() {
        let cases = PrismBluetoothState.allCases
        #expect(cases.contains(.unknown))
        #expect(cases.contains(.resetting))
        #expect(cases.contains(.unsupported))
        #expect(cases.contains(.unauthorized))
        #expect(cases.contains(.poweredOff))
        #expect(cases.contains(.poweredOn))
    }
}

// MARK: - Peripheral Tests

@Suite("PrismPeripheral")
struct PrismPeripheralTests {

    @Test("PrismPeripheral stores properties correctly")
    func peripheralProperties() {
        let id = UUID()
        let peripheral = PrismPeripheral(
            id: id,
            name: "Heart Rate Sensor",
            rssi: -45,
            isConnected: true
        )
        #expect(peripheral.id == id)
        #expect(peripheral.name == "Heart Rate Sensor")
        #expect(peripheral.rssi == -45)
        #expect(peripheral.isConnected == true)
    }

    @Test("PrismPeripheral has sensible defaults")
    func peripheralDefaults() {
        let id = UUID()
        let peripheral = PrismPeripheral(id: id)
        #expect(peripheral.id == id)
        #expect(peripheral.name == nil)
        #expect(peripheral.rssi == nil)
        #expect(peripheral.isConnected == false)
    }

    @Test("PrismPeripheral with nil name and negative RSSI")
    func peripheralNilNameNegativeRSSI() {
        let peripheral = PrismPeripheral(id: UUID(), name: nil, rssi: -100, isConnected: false)
        #expect(peripheral.name == nil)
        #expect(peripheral.rssi == -100)
    }
}

// MARK: - BLE Service Tests

@Suite("PrismBLEService")
struct PrismBLEServiceTests {

    @Test("PrismBLEService stores properties correctly")
    func serviceProperties() {
        let char = PrismBLECharacteristic(id: "2A37", value: Data([0x01]), isNotifying: true, properties: .notify)
        let service = PrismBLEService(
            id: "180D",
            name: "Heart Rate",
            characteristics: [char]
        )
        #expect(service.id == "180D")
        #expect(service.name == "Heart Rate")
        #expect(service.characteristics.count == 1)
        #expect(service.characteristics.first?.id == "2A37")
    }

    @Test("PrismBLEService has sensible defaults")
    func serviceDefaults() {
        let service = PrismBLEService(id: "180F")
        #expect(service.id == "180F")
        #expect(service.name == nil)
        #expect(service.characteristics.isEmpty)
    }
}

// MARK: - BLE Characteristic Tests

@Suite("PrismBLECharacteristic")
struct PrismBLECharacteristicTests {

    @Test("PrismBLECharacteristic stores properties correctly")
    func characteristicProperties() {
        let data = Data([0xAB, 0xCD])
        let props: PrismCharacteristicProperties = [.read, .write]
        let char = PrismBLECharacteristic(
            id: "2A19",
            value: data,
            isNotifying: false,
            properties: props
        )
        #expect(char.id == "2A19")
        #expect(char.value == data)
        #expect(char.isNotifying == false)
        #expect(char.properties.contains(.read))
        #expect(char.properties.contains(.write))
    }

    @Test("PrismBLECharacteristic has sensible defaults")
    func characteristicDefaults() {
        let char = PrismBLECharacteristic(id: "2A29")
        #expect(char.id == "2A29")
        #expect(char.value == nil)
        #expect(char.isNotifying == false)
        #expect(char.properties.isEmpty)
    }
}

// MARK: - Characteristic Properties Tests

@Suite("PrismCharacteristicProperties")
struct PrismCharacteristicPropertiesTests {

    @Test("PrismCharacteristicProperties contains individual flags")
    func individualFlags() {
        #expect(PrismCharacteristicProperties.read.rawValue == 1)
        #expect(PrismCharacteristicProperties.write.rawValue == 2)
        #expect(PrismCharacteristicProperties.writeWithoutResponse.rawValue == 4)
        #expect(PrismCharacteristicProperties.notify.rawValue == 8)
        #expect(PrismCharacteristicProperties.indicate.rawValue == 16)
    }

    @Test("PrismCharacteristicProperties supports combination")
    func combinedFlags() {
        let props: PrismCharacteristicProperties = [.read, .notify]
        #expect(props.contains(.read))
        #expect(props.contains(.notify))
        #expect(!props.contains(.write))
        #expect(!props.contains(.indicate))
    }

    @Test("PrismCharacteristicProperties rawValue matches expected bitmask")
    func rawValueBitmask() {
        let props: PrismCharacteristicProperties = [.read, .write, .notify]
        #expect(props.rawValue == 1 | 2 | 8)
    }

    @Test("PrismCharacteristicProperties empty set")
    func emptySet() {
        let props = PrismCharacteristicProperties()
        #expect(props.rawValue == 0)
        #expect(!props.contains(.read))
        #expect(!props.contains(.write))
    }

    @Test("PrismCharacteristicProperties all flags combined")
    func allFlags() {
        let props: PrismCharacteristicProperties = [.read, .write, .writeWithoutResponse, .notify, .indicate]
        #expect(props.contains(.read))
        #expect(props.contains(.write))
        #expect(props.contains(.writeWithoutResponse))
        #expect(props.contains(.notify))
        #expect(props.contains(.indicate))
        #expect(props.rawValue == 1 | 2 | 4 | 8 | 16)
    }
}
