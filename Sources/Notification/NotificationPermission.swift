import UserNotifications
import CoreAppKit

#if SWIFT_PACKAGE
import PermissionCore
#endif

#if canImport(UIKit)
import UIKit
#endif

@available(macOS 10.14, iOS 10.0, macCatalyst 13.0, *)
public struct NotificationPermission: PermissionHandle {
    public let options: UNAuthorizationOptions
    
    public var kind: PermissionKind {
        .notification
    }

    public var current: Permission {
#if DEBUG
        print("Call \"Permission.notification().current\" is discouraged, please use \"status()\"")
#endif
        var result = Permission.denied
        let signal = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            result = normalize(settings.authorizationStatus)
            signal.signal()
        }
        _ = signal.wait(timeout: .distantFuture)
        return result
    }

    public func status() -> Future<Permission> {
        let promise = MainEventLoop.instance.makePromise(of: Permission.self)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            promise.succeed(normalize(settings.authorizationStatus))
        }
        return promise.futureResult
    }

    public func request() -> Future<Permission> {
        let promise = MainEventLoop.instance.makePromise(of: Permission.self)
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let e = error {
                promise.fail(e)
            } else {
                promise.succeed(granted ? .authorized : .denied)
            }
        }
        return promise.futureResult
    }

    @inline(__always)
    private func normalize(_ status: UNAuthorizationStatus) -> Permission {
        switch status {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied:
            fallthrough
        @unknown default:
            return .denied
        }
    }

    public static var defaultOptions: UNAuthorizationOptions {
        [.badge, .alert]
    }
}

#if canImport(UIKit)

@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use NotificationPermission instead")
public struct LegacyNotificationPermission: PermissionHandle {
    public let settings: UIUserNotificationSettings

    public var current: Permission {
        let granted = UIApplication.shared.isRegisteredForRemoteNotifications
        return granted ? .authorized : .denied
    }
    
    public var kind: PermissionKind {
        .location
    }

    public func status() -> Future<Permission> {
        let granted = UIApplication.shared.isRegisteredForRemoteNotifications
        return MainEventLoop.instance.makeSucceededFuture(granted ? .authorized : .denied)
    }

    public func request() -> Future<Permission> {
        UIApplication.shared.registerUserNotificationSettings(settings)
        return MainEventLoop.instance.makeSucceededFuture(.denied)
    }

    public static var defaultSettings: UIUserNotificationSettings {
        UIUserNotificationSettings(types: [.badge, .alert], categories: nil)
    }
}

#endif // canImport(UIKit)
