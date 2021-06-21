// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "NetclearanceSDK",
    products: [
        .library(name: "NetclearanceSDK", targets: ["NetclearanceSDK"])
    ],
    targets: [
        .binaryTarget(name: "NetclearanceSDK", path: "Netclearance_SDK.xcframework")
    ]
)
