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
    var driverDepartment: String
    var vehicleDescription: String
    var origin: String
    var destination: String
    var departureTime: String
    var returnTime: String?
    var availableSeats: Int
    var totalSeats: Int
    var co2SavedKg: Double
    var status: RideStatus
    var passengerIds: [String]
    var isUserBooked: Bool

    init(
        id: String = UUID().uuidString,
        driverId: String = "mock_driver_1",
        driverName: String,
        driverDepartment: String,
        vehicleDescription: String,
        origin: String,
        destination: String,
        departureTime: String,
        returnTime: String? = nil,
        availableSeats: Int,
        totalSeats: Int,
        co2SavedKg: Double = 4.2,
        status: RideStatus = .scheduled,
        passengerIds: [String] = [],
        isUserBooked: Bool = false
    ) {
        self.id = id
        self.driverId = driverId
        self.driverName = driverName
        self.driverDepartment = driverDepartment
        self.vehicleDescription = vehicleDescription
        self.origin = origin
        self.destination = destination
        self.departureTime = departureTime
        self.returnTime = returnTime
        self.availableSeats = availableSeats
        self.totalSeats = totalSeats
        self.co2SavedKg = co2SavedKg
        self.status = status
        self.passengerIds = passengerIds
        self.isUserBooked = isUserBooked
    }

    var dictionaryRepresentation: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "driverId": driverId,
            "driverName": driverName,
            "driverDepartment": driverDepartment,
            "vehicleDescription": vehicleDescription,
            "origin": origin,
            "destination": destination,
            "departureTime": departureTime,
            "availableSeats": availableSeats,
            "totalSeats": totalSeats,
            "co2SavedKg": co2SavedKg,
            "status": status.rawValue,
            "passengerIds": passengerIds
        ]
        if let returnTime = returnTime {
            dict["returnTime"] = returnTime
        }
        return dict
    }

    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let driverName = dictionary["driverName"] as? String,
              let origin = dictionary["origin"] as? String,
              let destination = dictionary["destination"] as? String,
              let departureTime = dictionary["departureTime"] as? String else {
            return nil
        }
        self.id = id
        self.driverId = dictionary["driverId"] as? String ?? ""
        self.driverName = driverName
        self.driverDepartment = dictionary["driverDepartment"] as? String ?? "General"
        self.vehicleDescription = dictionary["vehicleDescription"] as? String ?? "Standard Vehicle"
        self.origin = origin
        self.destination = destination
        self.departureTime = departureTime
        self.returnTime = dictionary["returnTime"] as? String
        self.availableSeats = dictionary["availableSeats"] as? Int ?? 0
        self.totalSeats = dictionary["totalSeats"] as? Int ?? 4
        self.co2SavedKg = dictionary["co2SavedKg"] as? Double ?? 4.0
        let statusStr = dictionary["status"] as? String ?? RideStatus.scheduled.rawValue
        self.status = RideStatus(rawValue: statusStr) ?? .scheduled
        self.passengerIds = dictionary["passengerIds"] as? [String] ?? []
        self.isUserBooked = false
    }
}
