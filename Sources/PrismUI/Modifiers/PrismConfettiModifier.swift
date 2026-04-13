//
//  PrismConfettiModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/08/25.
//

import SwiftUI

/// Partícula individual de confetti do Design System PrismUI.
///
/// `PrismConfettiView` representa uma única partícula com:
/// - Cor aleatória (laranja, verde, azul, vermelho, amarelo)
/// - Rotação 3D em dois eixos (X e Z)
/// - Animação contínua de 360°
/// - Velocidade aleatória para efeito natural
private struct PrismConfettiView: View {
    @State var animate = false
    @State var xSpeed = Double.random(in: 0.7...2)
    @State var zSpeed = Double.random(in: 1...3)
    @State var anchor = CGFloat.random(in: 0...1).rounded()

    var body: some View {
        Rectangle()
            .fill(
                [
                    Color.orange,
                    Color.green,
                    Color.blue,
                    Color.red,
                    Color.yellow,
                ].randomElement() ?? .green
            )
            .frame(width: 9, height: 12)
            .onAppear { animate = true }
            .rotation3DEffect(
                .degrees(animate ? 360 : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .animation(
                Animation.linear(duration: xSpeed).repeatForever(autoreverses: false),
                value: animate
            )
            .rotation3DEffect(
                .degrees(animate ? 360 : 0),
                axis: (x: 0, y: 0, z: 1),
                anchor: UnitPoint(x: anchor, y: anchor)
            )
            .animation(
                Animation.linear(duration: zSpeed).repeatForever(autoreverses: false),
                value: animate
            )
    }
}

private struct PrismConfettiContainerView: View {
    let count: Int
    @State var yPosition: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<count, id: \.self) { _ in
                    PrismConfettiView()
                        .position(
                            x: CGFloat.random(in: 0...proxy.size.width),
                            y: yPosition != .zero ? CGFloat.random(in: 0...proxy.size.height) : yPosition
                        )
                }
            }
            .onAppear {
                yPosition = CGFloat.random(in: 0...proxy.size.height)
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    static func mocked() -> some View {
        PrismConfettiContainerView(count: 50)
    }
}

struct PrismConfettiModifier: ViewModifier {
    let amount: Int
    let seconds: Int
    let isActive: Bool

    public func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    PrismConfettiContainerView(count: amount)
                }
            }
            .sensoryFeedback(.success, trigger: isActive)
            .animation(.linear, value: isActive)
    }

    static func mocked() -> some View {
        PrismVStack {

        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .prismConfetti(amount: 60, isActive: true)
    }
}

#Preview {
    PrismConfettiModifier.mocked()
}
