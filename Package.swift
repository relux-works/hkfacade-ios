// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hkfacade-ios",
    platforms: [
        .iOS(.v14),
        .watchOS(.v7),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "HKFacade",
            type: .dynamic,
            targets: ["HKFacade"]),
    ],
    dependencies: Package.remoteDependencies,
    targets: [
        .target(
            name: "HKFacade",
            dependencies: Package.facadeDependencies,
            path: "Sources"
        ),
        .testTarget(
            name: "HKFacadeTests",
            dependencies: ["HKFacade"],
            path: "Tests/HKFacadeTests"
        ),
    ]
)

// MARK: -- Dependencies
extension Package {
    static var remoteDependencies: [Package.Dependency] {
        [
        ]
    }

    static var facadeDependencies: [Target.Dependency] {
        [
        ]
    }
}
