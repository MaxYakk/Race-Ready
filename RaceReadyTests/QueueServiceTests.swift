import XCTest
import SwiftData
@testable import RaceReady

@MainActor
final class QueueServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var service: QueueService!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: SessionLog.self, RunLog.self, BenchmarkEntry.self,
            QueueState.self, UserSettings.self,
            TemplateRecord.self, BlockRecord.self, ItemRecord.self,
            configurations: config
        )
        context = container.mainContext
        TemplateStore(context: context).seedIfNeeded()
        service = QueueService(context: context)
    }

    func testFirstFetchSeedsQueueWithAllTemplates() {
        let state = service.fetchOrCreate()
        XCTAssertEqual(state.orderedTemplateIds.count, PlanData.allTemplates.count)
        XCTAssertEqual(state.orderedTemplateIds.first, PlanData.allTemplates.first?.id)
    }

    func testUpNextReturnsFirstTemplate() {
        let up = service.upNext()
        XCTAssertEqual(up?.weekNumber, 1)
        XCTAssertEqual(up?.sessionType, .pushDay)
    }

    func testUpcomingReturnsPrefix() {
        let upcoming = service.upcoming(limit: 3)
        XCTAssertEqual(upcoming.count, 3)
        XCTAssertEqual(upcoming.map(\.id),
                       Array(PlanData.allTemplates.prefix(3).map(\.id)))
    }

    func testAdvanceRemovesHead() {
        let originalHead = service.upNext()?.id
        let removed = service.advance()
        XCTAssertEqual(removed?.id, originalHead)
        XCTAssertNotEqual(service.upNext()?.id, originalHead)
    }

    func testSkipRescheduleMovesHeadToTail() {
        let originalHead = service.upNext()?.id
        service.skipReschedule()
        let state = service.fetchOrCreate()
        XCTAssertNotEqual(state.orderedTemplateIds.first, originalHead)
        XCTAssertEqual(state.orderedTemplateIds.last, originalHead)
        XCTAssertEqual(state.orderedTemplateIds.count, PlanData.allTemplates.count)
    }

    func testSkipDropRemovesHeadEntirely() {
        let originalHead = service.upNext()?.id
        let originalCount = service.remainingCount()
        service.skipDrop()
        let state = service.fetchOrCreate()
        XCTAssertFalse(state.orderedTemplateIds.contains(originalHead ?? ""))
        XCTAssertTrue(state.droppedTemplateIds.contains(originalHead ?? ""))
        XCTAssertEqual(service.remainingCount(), originalCount - 1)
    }

    func testSwapPromotesEarliestTemplateOfType() {
        // Head is Week 1 Push. Swap to easyRun → should promote Week 1 Easy Run.
        let didSwap = service.swap(toType: .easyRun)
        XCTAssertTrue(didSwap)
        let newHead = service.upNext()
        XCTAssertEqual(newHead?.sessionType, .easyRun)
        XCTAssertEqual(newHead?.weekNumber, 1)
    }

    func testSwapReturnsFalseWhenAlreadyAtHead() {
        let head = service.upNext()!
        let didSwap = service.swap(toType: head.sessionType)
        XCTAssertFalse(didSwap)
    }

    func testSwapPushesOldHeadToTail() {
        let oldHead = service.upNext()?.id
        service.swap(toType: .easyRun)
        let state = service.fetchOrCreate()
        XCTAssertEqual(state.orderedTemplateIds.last, oldHead)
    }

    func testResetToDefaultOrderRestoresWithoutDropped() {
        service.skipDrop() // drop head
        let droppedId = service.fetchOrCreate().droppedTemplateIds.first!
        service.swap(toType: .easyRun) // reorder
        service.resetToDefaultOrder()
        let state = service.fetchOrCreate()
        XCTAssertFalse(state.orderedTemplateIds.contains(droppedId))
        XCTAssertEqual(state.orderedTemplateIds.count, PlanData.allTemplates.count - 1)
        // First non-dropped template should now be at head
        let firstNonDropped = PlanData.allTemplates.map(\.id).first { $0 != droppedId }
        XCTAssertEqual(state.orderedTemplateIds.first, firstNonDropped)
    }
}
