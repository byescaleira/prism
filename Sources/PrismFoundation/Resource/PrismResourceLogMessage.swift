//
//  PrismResourceLogMessage.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/07/25.
//

import os

/// A protocol for localizable log messages.
public protocol PrismResourceLogMessage {
    /// The resolved string content of this log message.
    var value: String { get }
}
