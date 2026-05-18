# hkfacade-ios

A lightweight Swift facade over Apple's HealthKit that hides the raw `HKHealthStore`
plumbing behind a single `AnyHKFacade` protocol with typed metrics, predicates, and
stats requests.

## Installation

### Swift Package Manager

```swift
.package(url: "git@github.com:relux-works/hkfacade-ios.git", from: "1.8.0"),
```

Add `HKFacade` as a target dependency.

## App requirements

### Entitlement

Enable the **HealthKit** capability on your app target. This adds
`com.apple.developer.healthkit` to the entitlements file.

If you use Tuist with this project's `Capability` DSL, it's `.healthKit()`.

### Info.plist usage strings

Add both keys when your app reads and writes HealthKit data:

```xml
<key>NSHealthShareUsageDescription</key>
<string>App reads your step count and walking/running distance from Apple Health.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>App writes step count and walking/running distance to Apple Health.</string>
```

## Usage

### Request authorization (split read vs write)

Recommended path — the prompt shows only the access kinds your app actually needs:

```swift
let facade: AnyHKFacade = HKFacade()

let result = await facade.requestAccess(
    HKFAuthorizationRequest(
        read: [.steps, .distance],
        write: [.steps, .distance]
    )
)
```

Or via domains:

```swift
await facade.requestAccess(read: [.pedometer], write: [.pedometer])
```

The legacy `requestAccess(_ domains:)` overload still exists; it requests the same
set for both read and write.

### Read today's step count

```swift
let calendar = Calendar.current
let startOfDay = calendar.startOfDay(for: .now)

let request = HKReadStatsRequest(
    associatedType: .steps,
    anchor: startOfDay,
    cadence: .days(),
    predicate: .date(.init(start: startOfDay, end: .now)),
    aggregation: .sum
)

switch await facade.readStats(request: request) {
case .success(let collection):
    let total = collection.stats.compactMap { $0.value.asDouble }.reduce(0, +)
    print("today: \(Int(total)) steps")
case .failure(let err):
    print("read failed: \(err)")
}
```

The library routes quantity metrics (`steps`, `distance`, energy, heart rate, etc.)
through `HKStatisticsCollectionQuery` automatically — the canonical HealthKit API
for cumulative quantities.

#### Aggregation compatibility

Not every aggregation makes sense for every metric:

- **Cumulative** metrics (steps, distance, basal/active energy) — only `.sum` and
  `.mostRecent` are accepted.
- **Discrete** metrics (heart rate, oxygen saturation, SDNN, BP components) — only
  `.avg`, `.min`, `.max`, and `.mostRecent` are accepted.

Requesting an incompatible combination returns
`.unsupportedAggregation(metric:aggregation:)` before the query reaches HealthKit.
Use `HKFMetricType.supportsQuantityStatsAggregation(_:)` to check up front.

Composite metrics (`bloodPressure`, `mindfulMinutes`, `rri`) do not flow through
the quantity-stats path; for them this helper always returns `false`. Their
aggregations are handled inside the sample-side reducer.

### Read walking/running distance

Same shape as steps, swap `.steps` → `.distance`. `value.asDouble` is in meters.

### Write a step sample

```swift
let period = HKFPeriod(start: startDate, end: endDate)
let device = HKFDevice(
    name: UIDevice.current.name,
    model: UIDevice.current.model,
    hardwareVersion: "",
    softwareVersion: UIDevice.current.systemVersion,
    manufacturer: "Apple"
)

let write = HKWriteRequest(
    type: .quantitySample(st: .steps, value: 1234, period: period),
    device: device,
    meta: nil
)

await facade.write(request: write)
```

For distance: `.quantitySample(st: .distance, value: meters, period: period)`.

## Domains

Convenience groupings of metric types for `requestAccess`:

- `.pedometer` — `[.steps, .distance]`
- `.fitness` — `[.steps, .distance, .basalEnergy, .activeEnergy]`
- `.cardio` — heart-rate family + blood pressure
- `.meditation` — `[.mindfulMinutes]`

## Supported metrics

| Metric | HealthKit type | Read path |
| --- | --- | --- |
| `.steps` | `stepCount` | `HKStatisticsCollectionQuery` |
| `.distance` | `distanceWalkingRunning` | `HKStatisticsCollectionQuery` |
| `.basalEnergy` | `basalEnergyBurned` | `HKStatisticsCollectionQuery` |
| `.activeEnergy` | `activeEnergyBurned` | `HKStatisticsCollectionQuery` |
| `.heartRate` | `heartRate` | `HKStatisticsCollectionQuery` |
| `.breathRate` | `respiratoryRate` | `HKStatisticsCollectionQuery` |
| `.oxygenSaturation` | `oxygenSaturation` | `HKStatisticsCollectionQuery` |
| `.sdnn` | `heartRateVariabilitySDNN` | `HKStatisticsCollectionQuery` |
| `.bloodPressureSystolic` / `.bloodPressureDiastolic` | quantity | `HKStatisticsCollectionQuery` |
| `.bloodPressure` | composite | Sample-side grouping |
| `.mindfulMinutes` | `mindfulSession` (category) | Sample-side grouping |
| `.rri` | `heartbeat` (series) | Sample-side grouping |

## Platforms

- iOS 14+
- watchOS 7+
- macOS 13+ (test/build only — HealthKit on macOS has limited surface)

## License

Apache 2.0. See `LICENSE` / `NOTICE`.
