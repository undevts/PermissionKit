#if SWIFT_PACKAGE
@_exported import PermissionCore

#if canImport(PermissionCamera)
@_exported import PermissionCamera
#endif

#if canImport(PermissionLocation)
@_exported import PermissionLocation
#endif

#if canImport(PermissionMicrophone)
@_exported import PermissionMicrophone
#endif

#if canImport(PermissionNotification)
@_exported import PermissionNotification
#endif

#if canImport(PermissionPhoto)
@_exported import PermissionPhoto
#endif

#endif
