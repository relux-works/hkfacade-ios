import HealthKit

public enum HKFMetricType: String, Codable, Sendable {
    case heartRate
    case breathRate
    case oxygenSaturation
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case bloodPressure
    case sdnn
    case rri

    case steps
    case distance
    case basalEnergy
    case activeEnergy

    case mindfulMinutes

    /// Whether `readStats` should route this metric through `HKStatisticsCollectionQuery`.
    ///
    /// Quantity metrics (cumulative or discrete) use the canonical HealthKit aggregation
    /// path. Composite/custom metrics (`bloodPressure`, `mindfulMinutes`, `rri`) fall
    /// back to the sample-side grouping path because they have no single native
    /// `HKQuantityType` counterpart.
    var usesQuantityStatsCollection: Bool {
        switch self {
        case .steps, .distance, .basalEnergy, .activeEnergy,
             .heartRate, .breathRate, .oxygenSaturation, .sdnn,
             .bloodPressureSystolic, .bloodPressureDiastolic:
            return true
        case .bloodPressure, .mindfulMinutes, .rri:
            return false
        }
    }

    /// How HealthKit aggregates values of this metric.
    ///
    /// Cumulative metrics (steps, distance, energy) sum sample values; aggregations like
    /// `.avg`, `.min`, `.max` are not meaningful and HealthKit rejects them in
    /// `HKStatisticsCollectionQuery`.
    ///
    /// Discrete metrics (heart rate, oxygen saturation, etc.) sample point-in-time values;
    /// `.sum` over them is not meaningful and HealthKit rejects it.
    ///
    /// `.none` covers composite/custom types that don't go through quantity stats at all.
    public enum AggregationStyle: Sendable {
        case cumulative
        case discrete
        case none
    }

    public var aggregationStyle: AggregationStyle {
        switch self {
        case .steps, .distance, .basalEnergy, .activeEnergy:
            return .cumulative
        case .heartRate, .breathRate, .oxygenSaturation, .sdnn,
             .bloodPressureSystolic, .bloodPressureDiastolic:
            return .discrete
        case .bloodPressure, .mindfulMinutes, .rri:
            return .none
        }
    }

    /// Whether the given aggregation can be applied to this metric on the quantity-stats path.
    ///
    /// Use this to fail fast before dispatching an `HKStatisticsCollectionQuery`; the
    /// HealthKit API itself throws when an incompatible aggregation is requested.
    ///
    /// Composite / custom metrics (`bloodPressure`, `mindfulMinutes`, `rri`) always
    /// return `false` because they do not flow through the quantity-stats path at all —
    /// they are handled via sample-side aggregation inside `HKFModelBuilder.reduce`.
    public func supportsQuantityStatsAggregation(_ aggregation: HKFAggregationType) -> Bool {
        guard usesQuantityStatsCollection else { return false }

        switch aggregationStyle {
        case .cumulative:
            switch aggregation {
            case .sum, .mostRecent: return true
            case .avg, .min, .max: return false
            }
        case .discrete:
            switch aggregation {
            case .avg, .min, .max, .mostRecent: return true
            case .sum: return false
            }
        case .none:
            return false
        }
    }

    public var units: HKUnit {
        switch self {
        case .heartRate: return .timesPerMinuteUnit
        case .breathRate: return .timesPerMinuteUnit
        case .oxygenSaturation: return .percent()
        case .bloodPressureSystolic: return .millimeterOfMercury()
        case .bloodPressureDiastolic: return .millimeterOfMercury()
        case .bloodPressure: return .millimeterOfMercury()
        case .sdnn: return .second()
        case .rri: return .second()

        case .steps: return .count()
        case .distance: return .meter()
        case .basalEnergy: return .smallCalorie()
        case .activeEnergy: return .smallCalorie()

        case .mindfulMinutes: return .minute()
        }
    }

    var asSampleType: HealthKit.HKSampleType? { asHKObjectType as? HealthKit.HKSampleType }

    var asQuantityType: HealthKit.HKQuantityType? { asHKObjectType as? HealthKit.HKQuantityType }

    var asHKSeriesType: HealthKit.HKSeriesType? { asHKObjectType as? HKSeriesType }

    var asHKCategoryType: HealthKit.HKCategoryType? { asHKObjectType as? HealthKit.HKCategoryType }

    /// Resolves the metric to its native HealthKit type.
    ///
    /// Returns a quantity type, category type, or series type depending on the metric.
    /// `.bloodPressure` returns `nil` because it is a composite of two quantity types
    /// (`bloodPressureSystolic` + `bloodPressureDiastolic`) and has no single native counterpart.
    var asHKObjectType: HealthKit.HKObjectType? {
        switch self {
        case .heartRate:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .heartRate)
        case .breathRate:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .respiratoryRate)
        case .oxygenSaturation:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)
        case .bloodPressureSystolic:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
        case .bloodPressureDiastolic:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
        case .bloodPressure:
            return nil

        case .sdnn:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case .rri:
            return HealthKit.HKSeriesType.heartbeat()
        case .steps:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .stepCount)
        case .distance:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        case .basalEnergy:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)
        case .activeEnergy:
            return HealthKit.HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)

        case .mindfulMinutes:
            return HealthKit.HKObjectType.categoryType(forIdentifier: .mindfulSession)
        }
    }
}

extension HKFMetricType: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}
