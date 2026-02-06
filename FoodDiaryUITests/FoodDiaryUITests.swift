import XCTest

final class FoodDiaryUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchShowsDailyDiary() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify we landed on the main screen
        XCTAssertTrue(app.navigationBars["Today"].exists)
    }

    @MainActor
    func testOpenAddEntrySheet() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Add entry"].tap()

        XCTAssertTrue(app.navigationBars["Add Entry"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
