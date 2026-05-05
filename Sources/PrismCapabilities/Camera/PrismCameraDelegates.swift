#if canImport(AVFoundation)
import AVFoundation

// MARK: - Photo Capture Delegate

final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    private let completion: (Result<PrismCapturedPhoto, Error>) -> Void

    init(completion: @escaping (Result<PrismCapturedPhoto, Error>) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            completion(.failure(error))
            return
        }
        let data = photo.fileDataRepresentation()
        var metadata: [String: String] = [:]
        #if !os(macOS)
        metadata = photo.metadata.reduce(into: [String: String]()) { result, pair in
            result["\(pair.key)"] = "\(pair.value)"
        }
        #endif
        completion(.success(PrismCapturedPhoto(imageData: data, metadata: metadata)))
    }
}

// MARK: - Movie Recording Delegate

final class MovieRecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate, @unchecked Sendable {
    var onFinish: ((URL?) -> Void)?

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        onFinish?(error == nil ? outputFileURL : nil)
    }
}

// MARK: - Metadata Delegate

final class MetadataDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {
    private let onDetected: ([PrismBarcodeResult]) -> Void

    init(onDetected: @escaping ([PrismBarcodeResult]) -> Void) {
        self.onDetected = onDetected
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let results = metadataObjects.compactMap { object -> PrismBarcodeResult? in
            guard let readable = object as? AVMetadataMachineReadableCodeObject,
                  let payload = readable.stringValue else {
                return nil
            }
            let symbology: PrismBarcodeSymbology = switch readable.type {
            case .qr: .qr
            case .ean13: .ean13
            case .ean8: .ean8
            case .code128: .code128
            case .code39: .code39
            case .dataMatrix: .dataMatrix
            case .pdf417: .pdf417
            case .aztec: .aztec
            default: .qr
            }
            return PrismBarcodeResult(payload: payload, symbology: symbology, bounds: readable.bounds)
        }
        onDetected(results)
    }
}
#endif
