import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var email: String
    var phoneNumber: String
    var officeLocation: String
    var role: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        phoneNumber: String = "",
        officeLocation: String = "Corporate HQ - Innovation Campus",
        role: String = "Commuter",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.officeLocation = officeLocation
        self.role = role
        self.createdAt = createdAt
    }

    // Firestore Dictionary Representation
    var dictionaryRepresentation: [String: Any] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "phoneNumber": phoneNumber,
            "officeLocation": officeLocation,
            "role": role,
            "createdAt": createdAt.timeIntervalSince1970
        ]
    }

    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String ?? dictionary["uid"] as? String,
              let name = dictionary["name"] as? String,
              let email = dictionary["email"] as? String else {
            return nil
        }
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        self.officeLocation = dictionary["officeLocation"] as? String ?? "Corporate HQ"
        self.role = dictionary["role"] as? String ?? "Commuter"
        if let timestamp = dictionary["createdAt"] as? TimeInterval {
            self.createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            self.createdAt = Date()
        }
    }
}
