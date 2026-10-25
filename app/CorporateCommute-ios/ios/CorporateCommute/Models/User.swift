import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var phoneNumber: String

    init(id: UUID = UUID(), name: String, email: String, phoneNumber: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}
