import SwiftUI

/// Complete preview catalog covering every component in every state.
///
/// Drop any preview into an Xcode `#Preview` block:
/// ```swift
/// #Preview("Buttons") { PrismPreviews.buttons }
/// #Preview("Cards") { PrismPreviews.cards }
/// ```
@MainActor
public enum PrismPreviews {

    // MARK: - Primitives

    /// Preview of all button variants and roles.
    public static var buttons: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionHeader("Standard Variants")
                PrismButton("Filled", variant: .filled) {}
                PrismButton("Tinted", variant: .tinted) {}
                PrismButton("Bordered", variant: .bordered) {}
                PrismButton("Plain", variant: .plain) {}

                sectionHeader("Roles")
                PrismButton("Destructive", variant: .filled, role: .destructive) {}
                PrismButton("Cancel", variant: .bordered, role: .cancel) {}

                sectionHeader("States")
                PrismButton("Disabled", variant: .filled) {}.disabled(true)

                sectionHeader("Glass")
                PrismButton("Glass", variant: .glass) {}
                PrismButton("Glass Prominent", variant: .glassProminent) {}
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    /// Preview of text field styles and validation states.
    public static var textFields: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionHeader("Standard")
                PrismTextField("Email", text: .constant("user@example.com"))
                PrismTextField("Empty", text: .constant(""))

                sectionHeader("With Validation")
                PrismTextField("Required", text: .constant(""), validation: .required("Required"))
                PrismTextField("Min Length", text: .constant("ab"), validation: .minLength(3, "Too short"))

                sectionHeader("Multiline")
                PrismTextField("Notes", text: .constant("Multi-line text area"), axis: .vertical)
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    /// Preview of card styles and elevation levels.
    public static var cards: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionHeader("Default Card")
                PrismCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card Title").font(TypographyToken.headline.font)
                        Text("Description text").font(TypographyToken.body.font)
                    }
                }

                sectionHeader("Elevated Card")
                PrismCard(elevation: .high) {
                    Text("High elevation")
                }

                sectionHeader("Secondary Surface")
                PrismCard(surface: .surfaceSecondary) {
                    Text("Secondary background")
                }
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    /// Preview of tag styles across semantic categories.
    public static var tags: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionHeader("Styles")
                HStack {
                    PrismTag("Default")
                    PrismTag("Info", style: .info)
                    PrismTag("Success", style: .success)
                    PrismTag("Warning", style: .warning)
                    PrismTag("Error", style: .error)
                }
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    /// Preview of avatar sizes and status indicators.
    public static var avatars: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionHeader("Sizes")
                HStack(spacing: 16) {
                    PrismAvatar(initials: "SM", size: .small)
                    PrismAvatar(initials: "MD", size: .medium)
                    PrismAvatar(initials: "LG", size: .large)
                }

                sectionHeader("With Status")
                HStack(spacing: 16) {
                    PrismAvatar(initials: "ON", size: .medium, status: .online)
                    PrismAvatar(initials: "AW", size: .medium, status: .away)
                    PrismAvatar(initials: "BY", size: .medium, status: .busy)
                    PrismAvatar(initials: "OF", size: .medium, status: .offline)
                }
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    /// Preview of loading, empty, and error states.
    public static var loadingStates: some View {
        ScrollView {
            VStack(spacing: 24) {
                sectionHeader("Loading")
                PrismLoadingState(.loading)
                    .frame(height: 100)

                sectionHeader("Empty")
                PrismLoadingState(.empty(
                    title: "No Items",
                    message: "Add your first item to get started.",
                    icon: "tray"
                ))
                .frame(height: 200)

                sectionHeader("Error")
                PrismLoadingState(.error("Something went wrong", retry: {}))
                    .frame(height: 200)
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    // MARK: - Composites

    /// Preview of banner styles across all feedback levels.
    public static var banners: some View {
        ScrollView {
            VStack(spacing: 12) {
                sectionHeader("All Styles")
                PrismBanner("Info message", style: .info)
                PrismBanner("Success!", style: .success)
                PrismBanner("Warning alert", style: .warning)
                PrismBanner("Error occurred", style: .error)
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    /// Preview of search bar in empty and populated states.
    public static var searchBar: some View {
        VStack(spacing: 16) {
            sectionHeader("Search Bar")
            PrismSearchBar(text: .constant(""))
            PrismSearchBar(text: .constant("SwiftUI"))
        }
        .padding()
        .prismTheme(DefaultTheme())
    }

    // MARK: - Forms

    /// Preview of form controls including toggles, sliders, and secure fields.
    public static var forms: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionHeader("Toggle")
                PrismToggle("Notifications", isOn: .constant(true))
                PrismToggle("Dark Mode", isOn: .constant(false))

                sectionHeader("Slider")
                PrismSlider("Volume", value: .constant(0.6))

                sectionHeader("Secure Field")
                PrismSecureField("Password", text: .constant("secret123"))
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    // MARK: - Layout

    /// Preview of layout primitives including adaptive stacks, sections, and dividers.
    public static var layout: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionHeader("Adaptive Stack")
                PrismAdaptiveStack(spacing: .md) {
                    PrismCard { Text("Card A") }
                    PrismCard { Text("Card B") }
                    PrismCard { Text("Card C") }
                }

                sectionHeader("Section")
                PrismSection {
                    Text("Row 1")
                    Text("Row 2")
                } header: {
                    Text("Settings")
                }

                sectionHeader("Divider")
                Text("Above")
                PrismDivider()
                Text("Below")
            }
            .padding()
        }
        .prismTheme(DefaultTheme())
    }

    // MARK: - Tokens

    /// Preview of all elevation token shadow levels.
    public static var elevationScale: some View {
        ScrollView {
            VStack(spacing: 24) {
                sectionHeader("Elevation Tokens")
                let tokens = ElevationToken.allCases
                ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                    HStack {
                        Text(String(describing: token))
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(height: 50)
                            .prismElevation(token)
                    }
                }
            }
            .padding()
        }
    }

    /// Preview of all motion token durations.
    public static var motionScale: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Motion Tokens")
            ForEach(MotionToken.allCases, id: \.self) { token in
                HStack {
                    Text(String(describing: token))
                        .font(.caption)
                        .frame(width: 80, alignment: .leading)
                    Text("\(Int(token.duration * 1000))ms")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    // MARK: - Themes

    /// Preview of all built-in themes side by side.
    public static var allThemes: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                themePreview(DefaultTheme(), name: "Default")
                themePreview(DarkTheme(), name: "Dark")
                themePreview(HighContrastTheme(), name: "High Contrast")
                themePreview(
                    BrandTheme(primary: .indigo, secondary: .mint, accent: .orange),
                    name: "Custom Brand"
                )
            }
            .padding()
        }
    }

    // MARK: - Helpers

    private static func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(TypographyToken.headline.font)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private static func themePreview<T: PrismTheme>(_ theme: T, name: String) -> some View {
        VStack(spacing: 12) {
            Text(name)
                .font(TypographyToken.headline.font)
                .foregroundStyle(theme.color(.onBackground))

            PrismButton("Primary", variant: .filled) {}

            PrismCard {
                Text("Card content")
                    .font(TypographyToken.body.font)
            }

            HStack(spacing: 8) {
                PrismTag("Tag", style: .info)
                PrismTag("Success", style: .success)
            }
        }
        .padding()
        .frame(width: 200)
        .background(theme.color(.background))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .prismTheme(theme)
    }
}
