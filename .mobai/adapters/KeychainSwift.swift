// Preview adapter for KeychainSwift (https://github.com/evgenyneu/keychain-swift).
// The real package talks to the iOS keychain, which does not exist in a preview.
// This maps the surface the app uses onto a process-wide in-memory store, so
// account storage, the DeepL key and push keys behave normally for one session.

import Foundation

public enum KeychainSwiftAccessOptions: Sendable {
  case accessibleWhenUnlocked
  case accessibleWhenUnlockedThisDeviceOnly
  case accessibleAfterFirstUnlock
  case accessibleAfterFirstUnlockThisDeviceOnly
  case accessibleWhenPasscodeSetThisDeviceOnly
}

/// Backing store shared by every KeychainSwift instance, like the real keychain.
private final class KeychainStore: @unchecked Sendable {
  static let shared = KeychainStore()
  private let lock = NSLock()
  private var values: [String: Data] = [:]

  func set(_ data: Data, forKey key: String) {
    lock.lock(); defer { lock.unlock() }
    values[key] = data
  }

  func data(forKey key: String) -> Data? {
    lock.lock(); defer { lock.unlock() }
    return values[key]
  }

  func delete(_ key: String) {
    lock.lock(); defer { lock.unlock() }
    values[key] = nil
  }

  func clear() {
    lock.lock(); defer { lock.unlock() }
    values.removeAll()
  }

  var allKeys: [String] {
    lock.lock(); defer { lock.unlock() }
    return Array(values.keys)
  }
}

public class KeychainSwift {
  public var accessGroup: String?
  public var synchronizable: Bool = false
  public var lastResultCode: Int32 = 0
  public let keyPrefix: String

  public init() { keyPrefix = "" }
  public init(keyPrefix: String) { self.keyPrefix = keyPrefix }

  private func prefixed(_ key: String) -> String { keyPrefix + key }

  public var allKeys: [String] {
    let prefix = keyPrefix
    guard !prefix.isEmpty else { return KeychainStore.shared.allKeys }
    return KeychainStore.shared.allKeys.filter { $0.hasPrefix(prefix) }
  }

  @discardableResult
  public func set(
    _ value: String, forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil
  ) -> Bool {
    guard let data = value.data(using: .utf8) else { return false }
    return set(data, forKey: key, withAccess: access)
  }

  @discardableResult
  public func set(
    _ value: Data, forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil
  ) -> Bool {
    KeychainStore.shared.set(value, forKey: prefixed(key))
    return true
  }

  @discardableResult
  public func set(
    _ value: Bool, forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil
  ) -> Bool {
    set(Data([value ? 1 : 0]), forKey: key, withAccess: access)
  }

  public func get(_ key: String) -> String? {
    guard let data = getData(key) else { return nil }
    return String(data: data, encoding: .utf8)
  }

  public func getData(_ key: String, asReference: Bool = false) -> Data? {
    KeychainStore.shared.data(forKey: prefixed(key))
  }

  public func getBool(_ key: String) -> Bool? {
    guard let data = getData(key), let first = data.first else { return nil }
    return first == 1
  }

  @discardableResult
  public func delete(_ key: String) -> Bool {
    KeychainStore.shared.delete(prefixed(key))
    return true
  }

  @discardableResult
  public func clear() -> Bool {
    KeychainStore.shared.clear()
    return true
  }
}
