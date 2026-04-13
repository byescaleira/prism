//
//  PrismFoundationLogger.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/07/25.
//

import os

struct PrismFoundationLogger: PrismSystemLogger {
    typealias Message = PrismFoundationLogMessage
    var logger: Logger

    init(logger: Logger = .init()) {
        self.logger = logger
    }

    func info(_ message: PrismFoundationLogMessage) {
        logger.info("\(message.value)")
    }

    func warning(_ message: PrismFoundationLogMessage) {
        logger.warning("\(message.value)")
    }

    func error(_ message: PrismFoundationLogMessage) {
        logger.error("\(message.value)")
    }
}
