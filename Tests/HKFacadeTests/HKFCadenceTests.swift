import Testing
import Foundation
@testable import HKFacade

@Suite("HKFCadence.buildPeriod")
struct HKFCadenceBuildPeriodTests {

    private func components(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> DateComponents {
        var dc = DateComponents()
        dc.year = year
        dc.month = month
        dc.day = day
        dc.hour = hour
        dc.minute = minute
        return dc
    }

    @Test("minutes cadence spans exactly one minute (regression: was using add(months:))")
    func minutesSpan() throws {
        let dc = components(year: 2025, month: 6, day: 15, hour: 12, minute: 30)
        let period = try #require(HKFCadence.buildPeriod(from: dc, cadence: .minutes()))
        let diff = period.end.timeIntervalSince(period.start)
        #expect(diff == 60, "minutes cadence must span 60 seconds, got \(diff)")
    }

    @Test("hours cadence spans exactly one hour")
    func hoursSpan() throws {
        let dc = components(year: 2025, month: 6, day: 15, hour: 12)
        let period = try #require(HKFCadence.buildPeriod(from: dc, cadence: .hours()))
        let diff = period.end.timeIntervalSince(period.start)
        #expect(diff == 3600)
    }

    @Test("days cadence spans exactly one day")
    func daysSpan() throws {
        let dc = components(year: 2025, month: 6, day: 15)
        let period = try #require(HKFCadence.buildPeriod(from: dc, cadence: .days()))
        let diff = period.end.timeIntervalSince(period.start)
        #expect(diff == 86_400)
    }

    @Test("weeks cadence spans exactly seven days")
    func weeksSpan() throws {
        let dc = components(year: 2025, month: 6, day: 15)
        let period = try #require(HKFCadence.buildPeriod(from: dc, cadence: .weeks()))
        let diff = period.end.timeIntervalSince(period.start)
        #expect(diff == 7 * 86_400)
    }

    @Test("months cadence advances calendar month")
    func monthsSpan() throws {
        let dc = components(year: 2025, month: 6, day: 15)
        let period = try #require(HKFCadence.buildPeriod(from: dc, cadence: .months()))
        let calendar = Calendar.current
        let startMonth = calendar.component(.month, from: period.start)
        let endMonth = calendar.component(.month, from: period.end)
        #expect(startMonth == 6)
        #expect(endMonth == 7)
    }

    @Test("years cadence advances calendar year")
    func yearsSpan() throws {
        let dc = components(year: 2025, month: 6, day: 15)
        let period = try #require(HKFCadence.buildPeriod(from: dc, cadence: .years()))
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: period.start)
        let endYear = calendar.component(.year, from: period.end)
        #expect(startYear == 2025)
        #expect(endYear == 2026)
    }
}
