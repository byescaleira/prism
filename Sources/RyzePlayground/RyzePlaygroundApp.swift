//
//  RyzePlaygroundApp.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

@main
struct RyzePlaygroundApp: App {
    @State private var theme = RyzePlaygroundTheme()

    var body: some Scene {
        WindowGroup {
            RyzePlaygroundHome()
                .ryze(theme: theme)
                .ryzeBackground()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 800)
        #endif
    }
}
