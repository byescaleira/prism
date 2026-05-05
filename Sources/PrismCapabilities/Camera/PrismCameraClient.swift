#if canImport(AVFoundation)
    import AVFoundation
    import CoreGraphics

    // MARK: - Camera Client

    /// Observable client for managing AVFoundation camera sessions, photo/video capture, and barcode scanning.
    @MainActor @Observable
    public final class PrismCameraClient {

        // MARK: - Public Properties

        /// The current camera authorization status.
        public private(set) var permissionStatus: PrismCameraPermission = .notDetermined

        /// Barcodes detected in the current scanning session.
        public private(set) var detectedBarcodes: [PrismBarcodeResult] = []

        // MARK: - Private Properties

        private var captureSession: AVCaptureSession?
        private var currentInput: AVCaptureDeviceInput?
        private var photoOutput: AVCapturePhotoOutput?
        private var movieOutput: AVCaptureMovieFileOutput?
        private var metadataOutput: AVCaptureMetadataOutput?
        private var metadataDelegate: MetadataDelegate?
        private var currentPosition: PrismCameraPosition = .back
        private var currentMode: PrismCaptureMode = .photo

        // MARK: - Init

        /// Creates a new camera client and queries the current authorization status.
        public init() {
            updatePermissionStatus()
        }

        // MARK: - Permission

        /// Requests camera access from the user and returns the resulting permission status.
        public func requestPermission() async -> PrismCameraPermission {
            await AVCaptureDevice.requestAccess(for: .video)
            updatePermissionStatus()
            return permissionStatus
        }

        // MARK: - Session Management

        /// Starts a camera capture session with the specified position and mode.
        public func startSession(position: PrismCameraPosition, mode: PrismCaptureMode) async throws {
            let session = AVCaptureSession()
            session.beginConfiguration()

            session.sessionPreset = mode == .photo ? .photo : .high

            let avPosition = avCapturePosition(from: position)
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: avPosition)
            else {
                session.commitConfiguration()
                throw CameraError.deviceNotFound
            }
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                currentInput = input
            }

            switch mode {
            case .photo:
                let output = AVCapturePhotoOutput()
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    photoOutput = output
                }
            case .video:
                let output = AVCaptureMovieFileOutput()
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    movieOutput = output
                }
            }

            session.commitConfiguration()
            session.startRunning()

            captureSession = session
            currentPosition = position
            currentMode = mode
        }

        /// Stops the current capture session and releases resources.
        public func stopSession() {
            captureSession?.stopRunning()
            captureSession = nil
            currentInput = nil
            photoOutput = nil
            movieOutput = nil
            metadataOutput = nil
            metadataDelegate = nil
            detectedBarcodes = []
        }

        // MARK: - Photo Capture

        /// Captures a photo with the specified settings.
        public func capturePhoto(settings: PrismPhotoSettings) async throws -> PrismCapturedPhoto {
            guard let photoOutput else {
                throw CameraError.outputNotConfigured
            }

            let avSettings = AVCapturePhotoSettings()
            avSettings.flashMode = avFlashMode(from: settings.flashMode)

            return try await withCheckedThrowingContinuation { continuation in
                let delegate = PhotoCaptureDelegate { result in
                    continuation.resume(with: result)
                }
                objc_setAssociatedObject(photoOutput, "captureDelegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                photoOutput.capturePhoto(with: avSettings, delegate: delegate)
            }
        }

        // MARK: - Video Recording

        /// Starts recording video to a temporary file.
        public func startRecording() async throws {
            guard let movieOutput else {
                throw CameraError.outputNotConfigured
            }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            let delegate = MovieRecordingDelegate()
            objc_setAssociatedObject(movieOutput, "recordingDelegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            movieOutput.startRecording(to: url, recordingDelegate: delegate)
        }

        /// Stops the current video recording and returns the file URL.
        public func stopRecording() async throws -> URL? {
            guard let movieOutput, movieOutput.isRecording else {
                return nil
            }
            return await withCheckedContinuation { continuation in
                let delegate = objc_getAssociatedObject(movieOutput, "recordingDelegate") as? MovieRecordingDelegate
                delegate?.onFinish = { url in
                    continuation.resume(returning: url)
                }
                movieOutput.stopRecording()
            }
        }

        // MARK: - Camera Switching

        /// Switches the camera to the specified position while maintaining the current session.
        public func switchCamera(to position: PrismCameraPosition) async throws {
            guard let session = captureSession else {
                throw CameraError.sessionNotRunning
            }

            session.beginConfiguration()

            if let currentInput {
                session.removeInput(currentInput)
            }

            let avPosition = avCapturePosition(from: position)
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: avPosition)
            else {
                session.commitConfiguration()
                throw CameraError.deviceNotFound
            }
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                currentInput = input
                currentPosition = position
            }

            session.commitConfiguration()
        }

        // MARK: - Barcode Scanning

        /// Starts barcode scanning for the specified symbologies.
        public func startBarcodeScanning(symbologies: [PrismBarcodeSymbology]) {
            guard let session = captureSession else { return }

            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                let delegate = MetadataDelegate { [weak self] barcodes in
                    self?.detectedBarcodes = barcodes
                }
                output.setMetadataObjectsDelegate(delegate, queue: .main)
                let avTypes = symbologies.compactMap { avMetadataType(from: $0) }
                let available = output.availableMetadataObjectTypes
                output.metadataObjectTypes = avTypes.filter { available.contains($0) }
                metadataOutput = output
                metadataDelegate = delegate
            }
        }

        /// Stops barcode scanning and clears detected results.
        public func stopBarcodeScanning() {
            if let metadataOutput, let session = captureSession {
                session.removeOutput(metadataOutput)
            }
            metadataOutput = nil
            metadataDelegate = nil
            detectedBarcodes = []
        }

        // MARK: - Zoom & Torch

        /// Sets the zoom factor on the current camera device.
        public func setZoom(factor: CGFloat) {
            #if !os(macOS)
                guard let device = currentInput?.device else { return }
                do {
                    try device.lockForConfiguration()
                    device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
                    device.unlockForConfiguration()
                } catch {
                    // Zoom configuration failed silently — device may not support the requested factor.
                }
            #endif
        }

        /// Enables or disables the torch (flashlight) on the current camera device.
        public func setTorch(enabled: Bool) throws {
            guard let device = currentInput?.device, device.hasTorch else {
                throw CameraError.torchUnavailable
            }
            try device.lockForConfiguration()
            device.torchMode = enabled ? .on : .off
            device.unlockForConfiguration()
        }

        // MARK: - Private Helpers

        private func updatePermissionStatus() {
            permissionStatus =
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .notDetermined: .notDetermined
                case .restricted: .restricted
                case .denied: .denied
                case .authorized: .authorized
                @unknown default: .notDetermined
                }
        }

        private func avCapturePosition(from position: PrismCameraPosition) -> AVCaptureDevice.Position {
            switch position {
            case .front: .front
            case .back: .back
            case .external: .unspecified
            }
        }

        private func avFlashMode(from mode: PrismFlashMode) -> AVCaptureDevice.FlashMode {
            switch mode {
            case .off: .off
            case .on: .on
            case .auto: .auto
            }
        }

        private func avMetadataType(from symbology: PrismBarcodeSymbology) -> AVMetadataObject.ObjectType? {
            switch symbology {
            case .qr: .qr
            case .ean13: .ean13
            case .ean8: .ean8
            case .code128: .code128
            case .code39: .code39
            case .dataMatrix: .dataMatrix
            case .pdf417: .pdf417
            case .aztec: .aztec
            }
        }
    }
#endif
