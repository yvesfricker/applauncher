// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppLauncher",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "AppLauncher", targets: ["AppLauncher"])
    ],
    targets: [
        .executableTarget(name: "AppLauncher")
    ]
)
