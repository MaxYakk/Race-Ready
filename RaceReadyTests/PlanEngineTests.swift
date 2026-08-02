import XCTest
@testable import RaceReady

final class PlanEngineTests: XCTestCase {

    // MARK: - Phase boundaries

    func testPhaseDetectionAtBoundaries() {
        XCTAssertEqual(PlanEngine.phase(forCompletedSessions: 0), .base)
        XCTAssertEqual(PlanEngine.phase(forCompletedSessions: 35), .base)
        XCTAssertEqual(PlanEngine.phase(forCompletedSessions: 36), .build, "36 = end of P1, next session is P2")
        XCTAssertEqual(PlanEngine.phase(forCompletedSessions: 71), .build)
        XCTAssertEqual(PlanEngine.phase(forCompletedSessions: 72), .peak)
        XCTAssertEqual(PlanEngine.phase(forCompletedSessions: 101), .peak)
        XCTAssertEqual(PlanEngine.phase(forCompletedSessions: 102), .taper)
        XCTAssertEqual(PlanEngine.phase(forCompletedSessions: 104), .taper)
    }

    // MARK: - Week mapping

    func testWeekNumberAtPhaseStart() {
        XCTAssertEqual(PlanEngine.weekNumber(forCompletedSessions: 0), 1)
        XCTAssertEqual(PlanEngine.weekNumber(forCompletedSessions: 6), 2)
        XCTAssertEqual(PlanEngine.weekNumber(forCompletedSessions: 35), 6)
        XCTAssertEqual(PlanEngine.weekNumber(forCompletedSessions: 36), 7, "first session of P2")
        XCTAssertEqual(PlanEngine.weekNumber(forCompletedSessions: 72), 13)
        XCTAssertEqual(PlanEngine.weekNumber(forCompletedSessions: 102), 18)
    }

    // MARK: - Plan content invariants

    func testPlanHasExpectedSessionCount() {
        XCTAssertEqual(PlanData.allTemplates.count, 105,
                       "Expected 36 + 36 + 30 + 3 = 105 sessions across all phases")
    }

    func testPhase1HasSixSessionsPerWeek() {
        for week in 1...6 {
            XCTAssertEqual(PlanData.templates(forWeek: week).count, 6, "Week \(week)")
        }
    }

    func testPhase4HasThreeSessions() {
        XCTAssertEqual(PlanData.templates(forWeek: 18).count, 3)
    }

    func testTemplateIdsAreUnique() {
        let ids = PlanData.allTemplates.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All template ids must be unique")
    }

    func testEveryTemplateMapsToCorrectPhase() {
        for template in PlanData.allTemplates {
            XCTAssertTrue(template.phase.weekRange.contains(template.weekNumber),
                          "Template \(template.id) week \(template.weekNumber) not in phase \(template.phase)")
        }
    }

    // MARK: - Days until race

    func testDaysUntilRaceFromSpecificDate() {
        let cal = Calendar(identifier: .gregorian)
        var now = DateComponents(); now.year = 2026; now.month = 5; now.day = 17
        var race = DateComponents(); race.year = 2026; race.month = 9; race.day = 18
        let result = PlanEngine.daysUntilRace(
            from: cal.date(from: now)!,
            raceDate: cal.date(from: race)!,
            calendar: cal
        )
        XCTAssertEqual(result, 124, "From 2026-05-17 to 2026-09-18 should be 124 days")
    }
}
