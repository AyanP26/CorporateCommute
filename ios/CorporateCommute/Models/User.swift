import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var email: String
    var phoneNumber: String
    var officeLocation: String
    var role: String
    var createdAt: Date

    // Extended settings fields
    var company: String
    var jobTitle: String
    var workLocation: CommuteLocation?
    var homeLocation: CommuteLocation?
    var preferredRole: String // "Rider", "Driver", "Flexible"
    var vehicleModel: String
    var vehicleColor: String
    var vehicleSeats: Int
    var notificationsEnabled: Bool

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        phoneNumber: String = "",
        officeLocation: String = "Corporate HQ - Innovation Campus",
        role: String = "Commuter",
        createdAt: Date = Date(),
        company: String = "Corporate Inc.",
        jobTitle: String = "Associate",
        workLocation: CommuteLocation? = CommuteLocation.corporateHQ,
        homeLocation: CommuteLocation? = nil,
        preferredRole: String = "Flexible",
        vehicleModel: String = "",
        vehicleColor: String = "",
        vehicleSeats: Int = 3,
        notificationsEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.officeLocation = officeLocation
        self.role = role
        self.createdAt = createdAt
        self.company = company
        self.jobTitle = jobTitle
        self.workLocation = workLocation
        self.homeLocation = homeLocation
        self.preferredRole = preferredRole
        self.vehicleModel = vehicleModel
        self.vehicleColor = vehicleColor
        self.vehicleSeats = vehicleSeats
        self.notificationsEnabled = notificationsEnabled
    }

    var firstName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Commuter" }
        let parts = trimmed.components(separatedBy: " ")
        return parts.first(where: { !$0.isEmpty }) ?? trimmed
    }

    // Firestore Dictionary Representation
    var dictionaryRepresentation: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "name": name,
            "email": email,
            "phoneNumber": phoneNumber,
            "officeLocation": officeLocation,
            "role": role,
            "createdAt": createdAt.timeIntervalSince1970,
            "company": company,
            "jobTitle": jobTitle,
            "preferredRole": preferredRole,
            "vehicleModel": vehicleModel,
            "vehicleColor": vehicleColor,
            "vehicleSeats": vehicleSeats,
            "notificationsEnabled": notificationsEnabled
        ]

        if let work = workLocation {
            dict["workLocation"] = work.dictionaryRepresentation
        }
        if let home = homeLocation {
            dict["homeLocation"] = home.dictionaryRepresentation
        }

        return dict
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

        self.company = dictionary["company"] as? String ?? "Corporate Inc."
        self.jobTitle = dictionary["jobTitle"] as? String ?? "Associate"
        self.preferredRole = dictionary["preferredRole"] as? String ?? "Flexible"
        self.vehicleModel = dictionary["vehicleModel"] as? String ?? ""
        self.vehicleColor = dictionary["vehicleColor"] as? String ?? ""
        self.vehicleSeats = dictionary["vehicleSeats"] as? Int ?? 3
        self.notificationsEnabled = dictionary["notificationsEnabled"] as? Bool ?? true

        if let workDict = dictionary["workLocation"] as? [String: Any] {
            self.workLocation = CommuteLocation(dictionary: workDict)
        } else {
            self.workLocation = CommuteLocation.corporateHQ
        }

        if let homeDict = dictionary["homeLocation"] as? [String: Any] {
            self.homeLocation = CommuteLocation(dictionary: homeDict)
        } else {
            self.homeLocation = nil
        }
    }
}
