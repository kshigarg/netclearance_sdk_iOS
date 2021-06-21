import PackageDescription
let package = Package(
    name: "NetclearanceSDK",
    products: [
        .library(name: "NetclearanceSDK", targets: ["Netclearance_SDK"])
    ],
    targets: [
        .target(name: "Netclearance_SDK", path: "Netclearance_SDK")
    ]
)
