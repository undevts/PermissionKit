import CoreAppKit

public class AnyPermission {
    public var current: Permission {
        .denied
    }
    
    public var kind: PermissionKind {
        fatalError("Subclass hook")
    }

    public func status() -> Future<Permission> {
        MainEventLoop.instance.makeSucceededFuture(.denied)
    }

    public func request() -> Future<Permission> {
        MainEventLoop.instance.makeSucceededFuture(.denied)
    }

    public static func make<Handler>(by handler: Handler) -> AnyPermission where Handler: PermissionHandle {
        AnyPermissionHandler<Handler>(handler: handler)
    }
}

@usableFromInline
final class AnyPermissionHandler<Handler>: AnyPermission, PermissionHandle where Handler: PermissionHandle {
    @usableFromInline
    let handler: PermissionHandle
    
    @inlinable
    override var kind: PermissionKind {
        handler.kind
    }

    @usableFromInline
    init(handler: PermissionHandle) {
        self.handler = handler
    }

    @inlinable
    override var current: Permission {
        handler.current
    }

    @inlinable
    override func status() -> Future<Permission> {
        handler.status()
    }

    @inlinable
    override func request() -> Future<Permission> {
        handler.request()
    }
}
