import SwiftUI

/// Live runtime theme builder with sliders/pickers for every token category.
///
/// ```swift
/// #if DEBUG
/// PrismThemeEditor()
/// #endif
/// ```
@MainActor
public struct PrismThemeEditor: View {
    @State private var brandColor: Color = .blue
    @State private var secondaryColor: Color = .cyan
    @State private var accentColor: Color = .orange
    @State private var successColor: Color = .green
    @State private var warningColor: Color = .orange
    @State private var errorColor: Color = .red
    @State private var infoColor: Color = .blue

    @State private var selectedSpacing: SpacingToken = .md
    @State private var selectedRadius: RadiusToken = .md
    @State private var selectedElevation: ElevationToken = .medium
    @State private var selectedMotion: MotionToken = .normal

    @State private var previewDarkMode = false
    @State private var showExport = false

    public init() {}

    private var editorTheme: BrandTheme {
        BrandTheme(primary: brandColor, secondary: secondaryColor, accent: accentColor)
    }

    public var body: some View {
        NavigationStack {
            List {
                colorSection
                spacingSection
                radiusSection
                elevationSection
                motionSection
                previewSection
                exportSection
            }
            #if os(iOS) || os(visionOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.sidebar)
            #endif
            .navigationTitle("Theme Editor")
            .sheet(isPresented: $showExport) {
                exportView
            }
        }
    }

    // MARK: - Colors

    @ViewBuilder
    private var colorSection: some View {
        Section("Brand Colors") {
            ColorPicker("Primary / Brand", selection: $brandColor)
            ColorPicker("Secondary", selection: $secondaryColor)
            ColorPicker("Accent / Interactive", selection: $accentColor)
        }
        Section("Feedback Colors") {
            ColorPicker("Success", selection: $successColor)
            ColorPicker("Warning", selection: $warningColor)
            ColorPicker("Error", selection: $errorColor)
            ColorPicker("Info", selection: $infoColor)
        }
    }

    // MARK: - Spacing

    @ViewBuilder
    private var spacingSection: some View {
        Section("Spacing") {
            Picker("Preview Spacing", selection: $selectedSpacing) {
                ForEach(SpacingToken.allCases, id: \.self) { token in
                    Text("\(String(describing: token)) (\(Int(token.rawValue))pt)")
                        .tag(token)
                }
            }
            HStack(spacing: selectedSpacing.rawValue) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(editorTheme.color(.interactive))
                        .frame(width: 40, height: 40)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Radius

    @ViewBuilder
    private var radiusSection: some View {
        Section("Corner Radius") {
            Picker("Preview Radius", selection: $selectedRadius) {
                ForEach(RadiusToken.allCases, id: \.self) { token in
                    Text("\(String(describing: token)) (\(Int(token.rawValue))pt)")
                        .tag(token)
                }
            }
            RoundedRectangle(cornerRadius: selectedRadius.rawValue)
                .fill(editorTheme.color(.interactive).opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: selectedRadius.rawValue)
                        .stroke(editorTheme.color(.interactive), lineWidth: 2)
                )
                .frame(height: 60)
        }
    }

    // MARK: - Elevation

    @ViewBuilder
    private var elevationSection: some View {
        Section("Elevation") {
            Picker("Preview Elevation", selection: $selectedElevation) {
                ForEach(ElevationToken.allCases, id: \.self) { token in
                    Text(String(describing: token)).tag(token)
                }
            }
            RoundedRectangle(cornerRadius: RadiusToken.md.rawValue)
                .fill(editorTheme.color(.surface))
                .frame(height: 60)
                .shadow(
                    color: .black.opacity(selectedElevation.shadowOpacity),
                    radius: selectedElevation.shadowRadius,
                    y: selectedElevation.shadowY
                )
                .padding(8)
        }
    }

    // MARK: - Motion

    @ViewBuilder
    private var motionSection: some View {
        Section("Motion") {
            Picker("Preview Duration", selection: $selectedMotion) {
                ForEach(MotionToken.allCases, id: \.self) { token in
                    Text(String(describing: token)).tag(token)
                }
            }
        }
    }

    // MARK: - Preview

    @ViewBuilder
    private var previewSection: some View {
        Section("Live Preview") {
            Toggle("Dark Mode", isOn: $previewDarkMode)
            VStack(spacing: SpacingToken.md.rawValue) {
                Text("Sample Heading")
                    .font(TypographyToken.title.font)
                    .foregroundStyle(editorTheme.color(.onBackground))
                Text("Body text using your theme configuration.")
                    .font(TypographyToken.body.font)
                    .foregroundStyle(editorTheme.color(.onBackgroundSecondary))
                HStack(spacing: SpacingToken.sm.rawValue) {
                    Circle()
                        .fill(editorTheme.color(.brand))
                        .frame(width: 32, height: 32)
                    Circle()
                        .fill(editorTheme.color(.interactive))
                        .frame(width: 32, height: 32)
                    Circle()
                        .fill(editorTheme.color(.success))
                        .frame(width: 32, height: 32)
                    Circle()
                        .fill(editorTheme.color(.warning))
                        .frame(width: 32, height: 32)
                    Circle()
                        .fill(editorTheme.color(.error))
                        .frame(width: 32, height: 32)
                }
                PrismButton("Primary Action", variant: .filled) {}
            }
            .padding(SpacingToken.md.rawValue)
            .background(editorTheme.color(.background), in: RadiusToken.lg.shape)
            .preferredColorScheme(previewDarkMode ? .dark : .light)
            .prismTheme(editorTheme)
        }
    }

    // MARK: - Export

    @ViewBuilder
    private var exportSection: some View {
        Section {
            Button("Export Theme as JSON") {
                showExport = true
            }
        }
    }

    @ViewBuilder
    private var exportView: some View {
        NavigationStack {
            ScrollView {
                if let json = PrismTokenExport.toJSONString(theme: editorTheme) {
                    Text(json)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .textSelection(.enabled)
                } else {
                    Text("Failed to generate JSON")
                }
            }
            .navigationTitle("Theme Export")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { showExport = false }
                }
            }
            #endif
        }
    }
}
