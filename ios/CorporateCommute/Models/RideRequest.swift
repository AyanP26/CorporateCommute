import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

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
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000)
        ]
    }

    init?(dictionary: [String: Any], documentId: String? = nil) {
        let reqId = (dictionary["requestId"] as? String) ?? documentId ?? UUID().uuidString
        guard let rideId = dictionary["rideId"] as? String else {
            return nil
        }
        let driverId = (dictionary["driverId"] as? String) ?? ""

        self.requestId = reqId
        self.rideId = rideId
        self.driverId = driverId
        self.passengerId = dictionary["passengerId"] as? String ?? ""
        self.passengerName = dictionary["passengerName"] as? String ?? "Colleague"
        self.passengerEmail = dictionary["passengerEmail"] as? String ?? ""

        let rawRoute = dictionary["route"] as? String ?? "Commute Route"
        self.route = rawRoute.replacingOccurrences(of: "null ->", with: "Pickup ->")

        let statusString = (dictionary["status"] as? String)?.uppercased() ?? "PENDING"
        self.status = RideRequestStatus(rawValue: statusString) ?? .pending

        #if canImport(FirebaseFirestore)
        if let ts = dictionary["timestamp"] as? Timestamp {
            self.timestamp = ts.dateValue()
        } else if let num = dictionary["timestamp"] as? NSNumber {
            self.timestamp = Date(timeIntervalSince1970: num.doubleValue / 1000.0)
        } else if let millis = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: millis / 1000.0)
        } else if let millis = dictionary["timestamp"] as? Int64 {
            self.timestamp = Date(timeIntervalSince1970: Double(millis) / 1000.0)
        } else if let millis = dictionary["timestamp"] as? Int {
            self.timestamp = Date(timeIntervalSince1970: Double(millis) / 1000.0)
        } else {
            self.timestamp = Date()
        }
        #else
        if let num = dictionary["timestamp"] as? NSNumber {
            self.timestamp = Date(timeIntervalSince1970: num.doubleValue / 1000.0)
        } else if let millis = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: millis / 1000.0)
        } else if let millis = dictionary["timestamp"] as? Int64 {
            self.timestamp = Date(timeIntervalSince1970: Double(millis) / 1000.0)
        } else if let millis = dictionary["timestamp"] as? Int {
            self.timestamp = Date(timeIntervalSince1970: Double(millis) / 1000.0)
        } else {
            self.timestamp = Date()
        }
        #endif
    }
}
