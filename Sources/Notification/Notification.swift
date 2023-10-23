import UserNotifications

#if SWIFT_PACKAGE
import PermissionCore
#endif

#if canImport(UIKit)
import UIKit
#endif

@available(macOS 10.14, macCatalyst 14.0, *)
extension Permissions {

    @available(macOS 10.14, macCatalyst 14.0, *)
    public static func notification() -> AnyPermission {
#if os(iOS)
        if #available(iOS 10, *) {
            return notification(NotificationPermission.defaultOptions)
        } else {
            return notificationLegacy(LegacyNotificationPermission.defaultSettings)
        }
#else
        return notification(NotificationPermission.defaultOptions)
#endif // os(iOS)
    }

#if canImport(UIKit)

    @available(macCatalyst, unavailable)
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use notification(_:) instead")
    public static func notificationLegacy(
        _ settings: UIUserNotificationSettings = LegacyNotificationPermission.defaultSettings
    ) -> AnyPermission {
        AnyPermission.make(by: LegacyNotificationPermission(settings: settings))
    }

#endif // canImport(UIKit)

    @available(macOS 10.14, iOS 10, macCatalyst 14.0, *)
    public static func notification(_ options: UNAuthorizationOptions) -> AnyPermission {
        AnyPermission.make(by: NotificationPermission(options: options))
    }
}
