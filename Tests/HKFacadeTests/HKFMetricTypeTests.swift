import Testing
import HealthKit
@testable import HKFacade

@Suite("HKFMetricType")
struct HKFMetricTypeTests {

    @Test("steps maps to stepCount quantity type")
    func stepsMapping() {
        #expect(HKFMetricType.steps.asQuantityType == HKQuantityType.quantityType(forIdentifier: .stepCount))
        #expect(HKFMetricType.steps.units == .count())
    }

    @Test("distance maps to distanceWalkingRunning quantity type")
    func distanceMapping() {
        #expect(HKFMetricType.distance.asQuantityType == HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning))
        #expect(HKFMetricType.distance.units == .meter())
    }

    @Test("basalEnergy maps to basalEnergyBurned")
    func basalEnergyMapping() {
        #expect(HKFMetricType.basalEnergy.asQuantityType == HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned))
    }

    @Test("activeEnergy maps to activeEnergyBurned")
    func activeEnergyMapping() {
        #expect(HKFMetricType.activeEnergy.asQuantityType == HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned))
    }

    @Test("bloodPressure composite has no native quantity type")
    func bloodPressureNoNative() {
        #expect(HKFMetricType.bloodPressure.asQuantityType == nil)
        #expect(HKFMetricType.bloodPressure.asHKObjectType == nil)
    }

    @Test("mindfulMinutes resolves as category type, not quantity")
    func mindfulMinutesIsCategory() {
        #expect(HKFMetricType.mindfulMinutes.asHKCategoryType != nil)
        #expect(HKFMetricType.mindfulMinutes.asQuantityType == nil)
    }

    @Test("rri resolves as series type")
    func rriIsSeries() {
        #expect(HKFMetricType.rri.asHKSeriesType != nil)
    }

    @Test("quantity metrics route to HKStatisticsCollection path")
    func quantityRouting() {
        let routed: [HKFMetricType] = [.steps, .distance, .basalEnergy, .activeEnergy, .heartRate, .breathRate, .oxygenSaturation, .sdnn, .bloodPressureSystolic, .bloodPressureDiastolic]
        for metric in routed {
            #expect(metric.usesQuantityStatsCollection, "\(metric) should route to quantity stats")
        }
    }

    @Test("composite metrics do not route to HKStatisticsCollection path")
    func compositeRouting() {
        let composite: [HKFMetricType] = [.bloodPressure, .mindfulMinutes, .rri]
        for metric in composite {
            #expect(!metric.usesQuantityStatsCollection, "\(metric) should NOT route to quantity stats")
        }
    }
}
