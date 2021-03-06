import Foundation
import os

/// Logging implementation. Uses os.Logger under the hood.
public struct Logger {
    private let logger: os.Logger

    public init(category: String, label: String) {
        self.logger = os.Logger(subsystem: label, category: category)
    }

    public func log(_ message: String, level: LogLevel) {
        switch level {
            case .trace:
                logger.trace("[trace] \(message)")
            case .debug:
                logger.debug("[debug] \(message)")
            case .info:
                logger.info("[info] \(message)")
            case .notice:
                logger.notice("[notice] \(message)")
            case .warning:
                logger.warning("[warning] \(message)")
            case .error:
                logger.error("[error] \(message)")
            case .critical:
                logger.critical("[critical] \(message)")
        }
    }

    public func trace(_ message: String) {
        #if DEBUG
        log(message, level: .trace)
        #endif
    }

    public func debug(_ message: String) {
        #if DEBUG
        log(message, level: .debug)
        #endif
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
