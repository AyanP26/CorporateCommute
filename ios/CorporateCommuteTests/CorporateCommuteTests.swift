import XCTest
@testable import CorporateCommute

final class CorporateCommuteTests: XCTestCase {

    func testUserInitialization() {
        let user = User(
            name: "Jane Doe",
            email: "jane@company.com",
            phoneNumber: "555-123-4567"
        )

        XCTAssertEqual(user.name, "Jane Doe")
        XCTAssertEqual(user.email, "jane@company.com")
        XCTAssertEqual(user.phoneNumber, "555-123-4567")
    }

    func testAuthViewModelValidation() {
        let viewModel = AuthViewModel()

        // Initially invalid
        XCTAssertFalse(viewModel.isRegistrationValid)
        XCTAssertFalse(viewModel.isLoginValid)

        // Valid data
        viewModel.name = "John Smith"
        viewModel.email = "john@example.com"
        viewModel.password = "secret123"
        viewModel.phoneNumber = "1234567890"

        XCTAssertTrue(viewModel.isRegistrationValid)
        XCTAssertTrue(viewModel.isLoginValid)
    }

    func testLogoutResetsState() {
        let viewModel = AuthViewModel()
        viewModel.name = "John Smith"
        viewModel.isAuthenticated = true

        viewModel.logout()

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.currentUser)
        XCTAssertTrue(viewModel.name.isEmpty)
    }
}
