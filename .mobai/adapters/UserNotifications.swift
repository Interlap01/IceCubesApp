// Preview adapter for UserNotifications.
//
// Replaces the generated stand-in, which declared the delegate's methods with
// `<Self>` generic parameters Swift rejects, and only in their completion
// handler form -- PushNotificationsService implements the `async` ones, so it
// could not conform. Here the delegate's requirements are the async
// signatures, and every one has a default, so a partial conformance is fine.
//
// Nothing schedules or delivers a real notification; authorization is simply
// granted so the app takes its permitted path.

import Foundation

public struct UNAuthorizationOptions: OptionSet, Hashable, Sendable {
  public let rawValue: UInt
  public init(rawValue: UInt) { self.rawValue = rawValue }
  public init() { rawValue = 0 }

  public static let badge = UNAuthorizationOptions(rawValue: 1 << 0)
  public static let sound = UNAuthorizationOptions(rawValue: 1 << 1)
  public static let alert = UNAuthorizationOptions(rawValue: 1 << 2)
  public static let provisional = UNAuthorizationOptions(rawValue: 1 << 6)
}

public struct UNNotificationPresentationOptions: OptionSet, Hashable, Sendable {
  public let rawValue: UInt
  public init(rawValue: UInt) { self.rawValue = rawValue }
  public init() { rawValue = 0 }

  public static let badge = UNNotificationPresentationOptions(rawValue: 1 << 0)
  public static let sound = UNNotificationPresentationOptions(rawValue: 1 << 1)
  public static let list = UNNotificationPresentationOptions(rawValue: 1 << 3)
  public static let banner = UNNotificationPresentationOptions(rawValue: 1 << 4)
}

public enum UNAuthorizationStatus: Int, Sendable {
  case notDetermined = 0
  case denied = 1
  case authorized = 2
  case provisional = 3
  case ephemeral = 4
}

open class UNNotificationSettings: @unchecked Sendable {
  public let authorizationStatus: UNAuthorizationStatus

  public init(authorizationStatus: UNAuthorizationStatus = .authorized) {
    self.authorizationStatus = authorizationStatus
  }
}

open class UNNotificationContent: @unchecked Sendable {
  public var title: String = ""
  public var subtitle: String = ""
  public var body: String = ""
  public var badge: NSNumber?
  public var userInfo: [AnyHashable: Any] = [:]

  public init() {}
}

open class UNMutableNotificationContent: UNNotificationContent, @unchecked Sendable {
  public override init() { super.init() }
}

open class UNNotificationTrigger: @unchecked Sendable {
  public init() {}
}

open class UNNotificationRequest: @unchecked Sendable {
  public let identifier: String
  public let content: UNNotificationContent
  public let trigger: UNNotificationTrigger?

  public init(
    identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger? = nil
  ) {
    self.identifier = identifier
    self.content = content
    self.trigger = trigger
  }
}

open class UNNotification: @unchecked Sendable {
  public let request: UNNotificationRequest
  public let date: Date

  public init(
    request: UNNotificationRequest = UNNotificationRequest(
      identifier: "preview", content: UNNotificationContent()),
    date: Date = Date()
  ) {
    self.request = request
    self.date = date
  }
}

open class UNNotificationResponse: @unchecked Sendable {
  public let notification: UNNotification
  public let actionIdentifier: String

  public init(
    notification: UNNotification = UNNotification(),
    actionIdentifier: String = "com.apple.UNNotificationDefaultActionIdentifier"
  ) {
    self.notification = notification
    self.actionIdentifier = actionIdentifier
  }
}

open class UNNotificationCategory: @unchecked Sendable {
  public init() {}
}

open class UNNotificationServiceExtension: @unchecked Sendable {
  public init() {}
}

public protocol UNUserNotificationCenterDelegate: AnyObject {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions

  func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
  ) async

  func userNotificationCenter(
    _ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?)
}

/// Defaults, so conforming types implement only what they care about --
/// which is what the real ObjC protocol's optional methods give them.
extension UNUserNotificationCenterDelegate {
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions { [] }

  public func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
  ) async {}

  public func userNotificationCenter(
    _ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {}
}

public class UNUserNotificationCenter: @unchecked Sendable {
  private static let center = UNUserNotificationCenter()

  public weak var delegate: (any UNUserNotificationCenterDelegate)?

  public init() {}

  public static func current() -> UNUserNotificationCenter { center }

  /// Granted: the preview shows the app's authorized path rather than a
  /// permission wall it has no way to dismiss.
  @discardableResult
  public func requestAuthorization(options: UNAuthorizationOptions = []) async throws -> Bool {
    true
  }

  public func requestAuthorization(
    options: UNAuthorizationOptions = [], completionHandler: (Bool, (any Error)?) -> Void
  ) {
    completionHandler(true, nil)
  }

  public func notificationSettings() async -> UNNotificationSettings {
    UNNotificationSettings(authorizationStatus: .authorized)
  }

  public func getNotificationSettings(completionHandler: (UNNotificationSettings) -> Void) {
    completionHandler(UNNotificationSettings(authorizationStatus: .authorized))
  }

  public func add(_ request: UNNotificationRequest) async throws {}
  public func setNotificationCategories(_ categories: Set<AnyHashable>) {}
  public func removeAllDeliveredNotifications() {}
  public func removeAllPendingNotificationRequests() {}
  public func deliveredNotifications() async -> [UNNotification] { [] }
}
