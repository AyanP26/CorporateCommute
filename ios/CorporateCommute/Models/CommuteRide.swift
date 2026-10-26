import Foundation

enum RideStatus: String, Codable {
    case scheduled = "Scheduled"
    case inProgress = "En Route"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

struct CommuteRide: Identifiable, Codable, Equatable {
    var id: String
    var driverId: String
    var driverName: String
    var driverEmail: String
    var driverDepartment: String
    var vehicleDescription: String
    var origin: String
    var destination: String
    var departureDate: String
    var departureTime: String
    var returnTime: String?
    var availableSeats: Int
    var totalSeats: Int
    var notes: String
    var co2SavedKg: Double
    var status: RideStatus
    var passengerIds: [String]
    var isUserBooked: Bool
    var hasPendingRequest: Bool

    init(
        id: String = UUID().uuidString,
        driverId: String = "mock_driver_1",
        driverName: String,
        driverEmail: String = "",
        driverDepartment: String = "General",
        vehicleDescription: String = "Standard Vehicle",
        origin: String,
        destination: String,
        departureDate: String = "",
        departureTime: String,
        returnTime: String? = nil,
        availableSeats: Int,
        totalSeats: Int = 4,
        notes: String = "",
        co2SavedKg: Double = 4.2,
        status: RideStatus = .scheduled,
        passengerIds: [String] = [],
        isUserBooked: Bool = false,
        hasPendingRequest: Bool = false
    ) {
        self.id = id
        self.driverId = driverId
        self.driverName = driverName
        self.driverEmail = driverEmail
        self.driverDepartment = driverDepartment
        self.vehicleDescription = vehicleDescription
        self.origin = origin
        self.destination = destination
        self.departureDate = departureDate.isEmpty ? Self.currentDateString() : departureDate
        self.departureTime = departureTime
        self.returnTime = returnTime
        self.availableSeats = availableSeats
        self.totalSeats = totalSeats
        self.notes = notes
        self.co2SavedKg = co2SavedKg
        self.status = status
        self.passengerIds = passengerIds
        self.isUserBooked = isUserBooked
        self.hasPendingRequest = hasPendingRequest
    }

    private static func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var dictionaryRepresentation: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "rideId": id,
            "driverId": driverId,
            "driverName": driverName,
            "driverEmail": driverEmail,
            "driverDepartment": driverDepartment,
            "vehicleDescription": vehicleDescription,
            "origin": origin,
            "pickupLocation": origin, // Android compatibility
            "destination": destination,
            "departureDate": departureDate,
            "departureTime": departureTime,
            "availableSeats": availableSeats,
            "totalSeats": totalSeats,
            "notes": notes,
            "co2SavedKg": co2SavedKg,
            "status": status.rawValue,
            "passengerIds": passengerIds,
            "createdAt": Date().timeIntervalSince1970 * 1000
        ]
        if let returnTime = returnTime {
            dict["returnTime"] = returnTime
        }
        return dict
    }

    init?(dictionary: [String: Any]) {
        let parsedId = (dictionary["id"] as? String) ?? (dictionary["rideId"] as? String) ?? UUID().uuidString
        let parsedOrigin = (dictionary["origin"] as? String) ?? (dictionary["pickupLocation"] as? String)
        guard let origin = parsedOrigin,
              let destination = dictionary["destination"] as? String,
              let departureTime = dictionary["departureTime"] as? String else {
            return nil
        }

        self.id = parsedId
        self.driverId = dictionary["driverId"] as? String ?? ""
        self.driverName = dictionary["driverName"] as? String ?? "Commuter"
        self.driverEmail = dictionary["driverEmail"] as? String ?? ""
        self.driverDepartment = dictionary["driverDepartment"] as? String ?? "General"
        self.vehicleDescription = dictionary["vehicleDescription"] as? String ?? "Standard Vehicle"
        self.origin = origin
        self.destination = destination
        self.departureDate = dictionary["departureDate"] as? String ?? ""
        self.departureTime = departureTime
        self.returnTime = dictionary["returnTime"] as? String
        self.availableSeats = dictionary["availableSeats"] as? Int ?? 1
        self.totalSeats = dictionary["totalSeats"] as? Int ?? 4
        self.notes = dictionary["notes"] as? String ?? ""
        self.co2SavedKg = dictionary["co2SavedKg"] as? Double ?? 4.0
        let statusStr = dictionary["status"] as? String ?? RideStatus.scheduled.rawValue
        self.status = RideStatus(rawValue: statusStr) ?? .scheduled
        self.passengerIds = dictionary["passengerIds"] as? [String] ?? []
        self.isUserBooked = false
        self.hasPendingRequest = false
    }
}
