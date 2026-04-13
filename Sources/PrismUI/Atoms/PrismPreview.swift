//
//  PrismPreview.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import PrismFoundation
import SwiftUI

/// Preview abrangente do Design System PrismUI.
///
/// `PrismPreview` gera automaticamente previews para todos os cenários:
/// - Light mode e Dark mode
/// - Português (BR) e Inglês (US)
/// - Retrato e Paisagem
/// - Size That Fits e Device layout
///
/// ## Uso Básico
/// ```swift
/// #Preview {
///     PrismPreview(content: PrismButton.self)
/// }
/// ```
///
/// ## O Que é Gerado
/// O preview gera uma matriz completa de combinações:
/// - 2 color schemes × 2 locales × 2 orientations × 2 layouts = **16 previews**
///
/// ## Para Componentes Personalizados
/// ```swift
/// struct MyComponent: PrismView {
///     // ...
///     static func mocked() -> some View {
///         MyComponent(...)
///     }
/// }
///
/// #Preview {
///     PrismPreview(content: MyComponent.self)
/// }
/// ```
///
/// - Note: Requer que o componente tenha `static func mocked()` implementado.
/// - Important: Use para validar componentes em todos os cenários antes de commit.
public struct PrismPreview<Content: PrismView>: View {
    let colorSchemes: [ColorScheme] = [.light, .dark]
    let locales: [PrismLocale] = [.portugueseBR, .englishUS]
    let orientations: [InterfaceOrientation] = [.portrait, .landscapeRight]
    let layouts: [PreviewLayout] = [.sizeThatFits, .device]
    let content: Content.Type

    public init(content: Content.Type) {
        self.content = content
    }

    public var body: some View {
        Group {
            ForEach(locales.indices, id: \.self) {
                let locale = locales[$0]
                ForEach(orientations.indices, id: \.self) {
                    let orientation = orientations[$0]
                    ForEach(layouts.indices, id: \.self) {
                        let layout = layouts[$0]
                        ForEach(colorSchemes.indices, id: \.self) {
                            let colorScheme = colorSchemes[$0]
                            content.mocked()
                                .prismPreview(
                                    layout: layout,
                                    orientation: orientation,
                                    colorScheme: colorScheme,
                                    locale: locale
                                )
                        }
                    }
                }
            }
        }
    }
}
