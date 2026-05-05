#if canImport(AVFoundation)
import AVFoundation
import CoreGraphics

// MARK: - Camera Position

/// The physical position of the camera on the device.
public enum PrismCameraPosition: Sendable, CaseIterable {
    /// The front-facing (selfie) camera.
    case front
    /// The rear-facing camera.
    case back
    /// An externally connected camera.
    case external
}

// MARK: - Capture Mode

/// The capture mode for the camera session.
public enum PrismCaptureMode: Sendable {
    /// Capture still photos.
    case photo
    /// Record video.
    case video
}

// MARK: - Flash Mode

/// The flash mode used when capturing a photo.
public enum PrismFlashMode: Sendable, CaseIterable {
    /// Flash is disabled.
    case off
    /// Flash fires for every capture.
    case on
    /// Flash fires automatically based on lighting conditions.
    case auto
}

// MARK: - Camera Permission

/// The current camera authorization status.
public enum PrismCameraPermission: Sendable, CaseIterable {
    /// The user has not yet been asked for camera access.
    case notDetermined
    /// Camera access is restricted by the system (e.g., parental controls).
    case restricted
    /// The user has explicitly denied camera access.
    case denied
    /// The user has granted camera access.
    case authorized
}

// MARK: - Photo Quality

/// The quality level for captured photos.
public enum PrismPhotoQuality: Sendable, CaseIterable {
    /// Low quality, smallest file size.
    case low
    /// Medium quality, balanced file size.
    case medium
    /// High quality, larger file size.
    case high
    /// Maximum quality, largest file size.
    case maximum
}

// MARK: - Photo Settings

/// Configuration for capturing a photo.
public struct PrismPhotoSettings: Sendable {
    /// The flash mode to use during capture.
    public let flashMode: PrismFlashMode
    /// Whether HDR is enabled for the capture.
    public let isHDREnabled: Bool
    /// The quality level of the captured image.
    public let quality: PrismPhotoQuality

    /// Creates photo settings with the given flash mode, HDR flag, and quality level.
    public init(flashMode: PrismFlashMode = .auto, isHDREnabled: Bool = false, quality: PrismPhotoQuality = .high) {
        self.flashMode = flashMode
        self.isHDREnabled = isHDREnabled
        self.quality = quality
    }
}

// MARK: - Video Resolution

/// The resolution preset for video recording.
public enum PrismVideoResolution: Sendable, CaseIterable {
    /// 720p HD resolution (1280x720).
    case hd720
    /// 1080p Full HD resolution (1920x1080).
    case hd1080
    /// 4K Ultra HD resolution (3840x2160).
    case uhd4K
}

// MARK: - Video Settings

/// Configuration for video recording.
public struct PrismVideoSettings: Sendable {
    /// The target video resolution.
    public let resolution: PrismVideoResolution
    /// The target frame rate in frames per second.
    public let frameRate: Int
    /// Whether video stabilization is enabled.
    public let stabilization: Bool

    /// Creates video settings with the given resolution, frame rate, and stabilization flag.
    public init(resolution: PrismVideoResolution = .hd1080, frameRate: Int = 30, stabilization: Bool = true) {
        self.resolution = resolution
        self.frameRate = frameRate
        self.stabilization = stabilization
    }
}

// MARK: - Captured Photo

/// The result of a photo capture operation.
public struct PrismCapturedPhoto: Sendable {
    /// The raw image data of the captured photo.
    public let imageData: Data?
    /// Metadata key-value pairs associated with the captured photo.
    public let metadata: [String: String]

    /// Creates a captured photo result with the given image data and metadata.
    public init(imageData: Data? = nil, metadata: [String: String] = [:]) {
        self.imageData = imageData
        self.metadata = metadata
    }
}

// MARK: - Barcode Symbology

/// The barcode symbology types supported for scanning.
public enum PrismBarcodeSymbology: Sendable, CaseIterable {
    /// QR code.
    case qr
    /// EAN-13 barcode.
    case ean13
    /// EAN-8 barcode.
    case ean8
    /// Code 128 barcode.
    case code128
    /// Code 39 barcode.
    case code39
    /// Data Matrix 2D barcode.
    case dataMatrix
    /// PDF417 2D barcode.
    case pdf417
    /// Aztec 2D barcode.
    case aztec
}

// MARK: - Barcode Result

/// The result of a barcode detection.
public struct PrismBarcodeResult: Sendable {
    /// The decoded payload string from the barcode.
    public let payload: String
    /// The symbology type of the detected barcode.
    public let symbology: PrismBarcodeSymbology
    /// The bounding rectangle of the barcode in the camera preview coordinate space.
    public let bounds: CGRect?

    /// Creates a barcode result with the given payload, symbology, and optional bounds.
    public init(payload: String, symbology: PrismBarcodeSymbology, bounds: CGRect? = nil) {
        self.payload = payload
        self.symbology = symbology
        self.bounds = bounds
    }
}

// MARK: - Camera Error

/// Errors that can occur during camera operations.
public enum CameraError: Error, Sendable {
    /// No camera device matching the requested position was found.
    case deviceNotFound
    /// The capture output has not been configured for the current mode.
    case outputNotConfigured
    /// No capture session is currently running.
    case sessionNotRunning
    /// The torch (flashlight) is not available on the current device.
    case torchUnavailable
    /// The video recording operation failed.
    case recordingFailed
}
#endif
