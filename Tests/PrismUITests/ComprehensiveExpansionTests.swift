import SwiftUI
import Testing

@testable import PrismUI

#if canImport(MapKit)
    import MapKit
#endif

#if canImport(PhotosUI)
    import PhotosUI
#endif

@MainActor
@Suite("Comprehensive Expansion")
struct ComprehensiveExpansionTests {

    // MARK: - Map

    #if canImport(MapKit)
        @Suite("Map Integration")
        struct MapTests {

            @Test("PrismMap creation")
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
            @MainActor func mapCreation() {
                let view = PrismMap {
                    PrismMapMarker("Test", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
                }
                _ = view.body
            }

            @Test("PrismMapMarker with custom tint")
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
            @MainActor func mapMarkerTint() {
                let marker = PrismMapMarker(
                    "Location",
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    tint: .success
                )
                _ = marker
            }

            @Test("PrismMapAnnotation creation")
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
            @MainActor func mapAnnotation() {
                let annotation = PrismMapAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
                ) {
                    Image(systemName: "mappin.circle.fill")
                }
                _ = annotation
            }
        }
    #endif

    // MARK: - Photos

    #if canImport(PhotosUI)
        @Suite("Photo Picker")
        struct PhotoTests {

            @Test("PrismPhotoPicker creation")
            @MainActor func photoPicker() {
                @State var item: PhotosPickerItem? = nil
                let view = PrismPhotoPicker("Select Photo", selection: $item)
                _ = view.body
            }

            @Test("PrismMultiPhotoPicker creation")
            @MainActor func multiPhotoPicker() {
                @State var items: [PhotosPickerItem] = []
                let view = PrismMultiPhotoPicker(selection: $items, maxSelectionCount: 5) {
                    Label("Photos", systemImage: "photo.stack")
                }
                _ = view.body
            }
        }
    #endif

    // MARK: - Document

    @Suite("Document Support")
    struct DocumentTests {

        @Test("PrismDocumentView renders")
        @MainActor func documentView() {
            let view = PrismDocumentView("My Doc") {
                TextEditor(text: .constant("Hello"))
            }
            _ = view.body
        }

        @Test("PrismDocumentView default title")
        @MainActor func documentViewDefault() {
            let view = PrismDocumentView {
                Text("Content")
            }
            _ = view.body
        }
    }

    // MARK: - Flexible Header

    @Suite("Flexible Header")
    struct FlexibleHeaderTests {

        @Test("PrismFlexibleHeader renders")
        @MainActor func flexibleHeader() {
            let view = PrismFlexibleHeader(minHeight: 200) {
                Color.blue
            }
            _ = view.body
        }

        @Test("PrismFlexibleHeader default height")
        @MainActor func flexibleHeaderDefault() {
            let view = PrismFlexibleHeader {
                Color.red
            }
            _ = view.body
        }

        @Test("PrismParallaxHeader with overlay")
        @MainActor func parallaxHeader() {
            let view = PrismParallaxHeader(minHeight: 300) {
                Color.blue
            } overlay: {
                Text("Title")
            }
            _ = view.body
        }

        @Test("PrismParallaxHeader without overlay")
        @MainActor func parallaxHeaderNoOverlay() {
            let view = PrismParallaxHeader {
                Color.green
            }
            _ = view.body
        }
    }

    // MARK: - Gradients

    @Suite("Gradients & Materials")
    struct GradientTests {

        @Test("PrismLinearGradient two colors")
        @MainActor func linearTwoColors() {
            let view = PrismLinearGradient(from: .brand, to: .interactive)
            _ = view.body
        }

        @Test("PrismLinearGradient multiple colors")
        @MainActor func linearMultiple() {
            let view = PrismLinearGradient(
                colors: [.brand, .interactive, .success],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            _ = view.body
        }

        @Test("PrismRadialGradient renders")
        @MainActor func radialGradient() {
            let view = PrismRadialGradient(
                colors: [.interactive, .background],
                center: .center,
                endRadius: 150
            )
            _ = view.body
        }

        @Test("PrismAngularGradient renders")
        @MainActor func angularGradient() {
            let view = PrismAngularGradient(
                colors: [.brand, .interactive, .success, .brand]
            )
            _ = view.body
        }

        @Test("PrismMaterial cases")
        @MainActor func materialCases() {
            let cases: [PrismMaterial] = [
                .ultraThin, .thin, .regular, .thick, .ultraThick, .bar,
            ]
            #expect(cases.count == 6)
            for m in cases {
                _ = m.material
            }
        }

        @Test("prismMaterial modifier")
        @MainActor func materialModifier() {
            let view = Text("Glass")
                .prismMaterial(.regular, in: RoundedRectangle(cornerRadius: 12))
            _ = view
        }
    }

    // MARK: - Toolbar

    @Suite("Advanced Toolbar")
    struct ToolbarTests {

        @Test("PrismToolbarPlacement cases")
        @MainActor func toolbarPlacements() {
            let cases: [PrismToolbarPlacement] = [
                .leading, .trailing, .principal, .primaryAction,
                .secondaryAction, .navigation, .status,
            ]
            #expect(cases.count == 7)
        }

        @Test("PrismToolbarButton renders")
        @MainActor func toolbarButton() {
            let view = PrismToolbarButton("Save", systemImage: "checkmark") {}
            _ = view.body
        }

        @Test("PrismToolbarMenu renders")
        @MainActor func toolbarMenu() {
            let view = PrismToolbarMenu {
                Button("Option A") {}
                Button("Option B") {}
            }
            _ = view.body
        }

