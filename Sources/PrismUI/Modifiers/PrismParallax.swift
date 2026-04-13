//
//  PrismParallax.swift
//  Prism
//
//  Created by Rafael Escaleira on 07/06/25.
//

import SwiftUI

#if os(iOS)
    import CoreMotion

    /// Modificador de efeito parallax (movimento 3D) do Design System PrismUI.
    ///
    /// `PrismParallaxModifier` cria efeito de profundidade usando o giroscópio:
    /// - Rotação 3D baseada no movimento do dispositivo
    /// - Brilho dinâmico (shine) que segue a inclinação
    /// - Sensibilidade ajustável via threshold
    /// - Suporte a customização de largura e altura
    ///
    /// ## Uso Básico
    /// ```swift
    /// PrismSymbol("rainbow")
    ///     .prismParallax(height: .medium2)
    /// ```
    ///
    /// ## Como Funciona
    /// - Usa `CMMotionManager` para ler dados do giroscópio
    /// - Aplica rotação nos eixos X (pitch) e Y (roll)
    /// - Cria efeito de brilho que se move com a inclinação
    /// - Atualiza a 60Hz para animação suave
    ///
    /// ## Limites de Rotação
    /// - Threshold: 35° - ângulo mínimo para ativar efeito
    /// - Max rotation: 20° - rotação máxima aplicada
    ///
    /// - Note: Disponível apenas para iOS. O efeito requer dispositivo físico com giroscópio.
    struct PrismParallaxModifier: ViewModifier {
        @Environment(\.theme) var theme
        @State var motion: CMDeviceMotion? = nil

        let motionManager: CMMotionManager = CMMotionManager()
        let threshold: Double = 35 * .pi / 180
        let maxRotationAngle: Double = 20
        let width: PrismSize?
        let height: PrismSize?

        init(
            width: PrismSize?,
            height: PrismSize?
        ) {
            self.width = width
            self.height = height
        }

        var rotation: CGPoint {
            guard let motion else { return .zero }
            let pitch = min(
                maxRotationAngle,
                motion.attitude.pitch > threshold ? (motion.attitude.pitch - threshold) * (100 / .pi) : .zero)
            let roll = min(maxRotationAngle, motion.attitude.roll * (100 / .pi))
            return .init(x: -pitch, y: roll)
        }

        var circleYOffset: CGFloat {
            guard let motion,
                motion.attitude.pitch > threshold
            else { return .zero }
            let offset = (motion.attitude.pitch - threshold) * (600 / .pi)
            return CGFloat(offset)
        }

        var widthValue: CGFloat? {
            width?.rawValue(for: theme.size)
        }

        var heightValue: CGFloat? {
            height?.rawValue(for: theme.size)
        }

        func body(content: Content) -> some View {
            PrismZStack {
                content
                    .scaledToFit()
                    .prism(width: width, height: height)
                    .rotation3DEffect(
                        .degrees(rotation.x),
                        axis: (x: 1, y: .zero, z: .zero)
                    )
                    .rotation3DEffect(
                        .degrees(rotation.y),
                        axis: (x: .zero, y: 1, z: .zero)
                    )

                shineView
            }
            .onAppear(perform: onAppear)
        }

        private func onAppear() {
            guard motionManager.isDeviceMotionAvailable else { return }
            motionManager.deviceMotionUpdateInterval = 1 / 60
            motionManager.startDeviceMotionUpdates(to: .init()) { motion, error in
                if let motion {
                    self.motion = motion
                }
            }
        }

        private var shineView: some View {
            PrismShape(shape: .circle)
                .fill(.white.opacity(0.6))
                .frame(
                    width: width != nil ? widthValue ?? .zero * 0.233 : nil,
                    height: height != nil ? heightValue ?? .zero * 0.233 : nil
                )
                .blur(radius: min(widthValue ?? .zero, heightValue ?? .zero) * 0.133)
                .offset(
                    x: motion != nil ? motion?.gravity.x ?? .zero * 400 : .zero,
                    y: circleYOffset
                )
                .mask { shineMaskView }
        }

        private var shineMaskView: some View {
            PrismShape(shape: .rect(cornerRadius: theme.radius.large))
                .prism(width: width, height: height)
                .rotation3DEffect(
                    .degrees(rotation.x),
                    axis: (x: 1, y: .zero, z: .zero)
                )
                .rotation3DEffect(
                    .degrees(rotation.y),
                    axis: (x: .zero, y: 1, z: .zero)
                )
        }

        static func mocked() -> some View {
            PrismSymbol("rainbow")
                .prism(font: .system(size: 50))
                .prismPadding(.extraLarge)
                .prismParallax(height: .medium2)
        }
    }

    #Preview {
        PrismParallaxModifier.mocked()
    }
#endif
