import Photos
import CoreAppKit

#if SWIFT_PACKAGE
import PermissionCore
#endif

@available(macOS 10.13, macCatalyst 13.0, *)
public struct PhotoPermission: PermissionHandle {
    public static var `default`: PhotoPermission {
        PhotoPermission(level: .readWrite, allowLimited: true)
    }

    public let level: AccessLevel
    public let allowLimited: Bool
    
    public var kind: PermissionKind {
        .photo
    }

    public var current: Permission {
        if #available(macOS 11.0, iOS 14.0, macCatalyst 14.0, *) {
            return normalize(PHPhotoLibrary.authorizationStatus(for: level.raw))
        } else {
            return normalize(PHPhotoLibrary.authorizationStatus())
        }
    }

    public func status() -> Future<Permission> {
        let result: Permission
        if #available(macOS 11.0, iOS 14.0, macCatalyst 14.0, *) {
            result = normalize(PHPhotoLibrary.authorizationStatus(for: level.raw))
        } else {
            result = normalize(PHPhotoLibrary.authorizationStatus())
        }
        return MainEventLoop.instance.makeSucceededFuture(result)
    }

    public func request() -> Future<Permission> {
        let promise = MainEventLoop.instance.makePromise(of: Permission.self)
        if #available(macOS 11.0, iOS 14.0, macCatalyst 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: level.raw) { status in
                promise.succeed(normalize(status))
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                promise.succeed(normalize(status))
            }
        }
        return promise.futureResult
    }

    @inline(__always)
    private func normalize(_ status: PHAuthorizationStatus) -> Permission {
        switch status {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .limited:
            return allowLimited ? .authorized : .denied
        case .denied, .restricted:
            fallthrough
        @unknown default:
            return .denied
        }
    }

    public enum AccessLevel: Int {
        case addOnly = 1
        case readWrite = 2

        @available(macOS 11.0, iOS 14.0, macCatalyst 14.0, *)
        var raw: PHAccessLevel {
            PHAccessLevel(rawValue: rawValue) ?? .readWrite
        }
    }
}
