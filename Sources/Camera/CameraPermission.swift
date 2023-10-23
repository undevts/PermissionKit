import AVFoundation
import CoreAppKit

#if SWIFT_PACKAGE
import PermissionCore
#endif

@available(macOS 10.14, macCatalyst 14.0, *)
public enum CameraPermission: PermissionHandle {
    case camera
    
    public var kind: PermissionKind {
        .camera
    }

    public var current: Permission {
        normalize(AVCaptureDevice.authorizationStatus(for: .video))
    }

    public func status() -> Future<Permission> {
        let result = normalize(AVCaptureDevice.authorizationStatus(for: .video))
        return MainEventLoop.instance.makeSucceededFuture(result)
    }

    public func request() -> Future<Permission> {
        let promise = MainEventLoop.instance.makePromise(of: Permission.self)
        AVCaptureDevice.requestAccess(for: .video) { granted in
            promise.succeed(granted ? .authorized : .denied)
        }
        return promise.futureResult
    }

    @inline(__always)
    private func normalize(_ status: AVAuthorizationStatus) -> Permission {
        switch status {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            fallthrough
        @unknown default:
            return .denied
        }
    }
}
