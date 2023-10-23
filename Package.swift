// swift-tools-version: 5.8

import PackageDescription

let models = ["Camera", "Location", "Microphone", "Notification", "Photo"]
var targets = [
    Target.target(
        name: "PermissionCore",
        dependencies: [
            .product(name: "CoreAppKit", package: "CoreAppKit"),
        ]),
    .target(
        name: "PermissionKit",
        dependencies: [
            "PermissionCore",
        ]),
    .testTarget(
        name: "PermissionKitTests",
        dependencies: [
            "PermissionKit",
        ]),
]
var products = [
    Product.library(
        name: "PermissionKit",
        targets: ["PermissionKit"]),
]

products.append(contentsOf: models.map { name -> Product in
    Product.library(name: "Permission\(name)", targets: ["Permission\(name)"])
})
targets.append(contentsOf: models.map { name -> Target in
    Target.target(name: "Permission\(name)", dependencies: ["PermissionCore"], path: "Sources/\(name)")
})

let package = Package(
    name: "PermissionKit",
    products: products,
    dependencies: [
        .package(url: "https://github.com/undevts/CoreAppKit.git", from: "0.1.0"),
    ],
    targets: targets
)
