//
//  PrismBrowserView.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif
#if canImport(SafariServices)
    import SafariServices
#endif

/// View de navegação web do Design System PrismUI.
///
/// `PrismBrowserView` é um componente para exibir conteúdo web em:
/// - Sheet modal com `SFSafariViewController` (iOS)
/// - Navegador nativo (macOS)
/// - Binding de URL opcional para controle de apresentação
///
/// ## Uso Básico
/// ```swift
/// @State var url: URL?
/// PrismBrowserView(url: $url) {
///     PrismPrimaryButton("Abrir site") {
///         url = URL(string: "https://example.com")
///     }
/// }
/// ```
///
/// ## Com Conteúdo Personalizado
/// ```swift
/// PrismBrowserView(url: $url) {
///     VStack {
///         PrismText("Clique para abrir")
///         PrismPrimaryButton("Visitar") {
///             url = URL(string: "https://example.com")
///         }
///     }
/// }
/// ```
///
/// ## Comportamento por Plataforma
/// - **iOS**: Abre em `SFSafariViewController` dentro de um sheet
/// - **macOS**: Abre no navegador padrão do sistema
///
/// - Note: O sheet fecha automaticamente quando `url` é definido como `nil`.
public struct PrismBrowserView<Content: View>: View {
    @Binding private var url: URL?
    let content: Content
    private var isPresented: Binding<Bool> {
        Binding(
            get: { url != nil },
            set: { isPresented in
                if !isPresented {
                    url = nil
                }
            }
        )
    }

    public init(
        url: Binding<URL?>,
        @ViewBuilder content: () -> Content
    ) {
        self._url = url
        self.content = content()
    }

    public var body: some View {
        content
            .sheet(isPresented: isPresented) {
                if let url {
                    PrismBrowser(url: url)
                }
            }
    }
}

#if canImport(UIKit) && canImport(SafariServices)
    struct PrismBrowser: UIViewControllerRepresentable {
        let url: URL

        func makeUIViewController(context: Context) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }

        func updateUIViewController(
            _ uiViewController: SFSafariViewController,
            context: Context
        ) {
            return
        }
    }

#elseif canImport(AppKit)
    struct PrismBrowser: NSViewRepresentable {
        let url: URL

        func updateNSView(
            _ nsView: NSView,
            context: NSViewRepresentableContext<PrismBrowser>
        ) {
            _ = nsView
            NSWorkspace.shared.open(url)
        }

        func makeNSView(context: Context) -> NSView {
            return .init()
        }
    }

#else
    struct PrismBrowser: View {
        let url: URL

        var body: some View {
            EmptyView()
        }
    }

#endif
