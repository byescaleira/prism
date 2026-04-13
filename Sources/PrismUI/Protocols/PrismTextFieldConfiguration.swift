//
//  PrismTextFieldConfiguration.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/06/25.
//

import PrismFoundation
import SwiftUI

public protocol PrismTextFieldConfiguration {
    var placeholder: PrismResourceString { get }
    var mask: PrismTextFieldMask? { get }
    var icon: String? { get }
    var contentType: PrismTextFieldContentType { get }
    var autocapitalizationType: PrismTextInputAutocapitalization { get }
    var submitLabel: SubmitLabel { get }

    func validate(text: String) throws
}
