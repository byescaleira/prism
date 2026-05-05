import SwiftUI
import Testing

@testable import PrismUI

@MainActor
struct SnapshotTests {

    @Test
    func snapshotConfigurationDefaults() {
        let config = PrismSnapshotTest.Configuration.light
        #expect(config.size.width == 375)
        #expect(config.size.height == 200)
        #expect(config.colorScheme == .light)
    }

    @Test
    func darkConfigurationUsesDarkScheme() {
        let config = PrismSnapshotTest.Configuration.dark
        #expect(config.colorScheme == .dark)
    }

    @Test
    func largeTextConfigurationUsesXXXLarge() {
        let config = PrismSnapshotTest.Configuration.largeText
        #expect(config.dynamicTypeSize == .xxxLarge)
    }

    @Test
    func standardConfigurationsHaveFourEntries() {
        #expect(PrismSnapshotTest.standardConfigurations.count == 4)
    }

    @Test
    func customConfigurationAcceptsParameters() {
        let config = PrismSnapshotTest.Configuration(
            size: CGSize(width: 200, height: 100),
            colorScheme: .dark,
            dynamicTypeSize: .large,
            theme: DarkTheme()
        )
        #expect(config.size.width == 200)
        #expect(config.colorScheme == .dark)
    }

    #if canImport(UIKit) && !os(watchOS)
        @Test
        func renderProducesImage() {
            let image = PrismSnapshotTest.render {
                Text("Hello")
                    .padding()
            }
            #expect(image != nil)
        }

        @Test
        func renderAllProducesMultipleImages() {
            let results = PrismSnapshotTest.renderAll {
                Text("Test")
                    .padding()
            }
            #expect(results.count == 4)
            #expect(results["light"] != nil)
            #expect(results["dark"] != nil)
        }

        @Test
        func identicalImagesCompareAsEqual() {
            let image1 = PrismSnapshotTest.render {
                Text("Same").padding()
            }
            let image2 = PrismSnapshotTest.render {
                Text("Same").padding()
            }
            guard let img1 = image1, let img2 = image2 else {
                #expect(Bool(false), "Failed to render")
                return
            }
            #expect(PrismSnapshotTest.compare(img1, img2))
        }
    #endif
}
