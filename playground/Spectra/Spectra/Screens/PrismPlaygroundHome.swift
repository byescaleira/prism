//
//  PrismPlaygroundHome.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismFoundation
import PrismIntelligence
import PrismArchitecture
import PrismUI
import SwiftUI

private struct HomeSearchConfiguration: PrismTextFieldConfiguration {
    var placeholder: PrismResourceString { CustomString("Buscar componentes...") }
    var mask: PrismTextFieldMask? { nil }
    var icon: String? { "magnifyingglass" }
    var contentType: PrismTextFieldContentType { .default }
    var autocapitalizationType: PrismTextInputAutocapitalization { .never }
    var submitLabel: SubmitLabel { .done }

    func validate(text: String) throws {}
}

private struct CustomString: PrismResourceString {
    let value: String
    var localized: LocalizedStringKey { LocalizedStringKey(value) }

    init(_ value: String) {
        self.value = value
    }
}

struct PrismPlaygroundHome: View {
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
        PrismNavigationView(
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
        PrismLazyList {
            headerSection

            searchSection

            categoriesSection

            quickDemosSection

            intelligenceSection
        }
        .navigationTitle("PrismPlayground")
    }

    // MARK: - Header

    private var headerSection: some View {
        PrismVStack(alignment: .leading, spacing: .medium) {
            PrismHStack(spacing: .small) {
                PrismSymbol("sparkles", mode: .hierarchical)
                    .prism(color: .primary)
                    .prism(font: .title)

                PrismText("Design System Interativo")
                    .prism(font: .title)
                    .prism(color: .primary)
            }

            PrismBodyText(
                "Explore todos os componentes do PrismUI com exemplos interativos e documentação inteligente."
            )
        }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 20))
    }

    // MARK: - Search

    private var searchSection: some View {
        PrismHStack(spacing: .small) {
            PrismSymbol("magnifyingglass")
                .prism(color: .textSecondary)

            PrismTextField(
                text: $searchText,
                configuration: HomeSearchConfiguration(),
                accessibility: {
                    $0.label("Buscar componentes")
                        .testID("search_field")
                }
            )
        }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 20))
    }

    // MARK: - Categories

    private var categoriesSection: some View {
        PrismVStack(alignment: .leading, spacing: .medium) {
            PrismText("Categorias")
                .prism(font: .headline)
                .prismPadding(.bottom, .small)

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
        .prismPadding()
    }

    // MARK: - Quick Demos

    private var quickDemosSection: some View {
        PrismVStack(alignment: .leading, spacing: .medium) {
            PrismHStack {
                PrismText("Demos Rápidas")
                    .prism(font: .headline)

                PrismSpacer()

                PrismFootnoteText("Ver todos")
                    .prism(color: .primary)
            }

            PrismHStack(spacing: .medium) {
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
                    color: PrismColor.warning
                )
            }
        }
        .prismPadding()
    }

    // MARK: - Intelligence

    private var intelligenceSection: some View {
        PrismVStack(alignment: .leading, spacing: .medium) {
            PrismHStack {
                PrismSymbol("brain.headset")
                    .prism(color: .primary)

                PrismText("Prism Intelligence")
                    .prism(font: .headline)
            }

            PrismBodyText(
                "Obtenha explicações inteligentes sobre cada componente, incluindo melhores práticas, padrões de uso e exemplos de código."
            )

            PrismPrimaryButton("Explorar Intelligence", testID: "explore_intelligence_button") {
                // Navegar para tela de intelligence
            }
            .prism(width: .max)
        }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 20))
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    @Environment(\.theme) private var theme
    let category: PlaygroundCategory

    var body: some View {
        PrismVStack(alignment: .leading, spacing: .small) {
            PrismSymbol(category.icon, mode: .hierarchical)
                .prism(font: .title2)
                .prism(color: category.color)

            PrismText(category.title)
                .prism(font: .headline)

            PrismFootnoteText("\(category.componentCount) componentes")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 12))
    }
}

// MARK: - Quick Demo Card

private struct QuickDemoCard: View {
    let title: String
    let icon: String
    let color: PrismColor

    var body: some View {
        PrismVStack(spacing: .small) {
            PrismSymbol(icon, mode: .hierarchical)
                .prism(font: .title2)
                .prism(color: color)

            PrismFootnoteText(title)
        }
        .frame(maxWidth: .infinity)
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 12))
    }
}

// MARK: - Preview

#Preview {
    PrismPlaygroundHome()
        .prism(theme: PrismPlaygroundTheme())
}
