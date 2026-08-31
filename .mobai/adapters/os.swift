// Preview adapter for the `os` module.
// MastodonClient stores all its mutable state in an OSAllocatedUnfairLock to
// stay Sendable; this backs that same API with NSLock so the client compiles
// and keeps its concurrency semantics in the preview.

import Foundation

public final class OSAllocatedUnfairLock<State>: @unchecked Sendable {
  private let mutex = NSLock()
  private var state: State

  public init(initialState: State) {
    state = initialState
  }

  public init(uncheckedState: State) {
    state = uncheckedState
  }

  public func withLock<R>(_ body: (inout State) throws -> R) rethrows -> R {
    mutex.lock()
    defer { mutex.unlock() }
    return try body(&state)
  }

  public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
    try withLock(body)
  }

  public func lock() { mutex.lock() }
  public func unlock() { mutex.unlock() }
}

extension OSAllocatedUnfairLock where State == Void {
  public convenience init() {
    self.init(initialState: ())
  }

  public func withLock<R>(_ body: () throws -> R) rethrows -> R {
    try withLock { _ in try body() }
  }
}
