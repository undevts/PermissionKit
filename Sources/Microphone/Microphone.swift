#if SWIFT_PACKAGE
import PermissionCore
#endif

@available(macOS 10.14, macCatalyst 14.0, *)
extension Permissions {
    public static func microphone(_ microphone: MicrophonePermission = .microphone) -> AnyPermission {
        AnyPermission.make(by: microphone)
    }
}
