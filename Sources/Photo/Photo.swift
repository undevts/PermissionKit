#if SWIFT_PACKAGE
import PermissionCore
#endif

@available(macOS 10.13, macCatalyst 13.0, *)
extension Permissions {
    public static func photo(_ photo: PhotoPermission = .default) -> AnyPermission {
        AnyPermission.make(by: photo)
    }
}
