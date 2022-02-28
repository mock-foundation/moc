import Foundation
import os

/// Logging implementation. Uses os.Logger under the hood.
public struct Logger {
    private let logger: os.Logger

    public init(label: String, category: String) {
        self.logger = os.Logger(subsystem: label, category: category)
    }

    public func log(_ message: String?, level: LogLevel) {
        #if DEBUG
        switch level {
            case .trace:
                logger.trace("\(String(describing: message))")
            case .debug:
                logger.debug("\(String(describing: message))")
            case .info:
                logger.info("\(String(describing: message))")
            case .notice:
                logger.notice("\(String(describing: message))")
            case .warning:
                logger.warning("\(String(describing: message))")
            case .error:
                logger.error("\(String(describing: message))")
            case .critical:
                logger.critical("\(String(describing: message))")
        }
        #endif
    }

    public func trace(_ message: String?) {
        log(message, level: .trace)
    }

    public func debug(_ message: String?) {
        log(message, level: .debug)
    }

    public func info(_ message: String?) {
        log(message, level: .info)
    }

    public func notice(_ message: String?) {
        log(message, level: .notice)
    }

    public func warning(_ message: String?) {
        log(message, level: .warning)
    }

    public func error(_ message: String?) {
        log(message, level: .error)
    }

    public func critical(_ message: String?) {
        log(message, level: .critical)
    }
}
