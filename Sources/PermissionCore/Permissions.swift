import CoreAppKit

@frozen
public enum Permission: Int {
    case notDetermined
    case authorized
    case denied
}

@frozen
public enum PermissionKind: Int, CaseIterable {
    case camera
    case location
    case microphone
    case notification
    case photo
}

public protocol PermissionHandle {
    var kind: PermissionKind { get }
    var current: Permission { get }

    func status() -> Future<Permission>
    func request() -> Future<Permission>
}

public protocol PermissionAlertBuilder {
    func buildAlert(for kind: PermissionKind)
}

/// The namespace for all kind of permissions.
public enum Permissions {
    // No *any* case here
}
