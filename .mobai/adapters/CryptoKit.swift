// Preview adapter for CryptoKit.
// The engine cannot compile Apple's CryptoKit, and dropping it takes
// PushNotificationsService -- and PreviewEnv behind it -- out of the build.
// swift-crypto ships with the engine and is API-compatible with CryptoKit
// for what the app uses (P256 key agreement), so this re-exports it rather
// than inventing a second implementation.

@_exported import Crypto
@_exported import Foundation

// MARK: - Security's RNG

// PushNotificationsService generates its auth key with SecRandomCopyBytes,
// which arrives through Foundation on a phone. The engine's catch-all
// stand-in for it is generic and cannot be inferred at that call site, so
// this declares the real shape, backed by the system RNG.

public struct SecRandomRef: Sendable {
  public init() {}
}

public let kSecRandomDefault = SecRandomRef()

@discardableResult
public func SecRandomCopyBytes(
  _ rnd: SecRandomRef?, _ count: Int, _ bytes: UnsafeMutableRawPointer
) -> Int32 {
  var generator = SystemRandomNumberGenerator()
  let destination = bytes.assumingMemoryBound(to: UInt8.self)
  for offset in 0..<count {
    destination[offset] = UInt8.random(in: UInt8.min...UInt8.max, using: &generator)
  }
  return 0  // errSecSuccess
}
