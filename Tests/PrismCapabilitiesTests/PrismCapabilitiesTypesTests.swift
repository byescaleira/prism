import Testing
@testable import PrismCapabilities
import Foundation

// MARK: - Bluetooth Types Tests

#if canImport(CoreBluetooth)

@Suite("PrismBluetoothState")
struct PrismBluetoothStateTypesTests {

    @Test("has 6 cases and is CaseIterable")
    func caseCount() {
        #expect(PrismBluetoothState.allCases.count == 6)
    }

    @Test("includes all expected cases")
    func allCases() {
        let cases = PrismBluetoothState.allCases
        #expect(cases.contains(.unknown))
        #expect(cases.contains(.resetting))
        #expect(cases.contains(.unsupported))
        #expect(cases.contains(.unauthorized))
        #expect(cases.contains(.poweredOff))
        #expect(cases.contains(.poweredOn))
    }
}

@Suite("PrismPeripheral")
struct PrismPeripheralTypesTests {

    @Test("init stores id, name, rssi, isConnected")
    func storedProperties() {
        let id = UUID()
        let peripheral = PrismPeripheral(
            id: id,
            name: "Sensor",
            rssi: -55,
            isConnected: true
        )
        #expect(peripheral.id == id)
        #expect(peripheral.name == "Sensor")
        #expect(peripheral.rssi == -55)
        #expect(peripheral.isConnected == true)
    }

    @Test("defaults: name=nil, rssi=nil, isConnected=false")
    func defaults() {
        let id = UUID()
        let peripheral = PrismPeripheral(id: id)
        #expect(peripheral.id == id)
        #expect(peripheral.name == nil)
        #expect(peripheral.rssi == nil)
        #expect(peripheral.isConnected == false)
    }
}

@Suite("PrismBLEService")
struct PrismBLEServiceTypesTests {

    @Test("init stores id, name, characteristics")
    func storedProperties() {
        let char = PrismBLECharacteristic(id: "2A37")
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

    @Test("defaults: name=nil, characteristics=[]")
    func defaults() {
        let service = PrismBLEService(id: "180F")
        #expect(service.id == "180F")
        #expect(service.name == nil)
        #expect(service.characteristics.isEmpty)
    }
}

@Suite("PrismBLECharacteristic")
struct PrismBLECharacteristicTypesTests {

    @Test("init stores id, value, isNotifying, properties")
    func storedProperties() {
        let data = Data([0xAB, 0xCD])
        let props: PrismCharacteristicProperties = [.read, .notify]
        let char = PrismBLECharacteristic(
            id: "2A19",
            value: data,
            isNotifying: true,
            properties: props
        )
        #expect(char.id == "2A19")
        #expect(char.value == data)
        #expect(char.isNotifying == true)
        #expect(char.properties.contains(.read))
        #expect(char.properties.contains(.notify))
    }

    @Test("defaults: value=nil, isNotifying=false, properties=[]")
    func defaults() {
        let char = PrismBLECharacteristic(id: "2A29")
        #expect(char.id == "2A29")
        #expect(char.value == nil)
        #expect(char.isNotifying == false)
        #expect(char.properties.isEmpty)
    }
}

@Suite("PrismCharacteristicProperties")
struct PrismCharacteristicPropertiesTypesTests {

    @Test(".read, .write, .writeWithoutResponse, .notify, .indicate exist")
    func individualFlags() {
        #expect(PrismCharacteristicProperties.read.rawValue == 1 << 0)
        #expect(PrismCharacteristicProperties.write.rawValue == 1 << 1)
        #expect(PrismCharacteristicProperties.writeWithoutResponse.rawValue == 1 << 2)
        #expect(PrismCharacteristicProperties.notify.rawValue == 1 << 3)
        #expect(PrismCharacteristicProperties.indicate.rawValue == 1 << 4)
    }

    @Test("combination works: [.read, .write].contains(.read)")
    func combination() {
        let props: PrismCharacteristicProperties = [.read, .write]
        #expect(props.contains(.read))
        #expect(props.contains(.write))
        #expect(!props.contains(.notify))
    }