        @Test("PrismToolbarMenu custom icon")
        @MainActor func toolbarMenuIcon() {
            let view = PrismToolbarMenu(systemImage: "gear") {
                Button("Settings") {}
            }
            _ = view.body
        }
    }

    // MARK: - Form Validation

    @Suite("Form Validation")
    struct ValidationTests {

        @Test("Required rule validates")
        @MainActor func requiredRule() {
            #expect(PrismValidationRule.required.validate("hello"))
            #expect(!PrismValidationRule.required.validate(""))
            #expect(!PrismValidationRule.required.validate("   "))
        }

        @Test("Email rule validates")
        @MainActor func emailRule() {
            #expect(PrismValidationRule.email.validate("test@example.com"))
            #expect(!PrismValidationRule.email.validate("not-email"))
            #expect(!PrismValidationRule.email.validate("@.com"))
        }

        @Test("MinLength rule validates")
        @MainActor func minLengthRule() {
            let rule = PrismValidationRule.minLength(3)
            #expect(rule.validate("abc"))
            #expect(!rule.validate("ab"))
        }

        @Test("MaxLength rule validates")
        @MainActor func maxLengthRule() {
            let rule = PrismValidationRule.maxLength(5)
            #expect(rule.validate("abcde"))
            #expect(!rule.validate("abcdef"))
        }

        @Test("Range rule validates")
        @MainActor func rangeRule() {
            let rule = PrismValidationRule.range(1...100)
            #expect(rule.validate("50"))
            #expect(!rule.validate("0"))
            #expect(!rule.validate("101"))
            #expect(!rule.validate("abc"))
        }

        @Test("Regex rule validates")
        @MainActor func regexRule() {
            let rule = PrismValidationRule.regex(#"^\d{3}$"#, message: "Must be 3 digits")
            #expect(rule.validate("123"))
            #expect(!rule.validate("12"))
            #expect(!rule.validate("abcd"))
        }

        @Test("PrismValidatedField renders")
        @MainActor func validatedField() {
            @State var text = ""
            let view = PrismValidatedField("Email", text: $text, rules: [.required, .email])
            _ = view.body
        }
    }

    // MARK: - Preview Tools

    @Suite("Preview Enhancements")
    struct PreviewTests {

        @Test("PrismDevicePreview renders")
        @MainActor func devicePreview() {
            let view = PrismDevicePreview {
                Text("Component")
            }
            _ = view.body
        }

        @Test("PrismLocalePreview renders")
        @MainActor func localePreview() {
            let view = PrismLocalePreview {
                Text("RTL Test")
            }
            _ = view.body
        }
    }

    // MARK: - Onboarding

    @Suite("Onboarding")
    struct OnboardingTests {

        @Test("PrismOnboarding renders")
        @MainActor func onboardingRenders() {
            let view = PrismOnboarding(pages: [
                .init(icon: "star", title: "Welcome", message: "Hello"),
                .init(icon: "heart", title: "Enjoy", message: "World"),
            ]) {}
            _ = view.body
        }

        @Test("PrismOnboarding.Page creation")
        @MainActor func pageCreation() {
            let page = PrismOnboarding.Page(
                icon: "star",
                title: "Title",
                message: "Message"
            )
            #expect(page.icon == "star")
        }

        @Test("Single page onboarding")
        @MainActor func singlePage() {
            let view = PrismOnboarding(pages: [
                .init(icon: "checkmark", title: "Done", message: "Only page")
            ]) {}
            _ = view.body
        }
    }

    // MARK: - Redacted Styles

    @Suite("Redacted Styles")
    struct RedactedTests {

        @Test("PrismRedactedStyle cases")
        @MainActor func redactedCases() {
            let cases: [PrismRedactedStyle] = [.shimmer, .pulse, .blur]
            #expect(cases.count == 3)
        }

        @Test("prismRedacted shimmer when loading")
        @MainActor func shimmerLoading() {
            let view = Text("Loading...")
                .prismRedacted(.shimmer, isLoading: true)
            _ = view
        }

        @Test("prismRedacted pulse when loading")
        @MainActor func pulseLoading() {
            let view = Text("Loading...")
                .prismRedacted(.pulse, isLoading: true)
            _ = view
        }

        @Test("prismRedacted blur when loading")
        @MainActor func blurLoading() {
            let view = Text("Loading...")
                .prismRedacted(.blur, isLoading: true)
            _ = view
        }

        @Test("prismRedacted not loading shows content")
        @MainActor func notLoading() {
            let view = Text("Ready")
                .prismRedacted(.shimmer, isLoading: false)
            _ = view
        }
    }

    // MARK: - Notification Banner

    @Suite("Notification Banner")
    struct NotificationBannerTests {

        @Test("PrismNotificationBanner.Content creation")
        @MainActor func contentCreation() {
            let content = PrismNotificationBanner.Content(
                "New Message",
                message: "You have a new notification",
                icon: "bell.fill",
                style: .info,
                duration: 5
            )
            #expect(content.icon == "bell.fill")
            #expect(content.duration == 5)
        }

        @Test("Notification styles")
        @MainActor func notificationStyles() {
            let styles: [PrismNotificationBanner.Content.Style] = [
                .info, .success, .warning, .error,
            ]
            #expect(styles.count == 4)
        }

        @Test("prismNotificationBanner modifier")
        @MainActor func bannerModifier() {
            @State var notification: PrismNotificationBanner.Content? = nil
            let view = Text("Content")
                .prismNotificationBanner($notification)
            _ = view
        }

        @Test("Banner with content renders")
        @MainActor func bannerRenders() {
            let content = PrismNotificationBanner.Content("Test")
            let view = PrismNotificationBanner(content: content) {}
            _ = view.body
        }
    }
}
