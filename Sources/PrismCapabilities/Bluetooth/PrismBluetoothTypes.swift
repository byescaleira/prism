import Foundation

// MARK: - Bluetooth State

/// Represents the current state of the Bluetooth radio on the device.
///
/// Maps directly to `CBManagerState` for consistent state tracking across
/// the CoreBluetooth lifecycle.
public enum PrismBluetoothState: Sendable, CaseIterable {
    /// The Bluetooth state is unknown.
    case unknown
    /// The Bluetooth connection was momentarily lost and is resetting.
    case resetting
    /// The device does not support Bluetooth Low Energy.
    case unsupported
    /// The app is not authorized to use Bluetooth.
    case unauthorized
    /// Bluetooth is currently powered off.
    case poweredOff
    /// Bluetooth is powered on and ready.
    case poweredOn
}

// MARK: - Peripheral

/// A discovered or connected BLE peripheral with basic metadata.
///
/// ```swift
/// let peripheral = PrismPeripheral(
///     id: UUID(),
///     name: "Heart Rate Sensor",
///     rssi: -45,
///     isConnected: false
/// )
/// ```
public struct PrismPeripheral: Sendable {
    /// The unique identifier for this peripheral.
    public let id: UUID
    /// The advertised local name, if available.
    public let name: String?
    /// The received signal strength indicator in dBm, if available.
    public let rssi: Int?
    /// Whether the peripheral is currently connected.
    public let isConnected: Bool

    /// Creates a new peripheral descriptor with the given identity and metadata.
    public init(id: UUID, name: String? = nil, rssi: Int? = nil, isConnected: Bool = false) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.isConnected = isConnected
    }
}

// MARK: - BLE Service

/// A GATT service discovered on a connected peripheral.
public struct PrismBLEService: Sendable {
    /// The UUID string identifying this service.
    public let id: String
    /// The human-readable service name, if known.
    public let name: String?
    /// The characteristics belonging to this service.
    public let characteristics: [PrismBLECharacteristic]

    /// Creates a new BLE service with the given identifier and characteristics.
    public init(id: String, name: String? = nil, characteristics: [PrismBLECharacteristic] = []) {
        self.id = id
        self.name = name
        self.characteristics = characteristics
    }
}

// MARK: - BLE Characteristic

/// A GATT characteristic within a service, including its current value and notification state.
public struct PrismBLECharacteristic: Sendable {
    /// The UUID string identifying this characteristic.
    public let id: String
    /// The last-read value of the characteristic.
    public let value: Data?
    /// Whether notifications are currently enabled for this characteristic.
    public let isNotifying: Bool
    /// The supported properties (read, write, notify, etc.).
    public let properties: PrismCharacteristicProperties

    /// Creates a new BLE characteristic with the given identifier and properties.
    public init(
        id: String, value: Data? = nil, isNotifying: Bool = false, properties: PrismCharacteristicProperties = []
    ) {
        self.id = id
        self.value = value
        self.isNotifying = isNotifying
        self.properties = properties
    }
}

// MARK: - Characteristic Properties

/// An option set describing the capabilities of a BLE characteristic.
///
/// Mirrors `CBCharacteristicProperties` for a framework-agnostic API surface.
public struct PrismCharacteristicProperties: OptionSet, Sendable {
    /// The raw bitmask value for this set of properties.
    public let rawValue: UInt

    /// Creates a characteristic properties set from a raw bitmask value.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// The characteristic supports reading its value.
    public static let read = PrismCharacteristicProperties(rawValue: 1 << 0)
    /// The characteristic supports writing its value with a response.
    public static let write = PrismCharacteristicProperties(rawValue: 1 << 1)
    /// The characteristic supports writing its value without a response.
    public static let writeWithoutResponse = PrismCharacteristicProperties(rawValue: 1 << 2)
    /// The characteristic supports notifications.
    public static let notify = PrismCharacteristicProperties(rawValue: 1 << 3)
    /// The characteristic supports indications.
    public static let indicate = PrismCharacteristicProperties(rawValue: 1 << 4)
}
