import SwiftUI
import Testing

@testable import PrismUI

struct FormTests {

    // MARK: - PrismToggle

    @Test
    func toggleCreatesWithBinding() {
        @State var isOn = false
        let toggle = PrismToggle("Notifications", isOn: $isOn)
        #expect(toggle != nil)
    }

    @Test
    func toggleSupportsIconAndDescription() {
        @State var isOn = true
        let toggle = PrismToggle(
            "Dark Mode",
            isOn: $isOn,
            description: "Enable dark appearance",
            icon: "moon.fill"
        )
        #expect(toggle != nil)
    }

    // MARK: - PrismSecureField

    @Test
    func secureFieldCreatesWithBinding() {
        @State var password = ""
        let field = PrismSecureField("Password", text: $password)
        #expect(field != nil)
    }

    // MARK: - PrismSlider

    @Test
    func sliderCreatesWithRange() {
        @State var value = 50.0
        let slider = PrismSlider("Volume", value: $value, in: 0...100)
        #expect(slider != nil)
    }

    @Test
    func sliderSupportsStep() {
        @State var value = 5.0
        let slider = PrismSlider("Rating", value: $value, in: 1...10, step: 1)
        #expect(slider != nil)
    }

    // MARK: - PrismPicker

    @Test
    func pickerCreatesWithSelection() {
        @State var selection = 0
        let picker = PrismPicker("Theme", selection: $selection, icon: "paintbrush") {
            Text("Light").tag(0)
            Text("Dark").tag(1)
        }
        #expect(picker != nil)
    }

    // MARK: - PrismDatePicker

    @Test
    func datePickerCreatesWithSelection() {
        @State var date = Date()
        let picker = PrismDatePicker("Birthday", selection: $date, icon: "calendar")
        #expect(picker != nil)
    }

    @Test
    func datePickerSupportsRange() {
        @State var date = Date()
        let range = Date.distantPast...Date.now
        let picker = PrismDatePicker("Start", selection: $date, in: range)
        #expect(picker != nil)
    }
}
