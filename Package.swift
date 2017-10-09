// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "KulCalendar",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
		.package(url: "https://github.com/dev1an/iCalendar", .revision("da81bfedb12ea261ddaff97e32dbe4b7d5d2e962")),
		.package(url: "https://github.com/tid-kijyun/Kanna.git", .branch("feature/v4.0.0")),
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "iCalendar", "Kanna"],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)
