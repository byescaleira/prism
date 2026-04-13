//
//  RyzePlaygroundHome.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeFoundation
import RyzeIntelligence
import RyzeUI
import SwiftUI

private struct HomeSearchConfiguration: RyzeTextFieldConfiguration {
    var placeholder: RyzeResourceString { CustomString("Buscar componentes...") }
    var mask: RyzeTextFieldMask? { nil }
    var icon: String? { "magnifyingglass" }
    var contentType: RyzeTextFieldContentType { .default }
    var autocapitalizationType: RyzeTextInputAutocapitalization { .never }
    var submitLabel: SubmitLabel { .done }

    func validate(text: String) throws {}
}

private struct CustomString: RyzeResourceString {
    let value: String
    var localized: LocalizedStringKey { LocalizedStringKey(value) }

    init(_ value: String) {
        self.value = value
    }
}

struct RyzePlaygroundHome: View {
    @Environment(\.theme) private var theme
    @State private var searchText = ""
    @State private var selectedCategory: PlaygroundCategory?

    private let categories: [PlaygroundCategory] = [
        .atoms,
        .molecules,
        .modifiers,
        .patterns,
    ]

    var body: some View {
        RyzeNavigationView(
            router: .init(),
            destination: { (route: PlaygroundRoute) in
                route.destinationView()
            },
            content: {
                homeContent
            }
        )
    }

    private var homeContent: some View {
        RyzeLazyList {
            headerSection

            searchSection

            categoriesSection

            quickDemosSection

            intelligenceSection
        }
        .navigationTitle("RyzePlayground")
    }

    // MARK: - Header

    private var headerSection: some View {
        RyzeVStack(alignment: .leading, spacing: .medium) {
            RyzeHStack(spacing: .small) {
                RyzeSymbol("sparkles", mode: .hierarchical)
                    .ryze(color: .primary)
                    .ryze(font: .title)

                RyzeText("Design System Interativo")
                    .ryze(font: .title)
                    .ryze(color: .primary)
            }

            RyzeBodyText(
                "Explore todos os componentes do RyzeUI com exemplos interativos e documentação inteligente."
            )
        }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 20))
    }

    // MARK: - Search

    private var searchSection: some View {
        RyzeHStack(spacing: .small) {
            RyzeSymbol("magnifyingglass")
                .ryze(color: .textSecondary)

            RyzeTextField(
                text: $searchText,
                configuration: HomeSearchConfiguration(),
                accessibility: {
                    $0.label("Buscar componentes")
                        .testID("search_field")
                }
            )
        }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 20))
    }

    // MARK: - Categories

    private var categoriesSection: some View {
        RyzeVStack(alignment: .leading, spacing: .medium) {
            RyzeText("Categorias")
                .ryze(font: .headline)
                .ryzePadding(.bottom, .small)

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 150, maximum: 200), spacing: theme.spacing.medium),
                ],
                spacing: theme.spacing.medium
            ) {
                ForEach(categories, id: \.self) { category in
                    CategoryCard(category: category)
                        .onTapGesture {
                            selectedCategory = category
                        }
                }
            }
        }
        .ryzePadding()
    }

    // MARK: - Quick Demos

    private var quickDemosSection: some View {
        RyzeVStack(alignment: .leading, spacing: .medium) {
            RyzeHStack {
                RyzeText("Demos Rápidas")
                    .ryze(font: .headline)

                RyzeSpacer()

                RyzeFootnoteText("Ver todos")
                    .ryze(color: .primary)
            }

            RyzeHStack(spacing: .medium) {
                QuickDemoCard(
                    title: "Buttons",
                    icon: "rectangle.fill.on.rectangle.angled.fill",
                    color: .primary
                )

                QuickDemoCard(
                    title: "Text Fields",
                    icon: "textformat",
                    color: .secondary
                )

                QuickDemoCard(
                    title: "Effects",
                    icon: "sparkles",
                    color: RyzeColor.warning
                )
            }
        }
        .ryzePadding()
    }

    // MARK: - Intelligence

    private var intelligenceSection: some View {
        RyzeVStack(alignment: .leading, spacing: .medium) {
            RyzeHStack {
                RyzeSymbol("brain.headset")
                    .ryze(color: .primary)

                RyzeText("Ryze Intelligence")
                    .ryze(font: .headline)
            }

            RyzeBodyText(
                "Obtenha explicações inteligentes sobre cada componente, incluindo melhores práticas, padrões de uso e exemplos de código."
            )

            RyzePrimaryButton("Explorar Intelligence", testID: "explore_intelligence_button") {
                // Navegar para tela de intelligence
            }
            .ryze(width: .max)
        }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 20))
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    @Environment(\.theme) private var theme
    let category: PlaygroundCategory

    var body: some View {
        RyzeVStack(alignment: .leading, spacing: .small) {
            RyzeSymbol(category.icon, mode: .hierarchical)
                .ryze(font: .title2)
                .ryze(color: category.color)

            RyzeText(category.title)
                .ryze(font: .headline)

            RyzeFootnoteText("\(category.componentCount) componentes")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 12))
    }
}

// MARK: - Quick Demo Card

private struct QuickDemoCard: View {
    let title: String
    let icon: String
    let color: RyzeColor

    var body: some View {
        RyzeVStack(spacing: .small) {
            RyzeSymbol(icon, mode: .hierarchical)
                .ryze(font: .title2)
                .ryze(color: color)

            RyzeFootnoteText(title)
        }
        .frame(maxWidth: .infinity)
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 12))
    }
}

// MARK: - Preview

#Preview {
    RyzePlaygroundHome()
        .ryze(theme: RyzePlaygroundTheme())
}
