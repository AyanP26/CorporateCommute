import Foundation

enum RideRequestStatus: String, Codable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case declined = "DECLINED"

    var title: String {
        switch self {
        case .pending: return "PENDING"
        case .accepted: return "ACCEPTED"
        case .declined: return "DECLINED"
        }
    }
}

struct RideRequest: Identifiable, Codable, Equatable {
    var id: String { requestId }
    var requestId: String
    var rideId: String
    var driverId: String
    var passengerId: String
    var passengerName: String
    var passengerEmail: String
    var route: String
    var status: RideRequestStatus
    var timestamp: Date

    init(
        requestId: String = UUID().uuidString,
        rideId: String,
        driverId: String,
        passengerId: String,
        passengerName: String,
        passengerEmail: String,
        route: String,
        status: RideRequestStatus = .pending,
        timestamp: Date = Date()
    ) {
        self.requestId = requestId
        self.rideId = rideId
        self.driverId = driverId
        self.passengerId = passengerId
        self.passengerName = passengerName
        self.passengerEmail = passengerEmail
        self.route = route
        self.status = status
        self.timestamp = timestamp
    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "requestId": requestId,
            "rideId": rideId,
            "driverId": driverId,
            "passengerId": passengerId,
            "passengerName": passengerName,
            "passengerEmail": passengerEmail,
            "route": route,
            "status": status.rawValue,
            "timestamp": timestamp.timeIntervalSince1970 * 1000
        ]
    }

    init?(dictionary: [String: Any], documentId: String? = nil) {
        let reqId = (dictionary["requestId"] as? String) ?? documentId ?? UUID().uuidString
        guard let rideId = dictionary["rideId"] as? String,
              let driverId = dictionary["driverId"] as? String else {
            return nil
        }

        self.requestId = reqId
        self.rideId = rideId
        self.driverId = driverId
        self.passengerId = dictionary["passengerId"] as? String ?? ""
        self.passengerName = dictionary["passengerName"] as? String ?? "Colleague"
        self.passengerEmail = dictionary["passengerEmail"] as? String ?? ""
        self.route = dictionary["route"] as? String ?? "Commute Route"

        let statusString = dictionary["status"] as? String ?? "PENDING"
        self.status = RideRequestStatus(rawValue: statusString) ?? .pending

        if let millis = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: millis / 1000.0)
        } else if let millis = dictionary["timestamp"] as? Int64 {
            self.timestamp = Date(timeIntervalSince1970: Double(millis) / 1000.0)
        } else {
            self.timestamp = Date()
        }
    }
}
