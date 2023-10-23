import AVFoundation
import CoreAppKit

#if SWIFT_PACKAGE
import PermissionCore
#endif

@available(macOS 10.14, macCatalyst 14.0, *)
public enum MicrophonePermission: PermissionHandle {
    case microphone
    
    public var kind: PermissionKind {
        .microphone
    }

    public var current: Permission {
        normalize(AVCaptureDevice.authorizationStatus(for: .audio))
    }

    public func status() -> Future<Permission> {
        let result = normalize(AVCaptureDevice.authorizationStatus(for: .audio))
        return MainEventLoop.instance.makeSucceededFuture(result)
    }

    public func request() -> Future<Permission> {
        let promise = MainEventLoop.instance.makePromise(of: Permission.self)
        AVCaptureDevice.requestAccess(for: .audio) { granted in
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
