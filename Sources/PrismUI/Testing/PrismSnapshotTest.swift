import SwiftUI

/// Lightweight snapshot testing utility for visual regression testing.
///
/// Renders SwiftUI views into images for comparison. Does not require
/// external dependencies — uses native SwiftUI rendering.
///
/// ```swift
/// @Test func buttonSnapshot() async {
///     let image = PrismSnapshotTest.render {
///         PrismButton("Tap Me") {}
///     }
///     #expect(image != nil)
/// }
/// ```
@MainActor
public enum PrismSnapshotTest {

    /// Configuration for snapshot rendering.
    public struct Configuration: Sendable {
        public let size: CGSize
        public let colorScheme: ColorScheme
        public let dynamicTypeSize: DynamicTypeSize
        public let theme: any PrismTheme

        @MainActor
        public init(
            size: CGSize = CGSize(width: 375, height: 200),
            colorScheme: ColorScheme = .light,
            dynamicTypeSize: DynamicTypeSize = .medium,
            theme: any PrismTheme = DefaultTheme()
        ) {
            self.size = size
            self.colorScheme = colorScheme
            self.dynamicTypeSize = dynamicTypeSize
            self.theme = theme
        }

        @MainActor public static let light = Configuration()
        @MainActor public static let dark = Configuration(colorScheme: .dark)
        @MainActor public static let largeText = Configuration(dynamicTypeSize: .xxxLarge)
        @MainActor public static let highContrast = Configuration(theme: HighContrastTheme())
    }

    /// Standard snapshot configurations for comprehensive visual testing.
    @MainActor
    public static let standardConfigurations: [String: Configuration] = [
        "light": .light,
        "dark": .dark,
        "largeText": .largeText,
        "highContrast": .highContrast,
    ]

    #if canImport(UIKit) && !os(watchOS)
    /// Renders a SwiftUI view to a UIImage for snapshot comparison.
    @MainActor
    public static func render<V: View>(
        configuration: Configuration = .light,
        @ViewBuilder content: () -> V
    ) -> UIImage? {
        let hosted = content()
            .environment(\.prismTheme, configuration.theme)
            .environment(\.colorScheme, configuration.colorScheme)
            .environment(\.dynamicTypeSize, configuration.dynamicTypeSize)
            .frame(width: configuration.size.width, height: configuration.size.height)

        let controller = UIHostingController(rootView: hosted)
        controller.view.frame = CGRect(origin: .zero, size: configuration.size)
        controller.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: configuration.size)
        return renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }
    }

    /// Renders a view across all standard configurations.
    @MainActor
    public static func renderAll<V: View>(
        @ViewBuilder content: @escaping () -> V
    ) -> [String: UIImage] {
        var results: [String: UIImage] = [:]
        for (name, config) in standardConfigurations {
            if let image = render(configuration: config, content: content) {
                results[name] = image
            }
        }
        return results
    }

    /// Compares two images pixel-by-pixel and returns the percentage match (0.0–1.0).
    public static func compare(_ image1: UIImage, _ image2: UIImage, tolerance: Double = 0.99) -> Bool {
        guard let data1 = image1.pngData(), let data2 = image2.pngData() else {
            return false
        }

        if data1 == data2 { return true }

        guard image1.size == image2.size else { return false }

        guard let cgImage1 = image1.cgImage, let cgImage2 = image2.cgImage else {
            return false
        }

        let width = cgImage1.width
        let height = cgImage1.height
        let totalPixels = width * height

        guard totalPixels > 0 else { return true }

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        var pixels1 = [UInt8](repeating: 0, count: totalPixels * bytesPerPixel)
        var pixels2 = [UInt8](repeating: 0, count: totalPixels * bytesPerPixel)

        guard
            let context1 = CGContext(data: &pixels1, width: width, height: height,
                                     bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                     space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo),
            let context2 = CGContext(data: &pixels2, width: width, height: height,
                                     bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                     space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo)
        else { return false }

        context1.draw(cgImage1, in: CGRect(x: 0, y: 0, width: width, height: height))
        context2.draw(cgImage2, in: CGRect(x: 0, y: 0, width: width, height: height))

        var matchingPixels = 0
        for i in stride(from: 0, to: totalPixels * bytesPerPixel, by: bytesPerPixel) {
            let matches = (0..<bytesPerPixel).allSatisfy { offset in
                abs(Int(pixels1[i + offset]) - Int(pixels2[i + offset])) <= 2
            }
            if matches { matchingPixels += 1 }
        }

        return Double(matchingPixels) / Double(totalPixels) >= tolerance
    }
    #endif
}
