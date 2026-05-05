import Foundation

#if canImport(CoreBluetooth)
import CoreBluetooth

// MARK: - Bluetooth Client

/// A client that wraps CoreBluetooth for BLE peripheral scanning, connection,
/// service discovery, and characteristic read/write/notify operations.
///
/// Designed as an `@Observable` class so SwiftUI views can react to state changes:
///
/// ```swift
/// let bluetooth = PrismBluetoothClient()
///
/// // Observe state
/// if bluetooth.state == .poweredOn {
///     bluetooth.startScanning(serviceUUIDs: nil)
/// }
///
/// // Connect to a discovered peripheral
/// if let peripheral = bluetooth.discoveredPeripherals.first {
///     try await bluetooth.connect(peripheral: peripheral)
///     let services = try await bluetooth.discoverServices(peripheral: peripheral)
/// }
/// ```
@MainActor
@Observable
public final class PrismBluetoothClient: NSObject {
    /// The current state of the Bluetooth radio.
    public private(set) var state: PrismBluetoothState = .unknown
    /// Peripherals discovered during the current or most recent scan.
    public private(set) var discoveredPeripherals: [PrismPeripheral] = []
    /// The peripheral that is currently connected, if any.
    public private(set) var connectedPeripheral: PrismPeripheral? = nil

    private var centralManager: CBCentralManager!
    private var delegate: BluetoothDelegate!
    private var cbPeripherals: [UUID: CBPeripheral] = [:]

    /// Creates a new Bluetooth client and initializes the central manager.
    public override init() {
        super.init()
        delegate = BluetoothDelegate(client: self)
        centralManager = CBCentralManager(delegate: delegate, queue: .main)
    }

    /// Begins scanning for peripherals advertising the given service UUIDs.
    ///
    /// Pass `nil` to discover all nearby peripherals (not recommended for production).
    /// - Parameter serviceUUIDs: Optional array of service UUID strings to filter by.
    public func startScanning(serviceUUIDs: [String]? = nil) {
        let cbuuids = serviceUUIDs?.map { CBUUID(string: $0) }
        discoveredPeripherals = []
        cbPeripherals = [:]
        centralManager.scanForPeripherals(withServices: cbuuids)
    }

    /// Stops the current peripheral scan.
    public func stopScanning() {
        centralManager.stopScan()
    }

    /// Connects to the specified peripheral.
    ///
    /// - Parameter peripheral: The peripheral to connect to, previously discovered via scanning.
    /// - Throws: An error if the connection fails or the peripheral is unknown.
    public func connect(peripheral: PrismPeripheral) async throws {
        guard let cbPeripheral = cbPeripherals[peripheral.id] else {
            throw BluetoothError.peripheralNotFound
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            delegate.connectContinuation = continuation
            centralManager.connect(cbPeripheral)
        }
        connectedPeripheral = PrismPeripheral(
            id: peripheral.id,
            name: peripheral.name,
            rssi: peripheral.rssi,
            isConnected: true
        )
    }

    /// Disconnects from the specified peripheral.
    ///
    /// - Parameter peripheral: The peripheral to disconnect from.
    public func disconnect(peripheral: PrismPeripheral) {
        guard let cbPeripheral = cbPeripherals[peripheral.id] else { return }
        centralManager.cancelPeripheralConnection(cbPeripheral)
        if connectedPeripheral?.id == peripheral.id {
            connectedPeripheral = nil
        }
    }

