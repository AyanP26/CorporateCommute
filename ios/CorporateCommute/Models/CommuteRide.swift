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
        self.driverDepartment = dictionary["driverDepartment"] as? String ?? "Corporate Commute"
        self.vehicleDescription = dictionary["vehicleDescription"] as? String ?? "Colleague Vehicle"
        self.origin = origin
        self.destination = destination
        self.departureDate = dictionary["departureDate"] as? String ?? ""
        self.departureTime = departureTime
        self.returnTime = dictionary["returnTime"] as? String
        self.availableSeats = (dictionary["availableSeats"] as? NSNumber)?.intValue ?? (dictionary["availableSeats"] as? Int) ?? 1
        self.totalSeats = (dictionary["totalSeats"] as? NSNumber)?.intValue ?? (dictionary["totalSeats"] as? Int) ?? 4
        self.notes = dictionary["notes"] as? String ?? ""
        self.co2SavedKg = (dictionary["co2SavedKg"] as? NSNumber)?.doubleValue ?? (dictionary["co2SavedKg"] as? Double) ?? 4.0
        let statusStr = dictionary["status"] as? String ?? RideStatus.scheduled.rawValue
        self.status = RideStatus(rawValue: statusStr) ?? .scheduled
        self.passengerIds = dictionary["passengerIds"] as? [String] ?? []
        self.isUserBooked = false
        self.hasPendingRequest = false
    }

    // MARK: - Departure Parsing & 24-Hour Cancellation Policy
    var departureDateTime: Date? {
        let combined = "\(departureDate) \(departureTime)"
        let formats = [
            "yyyy-MM-dd h:mm a",
            "yyyy-MM-dd hh:mm a",
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd H:mm",
            "EEE, MMM d h:mm a",
            "EEE, MMM d hh:mm a",
            "MMM d, yyyy h:mm a",
            "MMM d h:mm a",
            "MM/dd/yyyy h:mm a",
            "h:mm a"
        ]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")

        for format in formats {
            df.dateFormat = format
            if let d = df.date(from: combined) {
                let cal = Calendar.current
                var comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: d)
                if comps.year == 2000 || comps.year == nil || comps.year == 1970 {
                    comps.year = cal.component(.year, from: Date())
                    if let fixed = cal.date(from: comps) {
                        return fixed
                    }
                }
                return d
            }
        }

        // Fallback: match time only for today
        df.dateFormat = "h:mm a"
        if let timeOnly = df.date(from: departureTime) {
            let cal = Calendar.current
            let timeComps = cal.dateComponents([.hour, .minute], from: timeOnly)
            if let merged = cal.date(bySettingHour: timeComps.hour ?? 8, minute: timeComps.minute ?? 0, second: 0, of: Date()) {
                return merged
            }
        }
        return nil
    }

    /// True if the carpool is scheduled more than 24 hours in the future.
    /// Rides scheduled in less than 24 hours cannot be cancelled to protect riders.
    var canBeDeleted: Bool {
        guard let pickup = departureDateTime else {
            return true
        }
        let interval = pickup.timeIntervalSince(Date())
        return interval >= (24.0 * 3600.0)
    }

    var hoursUntilPickup: Double? {
        guard let pickup = departureDateTime else { return nil }
        return pickup.timeIntervalSince(Date()) / 3600.0
    }
}
