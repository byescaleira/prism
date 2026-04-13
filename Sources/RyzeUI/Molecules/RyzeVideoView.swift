//
//  RyzeVideoView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import AVKit
import SwiftUI

/// Componente de reprodução de vídeo do Design System RyzeUI.
///
/// `RyzeVideoView` é um wrapper de `AVPlayer` com:
/// - Carregamento assíncrono de URL de vídeo
/// - Suporte a Picture in Picture (PiP)
/// - Controles nativos de plataforma
/// - Transição de escala ao aparecer
/// - Multi-plataforma (iOS, tvOS, macOS)
///
/// ## Uso Básico
/// ```swift
/// @State var videoURL: URL?
/// RyzeVideoView(url: $videoURL)
/// ```
///
/// ## Com Trigger de Reprodução
/// ```swift
/// RyzeVStack {
///     RyzePrimaryButton("Assistir") {
///         videoURL = URL(string: "https://example.com/video.mp4")
///     }
///     RyzeVideoView(url: $videoURL)
/// }
/// ```
///
/// ## Picture in Picture
/// - **iOS/tvOS**: Suporte automático via `canStartPictureInPictureAutomaticallyFromInline`
/// - **macOS**: Suporte via `allowsPictureInPicturePlayback`
///
/// ## Comportamento por Plataforma
/// - **iOS/tvOS**: `AVPlayerViewController` com controles touch
/// - **macOS**: `AVPlayerView` com controles de desktop
///
/// - Note: O player é criado automaticamente quando `url` é definido.
public struct RyzeVideoView: View {
    @State private var player: AVPlayer?
    @Binding private var url: URL?

    public init(url: Binding<URL?>) {
        self._url = url
    }

    public var body: some View {
        playerView
            .onChange(of: url) { updatePlayer() }
    }

    @ViewBuilder
    var playerView: some View {
        if let player {
            RyzeVideoPlayer(player: player)
                .transition(.scale)
        }
    }

    func updatePlayer() {
        guard let url else { return player = nil }
        player = AVPlayer(url: url)
    }
}

#if canImport(AppKit)
    struct RyzeVideoPlayer: NSViewRepresentable {
        let player: AVPlayer

        func updateNSView(
            _ NSView: NSView,
            context: NSViewRepresentableContext<RyzeVideoPlayer>
        ) {
            guard let view = NSView as? AVPlayerView else { return }
            view.player = player
            view.allowsPictureInPicturePlayback = true
        }

        func makeNSView(context: Context) -> NSView {
            return AVPlayerView(frame: .zero)
        }
    }

#elseif canImport(UIKit)
    struct RyzeVideoPlayer: UIViewControllerRepresentable {
        let player: AVPlayer

        func makeUIViewController(context: Context) -> AVPlayerViewController {
            let vc = AVPlayerViewController()
            vc.player = player
            #if os(tvOS)
            #else
                vc.canStartPictureInPictureAutomaticallyFromInline = true
            #endif
            return vc
        }

        func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
            uiViewController.player = player
        }
    }

#endif
