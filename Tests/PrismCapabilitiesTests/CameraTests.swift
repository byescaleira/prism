import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - Camera Tests

@Suite("PrismCamera")
struct PrismCameraTests {

    @Test("PrismCameraPosition has 3 cases")
    func cameraPositionCaseCount() {
        #expect(PrismCameraPosition.allCases.count == 3)
    }

    @Test("PrismCameraPosition includes all expected cases")
    func cameraPositionCases() {
        let cases = PrismCameraPosition.allCases
        #expect(cases.contains(.front))
        #expect(cases.contains(.back))
        #expect(cases.contains(.external))
    }

    @Test("PrismCaptureMode has 2 cases")
    func captureModeCases() {
        let modes: [PrismCaptureMode] = [.photo, .video]
        #expect(modes.count == 2)
    }

    @Test("PrismFlashMode has 3 cases")
    func flashModeCaseCount() {
        #expect(PrismFlashMode.allCases.count == 3)
    }

    @Test("PrismFlashMode includes all expected cases")
    func flashModeCases() {
        let cases = PrismFlashMode.allCases
        #expect(cases.contains(.off))
        #expect(cases.contains(.on))
        #expect(cases.contains(.auto))
    }

    @Test("PrismCameraPermission has 4 cases")
    func cameraPermissionCaseCount() {
        #expect(PrismCameraPermission.allCases.count == 4)
    }

    @Test("PrismCameraPermission includes all expected cases")
    func cameraPermissionCases() {
        let cases = PrismCameraPermission.allCases
        #expect(cases.contains(.notDetermined))
        #expect(cases.contains(.restricted))
        #expect(cases.contains(.denied))
        #expect(cases.contains(.authorized))
    }

    @Test("PrismPhotoQuality has 4 cases")
    func photoQualityCaseCount() {
        #expect(PrismPhotoQuality.allCases.count == 4)
    }

    @Test("PrismPhotoQuality includes all expected cases")
    func photoQualityCases() {
        let cases = PrismPhotoQuality.allCases
        #expect(cases.contains(.low))
        #expect(cases.contains(.medium))
        #expect(cases.contains(.high))
        #expect(cases.contains(.maximum))
    }

    @Test("PrismVideoResolution has 3 cases")
    func videoResolutionCaseCount() {
        #expect(PrismVideoResolution.allCases.count == 3)
    }

    @Test("PrismVideoResolution includes all expected cases")
    func videoResolutionCases() {
        let cases = PrismVideoResolution.allCases
        #expect(cases.contains(.hd720))
        #expect(cases.contains(.hd1080))
        #expect(cases.contains(.uhd4K))
    }

    @Test("PrismBarcodeSymbology has 8 cases")
    func barcodeSymbologyCaseCount() {
        #expect(PrismBarcodeSymbology.allCases.count == 8)
    }

    @Test("PrismBarcodeSymbology includes all expected cases")
    func barcodeSymbologyCases() {
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

    @Test("PrismPhotoSettings stores properties correctly")
    func photoSettingsProperties() {
        let settings = PrismPhotoSettings(
            flashMode: .on,
            isHDREnabled: true,
            quality: .maximum
        )
        #expect(settings.flashMode == .on)
        #expect(settings.isHDREnabled == true)
        #expect(settings.quality == .maximum)
    }

    @Test("PrismPhotoSettings has sensible defaults")
    func photoSettingsDefaults() {
        let settings = PrismPhotoSettings()
        #expect(settings.flashMode == .auto)
        #expect(settings.isHDREnabled == false)
        #expect(settings.quality == .high)
    }

    @Test("PrismVideoSettings stores properties correctly")
    func videoSettingsProperties() {
        let settings = PrismVideoSettings(
            resolution: .uhd4K,
            frameRate: 60,
            stabilization: false
        )
        #expect(settings.resolution == .uhd4K)
        #expect(settings.frameRate == 60)
        #expect(settings.stabilization == false)
    }

    @Test("PrismVideoSettings has sensible defaults")
    func videoSettingsDefaults() {
        let settings = PrismVideoSettings()
        #expect(settings.resolution == .hd1080)
        #expect(settings.frameRate == 30)
        #expect(settings.stabilization == true)
    }

    @Test("PrismCapturedPhoto stores properties correctly")
    func capturedPhotoProperties() {
        let data = Data([0xFF, 0xD8, 0xFF])
        let metadata = ["width": "1920", "height": "1080"]
        let photo = PrismCapturedPhoto(imageData: data, metadata: metadata)
        #expect(photo.imageData == data)
        #expect(photo.metadata["width"] == "1920")
        #expect(photo.metadata["height"] == "1080")
    }

    @Test("PrismCapturedPhoto has sensible defaults")
    func capturedPhotoDefaults() {
        let photo = PrismCapturedPhoto()
        #expect(photo.imageData == nil)
        #expect(photo.metadata.isEmpty)
    }

    @Test("PrismBarcodeResult stores properties correctly")
    func barcodeResultProperties() {
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

    @Test("PrismBarcodeResult defaults bounds to nil")
    func barcodeResultDefaults() {
        let result = PrismBarcodeResult(payload: "1234567890128", symbology: .ean13)
        #expect(result.bounds == nil)
    }
}
