//
//  PrismNetworkLogger.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/07/25.
//

import PrismFoundation
import os

struct PrismNetworkLogger: PrismSystemLogger {
    typealias Message = PrismNetworkLogMessage

    var logger: Logger

    init(logger: Logger = .init()) {
        self.logger = logger
    }

    func info(_ message: Message) {
        logger.info("\(message.value)")
    }

    func warning(_ message: Message) {
        logger.warning("\(message.value)")
    }

    func error(_ message: Message) {
        logger.error("\(message.value)")
    }

    func info(_ message: String) {
        logger.info("\(message)")
    }

    func warning(_ message: String) {
        logger.warning("\(message)")
    }

    func error(_ message: String) {
        logger.error("\(message)")
    }
}
