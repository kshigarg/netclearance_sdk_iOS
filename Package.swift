// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "Netclearance_SDK",
    products: [
        .library(name: "Netclearance_SDK", targets: ["Netclearance_SDK"])
    ],
    targets: [
        .binaryTarget(name: "Netclearance_SDK", path: "Netclearance_SDK.xcframework")
    ]
)
