import Foundation

#if canImport(CoreBluetooth)
    import CoreBluetooth

    // MARK: - Bluetooth Errors

    /// Errors that can occur during Bluetooth operations.
    package enum BluetoothError: Error, Sendable {
        case peripheralNotFound
        case notConnected
        case characteristicNotFound
    }

    // MARK: - Bluetooth Delegate

    /// Internal delegate that bridges CoreBluetooth callbacks to the PrismBluetoothClient.
    ///
    /// Uses continuations to convert delegate-based APIs into async/await calls.
    package final class BluetoothDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, @unchecked Sendable
    {
        package weak var client: PrismBluetoothClient?

        package var connectContinuation: CheckedContinuation<Void, Error>?
        package var servicesContinuation: CheckedContinuation<[PrismBLEService], Error>?
        package var readContinuation: CheckedContinuation<Data?, Error>?
        package var writeContinuation: CheckedContinuation<Void, Error>?
        package var notifyContinuation: CheckedContinuation<Void, Error>?

        package init(client: PrismBluetoothClient) {
            self.client = client
        }

        // MARK: CBCentralManagerDelegate

        package func centralManagerDidUpdateState(_ central: CBCentralManager) {
            let state = central.state
            Task { @MainActor in
                self.client?.updateState(state)
            }
        }

        package func centralManager(
            _ central: CBCentralManager,
            didDiscover peripheral: CBPeripheral,
            advertisementData: [String: Any],
            rssi RSSI: NSNumber
        ) {
            nonisolated(unsafe) let p = peripheral
            let rssi = RSSI
            Task { @MainActor in
                self.client?.addDiscoveredPeripheral(p, rssi: rssi)
            }
        }

        package func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            Task { @MainActor in
                self.connectContinuation?.resume()
                self.connectContinuation = nil
            }
        }

        package func centralManager(
            _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
        ) {
            let err = error
            Task { @MainActor in
                self.connectContinuation?.resume(throwing: err ?? BluetoothError.peripheralNotFound)
                self.connectContinuation = nil
            }
        }

        // MARK: CBPeripheralDelegate

        package func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            nonisolated(unsafe) let p = peripheral
            let err = error
            Task { @MainActor in
                if let err {
                    self.servicesContinuation?.resume(throwing: err)
                    self.servicesContinuation = nil
                    return
                }
                let services = p.services ?? []
                if services.isEmpty {
                    self.servicesContinuation?.resume(returning: [])
                    self.servicesContinuation = nil
                    return
                }
                for service in services {
                    p.discoverCharacteristics(nil, for: service)
                }
            }
        }

        package func peripheral(
            _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
        ) {
            nonisolated(unsafe) let p = peripheral
            let err = error
            Task { @MainActor in
                if let err {
                    self.servicesContinuation?.resume(throwing: err)
                    self.servicesContinuation = nil
                    return
                }
                let allServices = p.services ?? []
                let allDiscovered = allServices.allSatisfy { $0.characteristics != nil }
                guard allDiscovered else { return }

                let prismServices = allServices.map { service in
                    let chars = (service.characteristics ?? []).map { char in
                        PrismBLECharacteristic(
                            id: char.uuid.uuidString,
                            value: char.value,
                            isNotifying: char.isNotifying,
                            properties: PrismCharacteristicProperties(cbProperties: char.properties)
                        )
                    }
                    return PrismBLEService(
                        id: service.uuid.uuidString,
                        name: nil,
                        characteristics: chars
                    )
                }
                self.servicesContinuation?.resume(returning: prismServices)
                self.servicesContinuation = nil
            }
        }

        package func peripheral(
            _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?
        ) {
            let value = characteristic.value
            let err = error
            Task { @MainActor in
                if let err {
                    self.readContinuation?.resume(throwing: err)
                } else {
                    self.readContinuation?.resume(returning: value)
                }
                self.readContinuation = nil
            }
        }

        package func peripheral(
            _ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?
        ) {
            let err = error
            Task { @MainActor in
                if let err {
                    self.writeContinuation?.resume(throwing: err)
                } else {
                    self.writeContinuation?.resume()
                }
                self.writeContinuation = nil
            }
        }

        package func peripheral(
            _ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?
        ) {
            let err = error
            Task { @MainActor in
                if let err {
                    self.notifyContinuation?.resume(throwing: err)
                } else {
                    self.notifyContinuation?.resume()
                }
                self.notifyContinuation = nil
            }
        }
    }

    // MARK: - Private Extensions

    extension PrismCharacteristicProperties {
        package init(cbProperties: CBCharacteristicProperties) {
            var props = PrismCharacteristicProperties()
            if cbProperties.contains(.read) { props.insert(.read) }
            if cbProperties.contains(.write) { props.insert(.write) }
            if cbProperties.contains(.writeWithoutResponse) { props.insert(.writeWithoutResponse) }
            if cbProperties.contains(.notify) { props.insert(.notify) }
            if cbProperties.contains(.indicate) { props.insert(.indicate) }
            self = props
        }
    }
#endif
