#if SWIFT_PACKAGE
import PermissionCore
#endif

@available(macOS 10.15, macCatalyst 13.0, *)
extension Permissions {
    public static func location(_ kind: LocationPermission.LocationKind = .whenInUse) -> AnyPermission {
        AnyPermission.make(by: LocationPermission(kind: kind))
    }
}
