//
//  RyzeCurrencyTextField.swift
//  Ryze
//
//  Created by Rafael Escaleira on 02/09/25.
//

import RyzeFoundation
import SwiftUI

/// Campo de texto para valores monetários do Design System RyzeUI.
///
/// `RyzeCurrencyTextField` é um input especializado para valores de moeda:
/// - Formatação automática no formato monetário (ex: R$ 1.234,56)
/// - Binding em `Double` para valor numérico
/// - Máscara de digitação em tempo real
/// - Locale configurável para diferentes moedas
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// @State var amount: Double = 0
/// RyzeCurrencyTextField(amount: $amount)
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeCurrencyTextField(
///     amount: $amount,
///     testID: "price_field"
/// )
/// ```
///
/// ## Com Locale Personalizado
/// ```swift
/// RyzeCurrencyTextField(
///     amount: $amount,
///     locale: .us  // USD: $1,234.56
/// )
/// ```
///
/// - Note: O campo formata automaticamente enquanto o usuário digita.
/// - Important: O binding armazena o valor numérico (Double), não o texto formatado.
public struct RyzeCurrencyTextField: RyzeView {
    @Binding var amount: Double
    @State var text: String = ""
    let locale: RyzeLocale
    public var accessibility: RyzeAccessibilityProperties?

    public init(
        amount: Binding<Double>,
        _ accessibility: RyzeAccessibilityProperties? = nil,
        locale: RyzeLocale = .current
    ) {
        self._amount = amount
        self.accessibility = accessibility
        self.locale = locale
    }

    public init(
        amount: Binding<Double>,
        testID: String,
        locale: RyzeLocale = .current
    ) {
        self._amount = amount
        self.accessibility = RyzeAccessibility.textField("Amount", testID: testID, value: "R$ 0,00")
        self.locale = locale
    }

    public var body: some View {
        TextField("", text: $text)
            .ryze(color: amount == .zero ? .textSecondary : .text)
            .onAppear {
                if text.isEmpty {
                    text = amount.currency() ?? ""
                }
            }
            .onChange(of: amount) { _, newValue in
                let formatted = newValue.currency() ?? ""
                if formatted != text { text = formatted }
            }
            .onChange(of: text) { _, newValue in
                let digits = newValue.compactMap(\.wholeNumberValue)
                let value = digits.reduce(0) { $0.double * 10 + $1.double } / 100
                if value != amount { amount = value }
                let masked = value.currency() ?? ""
                if masked != newValue { text = masked }
            }
            .ryze(accessibility)
    }

    public static func mocked() -> some View {
        RyzeCurrencyTextField(
            amount: .constant(.zero),
            locale: .current
        )
    }
}

#Preview {
    @Previewable @State var amount: Double = .zero
    RyzeCurrencyTextField(amount: $amount)
}
