import XCTest

final class CorporateCommuteUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testWelcomeScreenElementsExist() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Welcome to Corporate\nCommute!"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Login"].exists)
        XCTAssertTrue(app.buttons["Create an Account"].exists)
    }

    func testNavigateToCreateAccount() throws {
        let app = XCUIApplication()
        app.launch()

        let createAccountButton = app.buttons["Create an Account"]
        XCTAssertTrue(createAccountButton.waitForExistence(timeout: 5))
        createAccountButton.tap()

        XCTAssertTrue(app.staticTexts["Create an Account"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Submit"].exists)
    }
}
