import Foundation
import os

/// Logging implementation. Uses os.Logger under the hood.
public struct Logger {
    private let logger: os.Logger

    public init(label: String, category: String) {
        self.logger = os.Logger(subsystem: label, category: category)
    }

    public func log(_ message: String, level: LogLevel) {
        #if DEBUG
        switch level {
            case .trace:
                logger.trace("\(message)")
            case .debug:
                logger.debug("\(message)")
            case .info:
                logger.info("\(message)")
            case .notice:
                logger.notice("\(message)")
            case .warning:
                logger.warning("\(message)")
            case .error:
                logger.error("\(message)")
            case .critical:
                logger.critical("\(message)")
        }
        #endif
    }

    public func trace(_ message: String) {
        log(message, level: .trace)
    }

    public func debug(_ message: String) {
        log(message, level: .debug)
    }

    public func info(_ message: String) {
        log(message, level: .info)
    }

    public func notice(_ message: String) {
        log(message, level: .notice)
    }

    public func warning(_ message: String) {
        log(message, level: .warning)
    }

    public func error(_ message: String) {
        log(message, level: .error)
    }

    public func critical(_ message: String) {
        log(message, level: .critical)
    }
}