    @Test("empty set has rawValue 0")
    func emptySet() {
        let props = PrismCharacteristicProperties()
        #expect(props.rawValue == 0)
        #expect(!props.contains(.read))
    }
}

#endif

// MARK: - Motion Types Tests

#if canImport(CoreMotion)

@Suite("PrismAccelerometerData")
struct PrismAccelerometerDataTypesTests {

    @Test("init stores x, y, z, timestamp")
    func storedProperties() {
        let now = Date()
        let data = PrismAccelerometerData(x: 0.1, y: -0.5, z: 9.8, timestamp: now)
        #expect(data.x == 0.1)
        #expect(data.y == -0.5)
        #expect(data.z == 9.8)
        #expect(data.timestamp == now)
    }
}

@Suite("PrismGyroscopeData")
struct PrismGyroscopeDataTypesTests {

    @Test("init stores x, y, z, timestamp")
    func storedProperties() {
        let now = Date()
        let data = PrismGyroscopeData(x: 1.2, y: -0.3, z: 0.7, timestamp: now)
        #expect(data.x == 1.2)
        #expect(data.y == -0.3)
        #expect(data.z == 0.7)
        #expect(data.timestamp == now)
    }
}

@Suite("PrismAttitude")
struct PrismAttitudeTypesTests {

    @Test("init stores roll, pitch, yaw")
    func storedProperties() {
        let attitude = PrismAttitude(roll: 0.5, pitch: -0.3, yaw: 1.57)
        #expect(attitude.roll == 0.5)
        #expect(attitude.pitch == -0.3)
        #expect(attitude.yaw == 1.57)
    }
}

@Suite("PrismDeviceMotion")
struct PrismDeviceMotionTypesTests {

    @Test("init stores attitude, rotationRate, gravity, userAcceleration")
    func storedProperties() {
        let now = Date()
        let attitude = PrismAttitude(roll: 0.1, pitch: 0.2, yaw: 0.3)
        let rotation = PrismGyroscopeData(x: 0.4, y: 0.5, z: 0.6, timestamp: now)
        let gravity = PrismAccelerometerData(x: 0.0, y: 0.0, z: -9.8, timestamp: now)
        let userAccel = PrismAccelerometerData(x: 0.1, y: -0.1, z: 0.0, timestamp: now)

        let motion = PrismDeviceMotion(
            attitude: attitude,
            rotationRate: rotation,
            gravity: gravity,
            userAcceleration: userAccel
        )

        #expect(motion.attitude.roll == 0.1)
        #expect(motion.attitude.pitch == 0.2)
        #expect(motion.attitude.yaw == 0.3)
        #expect(motion.rotationRate.x == 0.4)
        #expect(motion.gravity.z == -9.8)
        #expect(motion.userAcceleration.x == 0.1)
    }
}

@Suite("PrismPedometerData")
struct PrismPedometerDataTypesTests {

    @Test("init stores steps, distance, floorsAscended, floorsDescended, startDate, endDate")
    func storedProperties() {
        let start = Date()
        let end = start.addingTimeInterval(3600)
        let data = PrismPedometerData(
            steps: 5000,
            distance: 3200.5,
            floorsAscended: 3,
            floorsDescended: 1,
            startDate: start,
            endDate: end
        )
        #expect(data.steps == 5000)
        #expect(data.distance == 3200.5)
        #expect(data.floorsAscended == 3)
        #expect(data.floorsDescended == 1)
        #expect(data.startDate == start)
        #expect(data.endDate == end)
    }

    @Test("optionals default to nil")
    func defaults() {
        let start = Date()
        let end = start.addingTimeInterval(1800)
        let data = PrismPedometerData(steps: 100, startDate: start, endDate: end)
        #expect(data.steps == 100)
        #expect(data.distance == nil)
        #expect(data.floorsAscended == nil)
        #expect(data.floorsDescended == nil)
    }
}

@Suite("PrismActivityType")
struct PrismActivityTypeTypesTests {

