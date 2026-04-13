import os

enum PrismFoundationLogMessage: PrismResourceLogMessage {
    case message(String)
    case error(Error)

    var value: String {
        switch self {
        case .message(let string): return string
        case .error(let error): return error.localizedDescription
        }
    }
}
