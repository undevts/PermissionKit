#if SWIFT_PACKAGE
import PermissionCore
#endif

@available(macOS 10.14, macCatalyst 14.0, *)
extension Permissions {
    public static func camera(_ camera: CameraPermission = .camera) -> AnyPermission {
        AnyPermission.make(by: camera)
    }
}
