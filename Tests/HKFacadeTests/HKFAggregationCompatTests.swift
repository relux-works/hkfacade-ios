import Testing
@testable import HKFacade

@Suite("HKFMetricType aggregation compatibility")
struct HKFAggregationCompatTests {

    @Test("cumulative metrics support .sum and .mostRecent only")
    func cumulativeMatrix() {
        let cumulative: [HKFMetricType] = [.steps, .distance, .basalEnergy, .activeEnergy]
        for metric in cumulative {
            #expect(metric.aggregationStyle == .cumulative)
            #expect(metric.supportsQuantityStatsAggregation(.sum))
            #expect(metric.supportsQuantityStatsAggregation(.mostRecent))
            #expect(!metric.supportsQuantityStatsAggregation(.avg))
            #expect(!metric.supportsQuantityStatsAggregation(.min))
            #expect(!metric.supportsQuantityStatsAggregation(.max))
        }
    }

    @Test("discrete metrics support .avg/.min/.max/.mostRecent, not .sum")
    func discreteMatrix() {
        let discrete: [HKFMetricType] = [.heartRate, .breathRate, .oxygenSaturation, .sdnn,
                                          .bloodPressureSystolic, .bloodPressureDiastolic]
        for metric in discrete {
            #expect(metric.aggregationStyle == .discrete)
            #expect(metric.supportsQuantityStatsAggregation(.avg))
            #expect(metric.supportsQuantityStatsAggregation(.min))
            #expect(metric.supportsQuantityStatsAggregation(.max))
            #expect(metric.supportsQuantityStatsAggregation(.mostRecent))
            #expect(!metric.supportsQuantityStatsAggregation(.sum))
        }
    }

    @Test("composite/custom metrics report .none aggregation style")
    func composite() {
        for metric in [HKFMetricType.bloodPressure, .mindfulMinutes, .rri] {
            #expect(metric.aggregationStyle == .none)
        }
    }

    @Test("composite metrics never report support for quantity-stats path")
    func compositeRejectsAll() {
        let composite: [HKFMetricType] = [.bloodPressure, .mindfulMinutes, .rri]
        let allAggregations: [HKFAggregationType] = [.sum, .avg, .min, .max, .mostRecent]
        for metric in composite {
            for aggregation in allAggregations {
                #expect(
                    !metric.supportsQuantityStatsAggregation(aggregation),
                    "\(metric) should not claim support for \(aggregation) on quantity-stats path"
                )
            }
        }
    }
}
