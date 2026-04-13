//
//  PrismAccessibilityTests.swift
//  PrismUITests
//
//  Created by Rafael Escaleira on 09/04/26.
//

import PrismUI
import SwiftUI
import XCTest

/// Testes de unidade para verificar que as propriedades de acessibilidade
/// são criadas corretamente
final class PrismAccessibilityTests: XCTestCase {

    // MARK: - PrismAccessibilityProperties Tests

    func testButtonConvenience() {
        let accessibility = PrismAccessibility.button(
            "Entrar",
            testID: "login_button",
            hint: "Toque para fazer login"
        )

        XCTAssertEqual(accessibility.testID, "login_button")
        XCTAssertTrue(accessibility.traits.contains(.allowsDirectInteraction))
    }

    func testTextFieldConvenience() {
        let accessibility = PrismAccessibility.textField(
            "Email",
            testID: "email_field",
            value: "usuario@exemplo.com"
        )

        XCTAssertEqual(accessibility.testID, "email_field")
        XCTAssertTrue(accessibility.traits.contains(.isStaticText))
        XCTAssertNotNil(accessibility.value)
    }

    func testHeaderConvenience() {
        let accessibility = PrismAccessibility.header(
            "Bem-vindo",
            testID: "welcome_header",
            level: 1
        )

        XCTAssertEqual(accessibility.testID, "welcome_header")
        XCTAssertTrue(accessibility.traits.contains(.isHeader))
    }

    func testImageConvenience() {
        let accessibility = PrismAccessibility.image(
            "Logo da empresa",
            testID: "company_logo"
        )

        XCTAssertEqual(accessibility.testID, "company_logo")
        XCTAssertEqual(accessibility.traits, [])
    }

    func testCustomConvenience() {
        let accessibility = PrismAccessibility.custom(
            label: "Custom Element",
            testID: "custom_element",
            hint: "This is a custom element",
            traits: [.updatesFrequently]
        )

        XCTAssertEqual(accessibility.testID, "custom_element")
        XCTAssertTrue(accessibility.traits.contains(.updatesFrequently))
    }

    func testHiddenConvenience() {
        let accessibility = PrismAccessibility.hidden(testID: "hidden_element")

        XCTAssertEqual(accessibility.testID, "hidden_element")
        XCTAssertTrue(accessibility.isHidden)
    }

    // MARK: - PrismAccessibilityConfig Tests

    func testBuilderPattern() {
        let accessibility = PrismAccessibilityConfig()
            .label("Email")
            .hint("Digite seu email")
            .testID("email_field")
            .traits([.isStaticText, .updatesFrequently])
            .build()

        XCTAssertEqual(accessibility.testID, "email_field")
        XCTAssertTrue(accessibility.traits.contains(.isStaticText))
        XCTAssertTrue(accessibility.traits.contains(.updatesFrequently))
    }

    func testBuilderWithConvenienceMethods() {
        let accessibility = PrismAccessibilityConfig()
            .label("Slider")
            .testID("volume_slider")
            .asAdjustable()
            .action(.adjust(handler: { true }))
            .build()

        XCTAssertTrue(accessibility.traits.contains(.updatesFrequently))
        XCTAssertEqual(accessibility.actions.count, 1)
    }

    func testBuilderWithInputLabels() {
        let accessibility = PrismAccessibilityConfig()
            .label("Confirmação de senha")
            .testID("password_confirm")
            .inputLabels(["Senha", "Confirme sua senha"])
            .build()

        XCTAssertEqual(accessibility.inputLabels.count, 2)
    }

    func testBuilderWithActions() {
        let accessibility = PrismAccessibilityConfig()
            .label("Item")
            .testID("list_item")
            .action(
                .delete {
                    return true
                }
            )
            .build()

        // Execute the action
        let result = accessibility.actions.first?.handler()

        XCTAssertTrue(result ?? false)
    }

    // MARK: - Default Values Tests

    func testDefaultValues() {
        let accessibility = PrismAccessibilityProperties(
            label: "Test",
            testID: "test_id"
        )

        XCTAssertEqual(accessibility.hint, "")
        XCTAssertEqual(accessibility.traits, [])
        XCTAssertEqual(accessibility.actions.count, 0)
        XCTAssertEqual(accessibility.inputLabels.count, 0)
        XCTAssertNil(accessibility.value)
        XCTAssertFalse(accessibility.isHidden)
    }
}
