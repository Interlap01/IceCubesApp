// Preview adapter for OSLog.
// The engine cannot compile Apple's OSLog, and dropping it would take
// MastodonClient and UserPreferences with it. Logging is a side effect the
// preview does not need to reproduce faithfully, so this maps Logger onto
// FileHandle.standardError and keeps those files in the build.

import Foundation

public struct OSLogType: Equatable, Sendable {
  public let rawValue: UInt8
  public init(rawValue: UInt8) { self.rawValue = rawValue }

  public static let `default` = OSLogType(rawValue: 0)
  public static let info = OSLogType(rawValue: 1)
  public static let debug = OSLogType(rawValue: 2)
  public static let error = OSLogType(rawValue: 16)
  public static let fault = OSLogType(rawValue: 17)

  var label: String {
    switch rawValue {
    case 1: "info"
    case 2: "debug"
    case 16: "error"
    case 17: "fault"
    default: "default"
    }
  }
}

public struct Logger: Sendable {
  private let subsystem: String
  private let category: String

  public init() {
    self.init(subsystem: "preview", category: "default")
  }

  public init(subsystem: String, category: String) {
    self.subsystem = subsystem
    self.category = category
  }

  public func log(_ message: String) { emit(.default, message) }
  public func log(level: OSLogType, _ message: String) { emit(level, message) }
  public func trace(_ message: String) { emit(.debug, message) }
  public func debug(_ message: String) { emit(.debug, message) }
  public func info(_ message: String) { emit(.info, message) }
  public func notice(_ message: String) { emit(.default, message) }
  public func warning(_ message: String) { emit(.error, message) }
  public func error(_ message: String) { emit(.error, message) }
  public func critical(_ message: String) { emit(.fault, message) }
  public func fault(_ message: String) { emit(.fault, message) }

  private func emit(_ level: OSLogType, _ message: String) {
    let line = "[\(subsystem):\(category)] \(level.label): \(message)\n"
    FileHandle.standardError.write(Data(line.utf8))
  }
}

public class OSLog: @unchecked Sendable {
  public static let `default` = OSLog(subsystem: "preview", category: "default")
  public static let disabled = OSLog(subsystem: "preview", category: "disabled")

  public let subsystem: String
  public let category: String

  public init(subsystem: String, category: String) {
    self.subsystem = subsystem
    self.category = category
  }
}

public func os_log(
  _ message: String, log: OSLog = .default, type: OSLogType = .default
) {
  FileHandle.standardError.write(Data("[\(log.subsystem):\(log.category)] \(type.label): \(message)\n".utf8))
}
