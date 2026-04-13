//
//  PrismDefaultTextFieldMask.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/06/25.
//

import Foundation
import SwiftUI

enum PrismDefaultTextFieldMask: PrismTextFieldMask {
    case phoneNumber
    case cpf
    case cnpj
    case cep
    case creditCardNumber
    case creditCardExpirationDate
    case creditCardCVV

    var rawValues: [String]? {
        switch self {
        case .phoneNumber:
            return ["(##) # ####-####", "(##) ####-####", "+## (##) # ####-####"]
        case .cpf:
            return ["###.###.###-##"]
        case .cnpj:
            return ["##.###.###/####-##"]
        case .cep:
            return ["#####-###"]
        case .creditCardNumber:
            return ["#### #### #### ####"]
        case .creditCardExpirationDate:
            return ["##/##"]
        case .creditCardCVV:
            return ["###"]
        }
    }
}