    @Test("has 6 cases and is CaseIterable")
    func caseCount() {
        #expect(PrismActivityType.allCases.count == 6)
    }

    @Test("includes all expected cases")
    func allCases() {
        let cases = PrismActivityType.allCases
        #expect(cases.contains(.stationary))
        #expect(cases.contains(.walking))
        #expect(cases.contains(.running))
        #expect(cases.contains(.cycling))
        #expect(cases.contains(.automotive))
        #expect(cases.contains(.unknown))
    }
}

@Suite("PrismAltitudeData")
struct PrismAltitudeDataTypesTests {

    @Test("init stores relativeAltitude, pressure, timestamp")
    func storedProperties() {
        let now = Date()
        let data = PrismAltitudeData(relativeAltitude: 12.5, pressure: 101.3, timestamp: now)
        #expect(data.relativeAltitude == 12.5)
        #expect(data.pressure == 101.3)
        #expect(data.timestamp == now)
    }
}

#endif

// MARK: - Camera Types Tests

#if canImport(AVFoundation)

@Suite("PrismCameraPosition")
struct PrismCameraPositionTypesTests {

    @Test("has 3 cases and is CaseIterable")
    func caseCount() {
        #expect(PrismCameraPosition.allCases.count == 3)
    }

    @Test("includes front, back, external")
    func allCases() {
        let cases = PrismCameraPosition.allCases
        #expect(cases.contains(.front))
        #expect(cases.contains(.back))
        #expect(cases.contains(.external))
    }
}

@Suite("PrismCaptureMode")
struct PrismCaptureModeTypesTests {

    @Test("has photo and video cases")
    func cases() {
        let modes: [PrismCaptureMode] = [.photo, .video]
        #expect(modes.count == 2)
    }
}

@Suite("PrismFlashMode")
struct PrismFlashModeTypesTests {

    @Test("has 3 cases and is CaseIterable")
    func caseCount() {
        #expect(PrismFlashMode.allCases.count == 3)
    }

    @Test("includes off, on, auto")
    func allCases() {
        let cases = PrismFlashMode.allCases
        #expect(cases.contains(.off))
        #expect(cases.contains(.on))
        #expect(cases.contains(.auto))
    }
}

@Suite("PrismCameraPermission")
struct PrismCameraPermissionTypesTests {

    @Test("has 4 cases and is CaseIterable")
    func caseCount() {
        #expect(PrismCameraPermission.allCases.count == 4)
    }

    @Test("includes all expected cases")
    func allCases() {
        let cases = PrismCameraPermission.allCases
        #expect(cases.contains(.notDetermined))
        #expect(cases.contains(.restricted))
        #expect(cases.contains(.denied))
        #expect(cases.contains(.authorized))
    }
}

@Suite("PrismPhotoQuality")
struct PrismPhotoQualityTypesTests {

    @Test("has 4 cases and is CaseIterable")
    func caseCount() {
        #expect(PrismPhotoQuality.allCases.count == 4)
    }

    @Test("includes low, medium, high, maximum")
    func allCases() {
        let cases = PrismPhotoQuality.allCases
        #expect(cases.contains(.low))
        #expect(cases.contains(.medium))
        #expect(cases.contains(.high))
        #expect(cases.contains(.maximum))
    }
}

@Suite("PrismPhotoSettings")
struct PrismPhotoSettingsTypesTests {

    @Test("init stores flashMode, isHDREnabled, quality")
    func storedProperties() {
        let settings = PrismPhotoSettings(
            flashMode: .on,
            isHDREnabled: true,
            quality: .maximum
        )
        #expect(settings.flashMode == .on)
        #expect(settings.isHDREnabled == true)
        #expect(settings.quality == .maximum)
    }

    @Test("defaults: flashMode=.auto, isHDREnabled=false, quality=.high")
    func defaults() {
        let settings = PrismPhotoSettings()
        #expect(settings.flashMode == .auto)
        #expect(settings.isHDREnabled == false)
        #expect(settings.quality == .high)
    }
}

@Suite("PrismVideoResolution")
struct PrismVideoResolutionTypesTests {

