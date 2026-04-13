//
//  Color+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 31/07/25.
//

import SwiftUI

extension Color {
    public init(hex: String?) {
        guard let hex else {
            self = .primary
            return
        }

        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            self = .primary
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        #if canImport(UIKit)
            let uiColor = UIColor(
                red: red,
                green: green,
                blue: blue,
                alpha: 1
            )
            self = Color(uiColor: uiColor)
        #elseif canImport(AppKit)
            let nsColor = NSColor(
                red: red,
                green: green,
                blue: blue,
                alpha: 1
            )
            self = Color(nsColor: nsColor)
        #else
            self = .primary
        #endif
    }

    public var hex: String {
        #if canImport(UIKit)
            let uiColor = UIColor(self)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0

            guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
                return "#F1F2F1"
            }

            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(red * 255)),
                lroundf(Float(green * 255)),
                lroundf(Float(blue * 255))
            )

        #elseif canImport(AppKit)
            let nsColor = NSColor(self)
            let rgbColor = nsColor.usingColorSpace(.deviceRGB)

            guard let rgbColor else { return "#F1F2F1" }

            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(rgbColor.redComponent * 255)),
                lroundf(Float(rgbColor.greenComponent * 255)),
                lroundf(Float(rgbColor.blueComponent * 255))
            )
        #else
            return "#F1F2F1"
        #endif
    }
}
