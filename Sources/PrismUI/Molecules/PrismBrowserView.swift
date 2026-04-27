//
//  PrismBrowserView.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import SwiftUI

#if canImport(WebKit)
    import WebKit
#endif
#if canImport(SafariServices)
    import SafariServices
#endif

/// Web navigation view for the PrismUI Design System.
///
/// `PrismBrowserView` is a component for displaying web content via:
/// - Modal sheet with `SFSafariViewController` (iOS)
/// - Embedded `WKWebView` (macOS)
/// - Optional URL binding for presentation control
///
/// ## Basic Usage
/// ```swift
/// @State var url: URL?
/// PrismBrowserView(url: $url) {
///     PrismPrimaryButton("Open website") {
///         url = URL(string: "https://example.com")
///     }
/// }
/// ```
///
/// ## With Custom Content
/// ```swift
/// PrismBrowserView(url: $url) {
///     VStack {
///         PrismText("Tap to open")
///         PrismPrimaryButton("Visit") {
///             url = URL(string: "https://example.com")
///         }
///     }
/// }
/// ```
///
/// ## Platform Behavior
/// - **iOS**: Opens in `SFSafariViewController` within a sheet
/// - **macOS**: Opens in an embedded `WKWebView` within a sheet
///
/// - Note: The sheet automatically dismisses when `url` is set to `nil`.
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

#elseif canImport(AppKit) && canImport(WebKit)
    /// macOS browser view backed by `WKWebView`.
    ///
    /// Renders web content inline instead of opening the system browser,
    /// so the sheet displays the page directly within the app.
    struct PrismBrowser: NSViewRepresentable {
        let url: URL

        func makeNSView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.allowsBackForwardNavigationGestures = true
            webView.load(URLRequest(url: url))
            return webView
        }

        func updateNSView(
            _ webView: WKWebView,
            context: Context
        ) {
            // Reload only when the URL actually changes to avoid
            // unnecessary network requests on unrelated state updates.
            if webView.url != url {
                webView.load(URLRequest(url: url))
            }
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