    @Test("has 3 cases and is CaseIterable")
    func caseCount() {
        #expect(PrismVideoResolution.allCases.count == 3)
    }

    @Test("includes hd720, hd1080, uhd4K")
    func allCases() {
        let cases = PrismVideoResolution.allCases
        #expect(cases.contains(.hd720))
        #expect(cases.contains(.hd1080))
        #expect(cases.contains(.uhd4K))
    }
}

@Suite("PrismVideoSettings")
struct PrismVideoSettingsTypesTests {

    @Test("init stores resolution, frameRate, stabilization")
    func storedProperties() {
        let settings = PrismVideoSettings(
            resolution: .uhd4K,
            frameRate: 60,
            stabilization: false
        )
        #expect(settings.resolution == .uhd4K)
        #expect(settings.frameRate == 60)
        #expect(settings.stabilization == false)
    }

    @Test("defaults: resolution=.hd1080, frameRate=30, stabilization=true")
    func defaults() {
        let settings = PrismVideoSettings()
        #expect(settings.resolution == .hd1080)
        #expect(settings.frameRate == 30)
        #expect(settings.stabilization == true)
    }
}

@Suite("PrismCapturedPhoto")
struct PrismCapturedPhotoTypesTests {

    @Test("init stores imageData and metadata")
    func storedProperties() {
        let data = Data([0xFF, 0xD8, 0xFF])
        let metadata = ["width": "1920", "height": "1080"]
        let photo = PrismCapturedPhoto(imageData: data, metadata: metadata)
        #expect(photo.imageData == data)
        #expect(photo.metadata["width"] == "1920")
        #expect(photo.metadata["height"] == "1080")
    }

    @Test("defaults: imageData=nil, metadata=[:]")
    func defaults() {
        let photo = PrismCapturedPhoto()
        #expect(photo.imageData == nil)
        #expect(photo.metadata.isEmpty)
    }
}

@Suite("PrismBarcodeSymbology")
struct PrismBarcodeSymbologyTypesTests {

    @Test("has 8 cases and is CaseIterable")
    func caseCount() {
        #expect(PrismBarcodeSymbology.allCases.count == 8)
    }

    @Test("includes all expected symbologies")
    func allCases() {
        let cases = PrismBarcodeSymbology.allCases
        #expect(cases.contains(.qr))
        #expect(cases.contains(.ean13))
        #expect(cases.contains(.ean8))
        #expect(cases.contains(.code128))
        #expect(cases.contains(.code39))
        #expect(cases.contains(.dataMatrix))
        #expect(cases.contains(.pdf417))
        #expect(cases.contains(.aztec))
    }
}

@Suite("PrismBarcodeResult")
struct PrismBarcodeResultTypesTests {

    @Test("init stores payload, symbology, bounds")
    func storedProperties() {
        let bounds = CGRect(x: 10, y: 20, width: 100, height: 100)
        let result = PrismBarcodeResult(
            payload: "https://example.com",
            symbology: .qr,
            bounds: bounds
        )
        #expect(result.payload == "https://example.com")
        #expect(result.symbology == .qr)
        #expect(result.bounds == bounds)
    }

    @Test("bounds defaults to nil")
    func boundsDefault() {
        let result = PrismBarcodeResult(payload: "1234567890128", symbology: .ean13)
        #expect(result.payload == "1234567890128")
        #expect(result.symbology == .ean13)
        #expect(result.bounds == nil)
    }
}

@Suite("CameraError")
struct CameraErrorTypesTests {

    @Test("has 5 cases: deviceNotFound, outputNotConfigured, sessionNotRunning, torchUnavailable, recordingFailed")
    func allCases() {
        let errors: [CameraError] = [
            .deviceNotFound,
            .outputNotConfigured,
            .sessionNotRunning,
            .torchUnavailable,
            .recordingFailed,
        ]
        #expect(errors.count == 5)
    }

    @Test("conforms to Error")
    func conformsToError() {
        let error: any Error = CameraError.deviceNotFound
        #expect(error is CameraError)
    }
}

#endif
