import CoreLocation
import CoreAppKit

#if SWIFT_PACKAGE
import PermissionCore
#endif

@available(macOS 10.15, macCatalyst 13.0, *)
public struct LocationPermission: PermissionHandle {

    let locationKind: LocationKind
    private let manager: LocationManager

    init(kind: LocationKind) {
        locationKind = kind
        manager = LocationManager(manager: CLLocationManager())
    }
    
    public var kind: PermissionKind {
        .location
    }

    public var current: Permission {
        normalize(manager.authorizationStatus)
    }

    public func status() -> Future<Permission> {
        let status = manager.authorizationStatus
        return MainEventLoop.instance.makeSucceededFuture(normalize(status))
    }

    public func request() -> Future<Permission> {
        let promise = MainEventLoop.instance.makePromise(of: Permission.self)
        manager.request(kind: locationKind) { status in
            promise.succeed(normalize(status))
        }
        return promise.futureResult
    }

    @inline(__always)
    private func normalize(_ status: CLAuthorizationStatus) -> Permission {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            fallthrough
        @unknown default:
            return .denied
        }
    }

    public enum LocationKind {
        case whenInUse
        case always
        // @available(macOS 11.0, iOS 14.0, macCatalyst 14.0, *)
        case temporary(String)
    }
}

@available(macOS 10.15, macCatalyst 13.0, *)
private final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private var onStatusChanged: ((CLAuthorizationStatus) -> Void)?
    private var initStatus: CLAuthorizationStatus?

    init(manager: CLLocationManager) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }

    var authorizationStatus: CLAuthorizationStatus {
        guard CLLocationManager.locationServicesEnabled() else {
            return .denied
        }
        if #available(iOS 14.0, macOS 11.0, *) {
            return manager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    @available(macOS 10.15, *)
    func request(kind: LocationPermission.LocationKind, _ then: @escaping (CLAuthorizationStatus) -> Void) {
        onStatusChanged = then
        initStatus = authorizationStatus
        switch kind {
        case .always:
            manager.requestAlwaysAuthorization()
        case .whenInUse:
            manager.requestWhenInUseAuthorization()
        case let .temporary(key):
            if #available(macOS 11.0, iOS 14.0, macCatalyst 14.0, *) {
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: key)
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == initStatus && initStatus == CLAuthorizationStatus.notDetermined {
            return
        }
        onStatusChanged?(status)
    }

    @available(iOS 14.0, macOS 11.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager(manager, didChangeAuthorization: manager.authorizationStatus)
    }
}
