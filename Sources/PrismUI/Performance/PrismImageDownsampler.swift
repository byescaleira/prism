import SwiftUI
import ImageIO
import CoreGraphics

/// Memory-efficient image downsampling using CGImageSource.
public enum PrismImageDownsampler: Sendable {

    /// Downsamples an image file at the given URL to fit within a point size.
    /// - Parameters:
    ///   - url: File URL of the source image.
    ///   - pointSize: Target size in points.
    ///   - scale: Display scale factor (e.g. UIScreen.main.scale).
    /// - Returns: A downsampled CGImage, or nil on failure.
    public static func downsample(
        imageAt url: URL,
        to pointSize: CGSize,
        scale: CGFloat
    ) -> CGImage? {
        let sourceOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
        ]
        guard let source = CGImageSourceCreateWithURL(
            url as CFURL, sourceOptions as CFDictionary
        ) else { return nil }
        return createThumbnail(from: source, pointSize: pointSize, scale: scale)
    }

    /// Downsamples image data to fit within a point size.
    /// - Parameters:
    ///   - data: Raw image data.
    ///   - pointSize: Target size in points.
    ///   - scale: Display scale factor.
    /// - Returns: A downsampled CGImage, or nil on failure.
    public static func downsample(
        data: Data,
        to pointSize: CGSize,
        scale: CGFloat
    ) -> CGImage? {
        let sourceOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
        ]
        guard let source = CGImageSourceCreateWithData(
            data as CFData, sourceOptions as CFDictionary
        ) else { return nil }
        return createThumbnail(from: source, pointSize: pointSize, scale: scale)
    }

    private static func createThumbnail(
        from source: CGImageSource,
        pointSize: CGSize,
        scale: CGFloat
    ) -> CGImage? {
        let maxDimension = max(pointSize.width, pointSize.height) * scale
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
        ]
        return CGImageSourceCreateThumbnailAtIndex(
            source, 0, options as CFDictionary
        )
    }
}

/// SwiftUI view that asynchronously loads and displays a downsampled image.
public struct PrismDownsampledImage: View {
    private let url: URL?
    private let pointSize: CGSize
    private let scale: CGFloat

    @State private var cgImage: CGImage?

    /// Creates a downsampled image view.
    /// - Parameters:
    ///   - url: File URL of the source image.
    ///   - pointSize: Target display size in points.
    ///   - scale: Display scale factor.
    public init(url: URL?, pointSize: CGSize, scale: CGFloat = 2.0) {
        self.url = url
        self.pointSize = pointSize
        self.scale = scale
    }

    /// The content and behavior of the downsampled image view.
    public var body: some View {
        Group {
            if let cgImage {
                Image(decorative: cgImage, scale: scale)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
            }
        }
        .frame(width: pointSize.width, height: pointSize.height)
        .task {
            guard let url else { return }
            cgImage = PrismImageDownsampler.downsample(
                imageAt: url, to: pointSize, scale: scale
            )
        }
    }
}
