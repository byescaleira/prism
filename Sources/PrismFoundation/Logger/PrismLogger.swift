//
//  PrismLogger.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import os

public protocol PrismLogger {
    func log()
}

public protocol PrismSystemLogger {
    associatedtype Message: PrismResourceLogMessage
    var logger: Logger { get }

    func info(_ message: Message)
    func warning(_ message: Message)
    func error(_ message: Message)
}