    /// Discovers all GATT services on the specified peripheral.
    ///
    /// - Parameter peripheral: The connected peripheral to query.
    /// - Returns: An array of discovered services with their characteristics.
    /// - Throws: An error if service discovery fails.
    public func discoverServices(peripheral: PrismPeripheral) async throws -> [PrismBLEService] {
        guard let cbPeripheral = cbPeripherals[peripheral.id] else {
            throw BluetoothError.peripheralNotFound
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PrismBLEService], Error>) in
            delegate.servicesContinuation = continuation
            cbPeripheral.delegate = delegate
            cbPeripheral.discoverServices(nil)
        }
    }

    /// Reads the current value of a characteristic.
    ///
    /// - Parameters:
    ///   - id: The UUID string of the characteristic to read.
    ///   - serviceID: The UUID string of the service containing the characteristic.
    /// - Returns: The characteristic value, or `nil` if unavailable.
    /// - Throws: An error if the read operation fails.
    public func readCharacteristic(id: String, serviceID: String) async throws -> Data? {
        guard let cbPeripheral = connectedCBPeripheral else {
            throw BluetoothError.notConnected
        }
        guard let characteristic = findCharacteristic(id: id, serviceID: serviceID, on: cbPeripheral) else {
            throw BluetoothError.characteristicNotFound
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data?, Error>) in
            delegate.readContinuation = continuation
            cbPeripheral.readValue(for: characteristic)
        }
    }

    /// Writes a value to the specified characteristic.
    ///
    /// - Parameters:
    ///   - id: The UUID string of the characteristic to write to.
    ///   - serviceID: The UUID string of the service containing the characteristic.
    ///   - value: The data to write.
    /// - Throws: An error if the write operation fails.
    public func writeCharacteristic(id: String, serviceID: String, value: Data) async throws {
        guard let cbPeripheral = connectedCBPeripheral else {
            throw BluetoothError.notConnected
        }
        guard let characteristic = findCharacteristic(id: id, serviceID: serviceID, on: cbPeripheral) else {
            throw BluetoothError.characteristicNotFound
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            delegate.writeContinuation = continuation
            cbPeripheral.writeValue(value, for: characteristic, type: .withResponse)
        }
    }

    /// Enables or disables notifications for the specified characteristic.
    ///
    /// - Parameters:
    ///   - enabled: Whether to enable or disable notifications.
    ///   - characteristicID: The UUID string of the characteristic.
    ///   - serviceID: The UUID string of the service containing the characteristic.
    /// - Throws: An error if the operation fails.
    public func setNotify(enabled: Bool, characteristicID: String, serviceID: String) async throws {
        guard let cbPeripheral = connectedCBPeripheral else {
            throw BluetoothError.notConnected
        }
        guard let characteristic = findCharacteristic(id: characteristicID, serviceID: serviceID, on: cbPeripheral) else {
            throw BluetoothError.characteristicNotFound
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            delegate.notifyContinuation = continuation
            cbPeripheral.setNotifyValue(enabled, for: characteristic)
        }
    }

    // MARK: - Internal Helpers

    package func updateState(_ cbState: CBManagerState) {
        state = switch cbState {
        case .unknown: .unknown
        case .resetting: .resetting
        case .unsupported: .unsupported
        case .unauthorized: .unauthorized
        case .poweredOff: .poweredOff
        case .poweredOn: .poweredOn
        @unknown default: .unknown
        }
    }

    package func addDiscoveredPeripheral(_ cbPeripheral: CBPeripheral, rssi: NSNumber) {
        let id = cbPeripheral.identifier
        cbPeripherals[id] = cbPeripheral
        let peripheral = PrismPeripheral(
            id: id,
            name: cbPeripheral.name,
            rssi: rssi.intValue,
            isConnected: false
        )
        if !discoveredPeripherals.contains(where: { $0.id == id }) {
            discoveredPeripherals.append(peripheral)
        }
    }

    private var connectedCBPeripheral: CBPeripheral? {
        guard let id = connectedPeripheral?.id else { return nil }
        return cbPeripherals[id]
    }

    private func findCharacteristic(id: String, serviceID: String, on peripheral: CBPeripheral) -> CBCharacteristic? {
        let serviceUUID = CBUUID(string: serviceID)
        let charUUID = CBUUID(string: id)
        return peripheral.services?
            .first(where: { $0.uuid == serviceUUID })?
            .characteristics?
            .first(where: { $0.uuid == charUUID })
    }
}
#endif
