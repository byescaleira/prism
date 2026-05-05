import SwiftUI

/// Available component templates for code generation.
public enum PrismComponentTemplate: String, Sendable, CaseIterable {
    /// Button component template.
    case button
    /// Card container template.
    case card
    /// Form with validation template.
    case form
    /// Scrollable list template.
    case list
    /// Detail page template.
    case detail
    /// Settings screen template.
    case settings
}

/// Generates SwiftUI source code from predefined PrismUI templates.
public struct PrismComponentGenerator: Sendable {

    /// Returns all available template types.
    public static func availableTemplates() -> [PrismComponentTemplate] {
        PrismComponentTemplate.allCases
    }

    /// Generates Swift source code for a component using the given template and name.
    public static func generate(template: PrismComponentTemplate, name: String) -> String {
        switch template {
        case .button:
            generateButton(name: name)
        case .card:
            generateCard(name: name)
        case .form:
            generateForm(name: name)
        case .list:
            generateList(name: name)
        case .detail:
            generateDetail(name: name)
        case .settings:
            generateSettings(name: name)
        }
    }

    // MARK: - Private Generators

    private static func generateButton(name: String) -> String {
        """
        import SwiftUI
        import PrismUI

        /// A themed button component.
        struct \(name): View {
            @Environment(\\.prismTheme) private var theme

            let title: String
            let action: () -> Void

            var body: some View {
                Button(action: action) {
                    Text(title)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBrand))
                        .padding(.horizontal, SpacingToken.lg.rawValue)
                        .padding(.vertical, SpacingToken.sm.rawValue)
                        .background(theme.color(.brand))
                        .clipShape(RadiusToken.md.shape)
                }
                .accessibilityLabel(title)
            }
        }
        """
    }

    private static func generateCard(name: String) -> String {
        """
        import SwiftUI
        import PrismUI

        /// A themed card component with elevation.
        struct \(name)<Content: View>: View {
            @Environment(\\.prismTheme) private var theme

            let content: Content

            init(@ViewBuilder content: () -> Content) {
                self.content = content()
            }

            var body: some View {
                VStack(alignment: .leading, spacing: SpacingToken.md.rawValue) {
                    content
                }
                .padding(SpacingToken.lg.rawValue)
                .background(theme.color(.surface))
                .clipShape(RadiusToken.lg.shape)
                .shadow(
                    color: theme.color(.shadow),
                    radius: ElevationToken.medium.shadowRadius,
                    y: ElevationToken.medium.shadowY
                )
                .accessibilityElement(children: .contain)
            }
        }
        """
    }

    private static func generateForm(name: String) -> String {
        """
        import SwiftUI
        import PrismUI

        /// A themed form component with validation support.
        struct \(name): View {
            @Environment(\\.prismTheme) private var theme
            @State private var text = ""

            var body: some View {
                Form {
                    Section {
                        TextField("Field", text: $text)
                            .font(TypographyToken.body.font)
                            .padding(SpacingToken.sm.rawValue)
                            .background(theme.color(.surfaceSecondary))
                            .clipShape(RadiusToken.sm.shape)
                    } header: {
                        Text("Section")
                            .font(TypographyToken.caption.font)
                            .foregroundStyle(theme.color(.onBackgroundSecondary))
                    }
                }
                .accessibilityLabel("\\(name) Form")
            }
        }
        """
    }

    private static func generateList(name: String) -> String {
        """
        import SwiftUI
        import PrismUI

        /// A themed list component.
        struct \(name): View {
            @Environment(\\.prismTheme) private var theme

            let items: [String]

            var body: some View {
                List(items, id: \\.self) { item in
                    HStack(spacing: SpacingToken.md.rawValue) {
                        Text(item)
                            .font(TypographyToken.body.font)
                            .foregroundStyle(theme.color(.onSurface))
                    }
                    .padding(.vertical, SpacingToken.xs.rawValue)
                    .accessibilityLabel(item)
                }
                .listStyle(.plain)
            }
        }
        """
    }

    private static func generateDetail(name: String) -> String {
        """
        import SwiftUI
        import PrismUI

        /// A themed detail view component.
        struct \(name): View {
            @Environment(\\.prismTheme) private var theme

            let title: String
            let subtitle: String

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: SpacingToken.lg.rawValue) {
                        Text(title)
                            .font(TypographyToken.largeTitle.font)
                            .foregroundStyle(theme.color(.onBackground))

                        Text(subtitle)
                            .font(TypographyToken.body.font)
                            .foregroundStyle(theme.color(.onBackgroundSecondary))
                    }
                    .padding(SpacingToken.lg.rawValue)
                }
                .background(theme.color(.background))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\\(title) detail")
            }
        }
        """
    }

    private static func generateSettings(name: String) -> String {
        """
        import SwiftUI
        import PrismUI

        /// A themed settings view component.
        struct \(name): View {
            @Environment(\\.prismTheme) private var theme
            @State private var toggleValue = false

            var body: some View {
                List {
                    Section {
                        Toggle("Option", isOn: $toggleValue)
                            .font(TypographyToken.body.font)
                            .tint(theme.color(.brand))
                    } header: {
                        Text("Preferences")
                            .font(TypographyToken.caption.font)
                            .foregroundStyle(theme.color(.onBackgroundSecondary))
                    }
                }
                .accessibilityLabel("\\(name) Settings")
            }
        }
        """
    }
}
