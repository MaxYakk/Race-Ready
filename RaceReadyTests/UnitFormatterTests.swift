import XCTest
@testable import RaceReady

final class UnitFormatterTests: XCTestCase {

    // MARK: - Distance formatting

    func testMetricDistanceUsesKmForRuns() {
        let f = UnitFormatter(system: .metric)
        XCTAssertEqual(f.formatDistance(meters: 5_000), "5 km")
        XCTAssertEqual(f.formatDistance(meters: 1_500), "1.50 km")
    }

    func testImperialDistanceUsesMilesForRuns() {
        let f = UnitFormatter(system: .imperial)
        XCTAssertEqual(f.formatDistance(meters: 1_609.344), "1.00 mi")
        XCTAssertEqual(f.formatDistance(meters: 5_000), "3.11 mi")
    }

    func testStationDistanceUsesMetersOrFeet() {
        let m = UnitFormatter(system: .metric)
        let i = UnitFormatter(system: .imperial)
        XCTAssertEqual(m.formatDistance(meters: 50, style: .stationScale), "50 m")
        XCTAssertEqual(i.formatDistance(meters: 50, style: .stationScale), "164 ft")
    }

    // MARK: - Weight formatting

    func testWeightRoundTrip() {
        let m = UnitFormatter(system: .metric)
        let i = UnitFormatter(system: .imperial)
        XCTAssertEqual(m.formatWeight(kg: 20), "20 kg")
        XCTAssertEqual(i.formatWeight(kg: 20), "44.1 lb")
        XCTAssertEqual(i.formatWeight(kg: 152), "335.1 lb")
    }

    // MARK: - Pace

    func testPaceFormattingMetric() {
        let f = UnitFormatter(system: .metric)
        XCTAssertEqual(f.formatPace(secondsPerKm: 285), "4:45/km")
    }

    func testPaceFormattingImperial() {
        let f = UnitFormatter(system: .imperial)
        // 4:45/km = 285 s/km → 285 × 1.609344 = ~459 s/mi → 7:39/mi
        XCTAssertEqual(f.formatPace(secondsPerKm: 285), "7:39/mi")
    }

    func testPaceFromDistanceAndDuration() {
        // 5.0 mi (8046.7 m) in 40:00 (2400 s) → ~298 s/km
        let pace = UnitFormatter.paceSecondsPerKm(distanceMeters: 8_046.7, durationSeconds: 2_400)
        XCTAssertEqual(pace, 298)
    }

    func testPaceWithZeroDistanceReturnsNil() {
        XCTAssertNil(UnitFormatter.paceSecondsPerKm(distanceMeters: 0, durationSeconds: 100))
    }

    // MARK: - Duration

    func testDurationUnderHour() {
        let f = UnitFormatter(system: .metric)
        XCTAssertEqual(f.formatDuration(seconds: 285), "4:45")
        XCTAssertEqual(f.formatDuration(seconds: 0), "0:00")
    }

    func testDurationOverHour() {
        let f = UnitFormatter(system: .metric)
        XCTAssertEqual(f.formatDuration(seconds: 5_400), "1:30:00")
        XCTAssertEqual(f.formatDuration(seconds: 3_725), "1:02:05")
    }

    // MARK: - Parsing

    func testParseDistanceWithUnitSuffix() throws {
        let f = UnitFormatter(system: .imperial)
        XCTAssertEqual(try XCTUnwrap(f.parseDistance("5 mi")), 8_046.72, accuracy: 0.01)
        XCTAssertEqual(f.parseDistance("8 km"), 8_000)
    }

    func testParseDistanceWithoutSuffixUsesUserSystem() throws {
        let m = UnitFormatter(system: .metric)
        let i = UnitFormatter(system: .imperial)
        XCTAssertEqual(m.parseDistance("5"), 5_000) // 5 km
        XCTAssertEqual(try XCTUnwrap(i.parseDistance("5")), 8_046.72, accuracy: 0.01) // 5 mi
    }

    func testParseDuration() {
        let f = UnitFormatter(system: .metric)
        XCTAssertEqual(f.parseDuration("40:00"), 2_400)
        XCTAssertEqual(f.parseDuration("1:25:30"), 5_130)
        XCTAssertEqual(f.parseDuration("45"), 45)
    }

    func testParseGarbageReturnsNil() {
        let f = UnitFormatter(system: .metric)
        XCTAssertNil(f.parseDistance(""))
        XCTAssertNil(f.parseDistance("abc"))
        XCTAssertNil(f.parseDuration("not:a:time:fmt:bad"))
    }
}
