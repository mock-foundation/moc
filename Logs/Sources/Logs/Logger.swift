import Foundation
import os

/// Logging implementation. Uses os.Logger under the hood.
public struct Logger {
    private let logger: os.Logger
    private let label: String

    public init(category: String, label: String) {
        self.logger = os.Logger(subsystem: label, category: category)
        self.label = label
    }

    public func log(_ message: Any, level: LogLevel) {
        switch level {
            case .trace:
                logger.trace("[\(label)] [trace] \(String(describing: message))")
            case .debug:
                logger.debug("[\(label)] [debug] \(String(describing: message))")
            case .info:
                logger.info("[\(label)] [info] \(String(describing: message))")
            case .notice:
                logger.notice("[\(label)] [notice] \(String(describing: message))")
            case .warning:
                logger.warning("[\(label)] [warning] \(String(describing: message))")
            case .error:
                logger.error("[\(label)] [error] \(String(describing: message))")
            case .critical:
                logger.critical("[\(label)] [critical] \(String(describing: message))")
        }
    }

    public func trace(_ message: Any) {
        #if DEBUG
        log(message, level: .trace)
        #endif
    }

    public func debug(_ message: Any) {
        #if DEBUG
        log(message, level: .debug)
        #endif
    }

    public func info(_ message: Any) {
        log(message, level: .info)
    }

    public func notice(_ message: Any) {
        log(message, level: .notice)
    }

    public func warning(_ message: Any) {
        log(message, level: .warning)
    }

    public func error(_ message: Any) {
        log(message, level: .error)
    }

    public func critical(_ message: Any) {
        log(message, level: .critical)
    }
}
