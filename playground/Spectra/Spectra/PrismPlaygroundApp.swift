//
//  PrismPlaygroundApp.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

@main
public struct PrismPlaygroundApp: App {
    @State private var theme = PrismPlaygroundTheme()
    
    public init() {}

    public var body: some Scene {
        WindowGroup {
            PrismPlaygroundHome()
                .prism(theme: theme)
                .prismBackground()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 800)
        #endif
    }
}
