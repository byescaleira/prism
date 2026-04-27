//
//  PrismAnalyticsTrackModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import PrismFoundation
import SwiftUI

struct PrismAnalyticsTrackModifier: ViewModifier {
    @Environment(\.analyticsProvider) private var analyticsProvider

    let event: PrismAnalyticsEvent

    func body(content: Content) -> some View {
        content
            .onAppear {
                analyticsProvider?.track(event)
            }
    }
}
