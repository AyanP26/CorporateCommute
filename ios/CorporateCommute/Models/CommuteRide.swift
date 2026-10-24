import Foundation

enum RideStatus: String, Codable {
    case scheduled = "Scheduled"
    case inProgress = "En Route"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

struct CommuteRide: Identifiable, Codable, Equatable {
    let id: UUID
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
    var isUserBooked: Bool

    init(
        id: UUID = UUID(),
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
        isUserBooked: Bool = false
    ) {
        self.id = id
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
        self.isUserBooked = isUserBooked
    }
}
