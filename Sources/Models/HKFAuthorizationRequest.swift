import Foundation

/// A HealthKit authorization request that distinguishes read vs write access.
///
/// Use this instead of the legacy `requestAccess(_ domains:)` API when you want the
/// system permission prompt to show only the access kinds your app actually needs.
public struct HKFAuthorizationRequest: Sendable {
    public let read: [HKFMetricType]
    public let write: [HKFMetricType]

    public init(read: [HKFMetricType], write: [HKFMetricType]) {
        self.read = read
        self.write = write
    }
}

public extension HKFAuthorizationRequest {
    /// Builds a request from domains.
    static func from(read: [HKFDomain], write: [HKFDomain]) -> HKFAuthorizationRequest {
        .init(
            read: read.flatMap(\.associatedTypes),
            write: write.flatMap(\.associatedTypes)
        )
    }
}
