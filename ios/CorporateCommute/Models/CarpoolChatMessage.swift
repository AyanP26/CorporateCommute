import Foundation
import FirebaseFirestore

struct CarpoolChatMessage: Identifiable, Codable, Equatable {
    var id: String
    var rideId: String
    var senderId: String
    var senderName: String
    var senderEmail: String
    var text: String
    var timestamp: Date
    var isCurrentUser: Bool = false

    init(
        id: String = UUID().uuidString,
        rideId: String,
        senderId: String,
        senderName: String,
        senderEmail: String = "",
        text: String,
        timestamp: Date = Date(),
        isCurrentUser: Bool = false
    ) {
        self.id = id
        self.rideId = rideId
        self.senderId = senderId
        self.senderName = senderName
        self.senderEmail = senderEmail
        self.text = text
        self.timestamp = timestamp
        self.isCurrentUser = isCurrentUser
    }

    init?(dictionary: [String: Any], documentId: String) {
        guard let text = dictionary["text"] as? String else { return nil }
        self.id = (dictionary["messageId"] as? String) ?? documentId
        self.rideId = (dictionary["rideId"] as? String) ?? "general_commuter_chat"
        self.senderId = (dictionary["senderId"] as? String) ?? ""
        self.senderName = (dictionary["senderName"] as? String) ?? "Commuter"
        self.senderEmail = (dictionary["senderEmail"] as? String) ?? ""
        self.text = text
        self.isCurrentUser = false

        // Parse timestamp: Android writes System.currentTimeMillis() (Long)
        if let ms = dictionary["timestamp"] as? Int64 {
            self.timestamp = Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
        } else if let msDouble = dictionary["timestamp"] as? Double {
            if msDouble > 10_000_000_000 {
                self.timestamp = Date(timeIntervalSince1970: msDouble / 1000.0)
            } else {
                self.timestamp = Date(timeIntervalSince1970: msDouble)
            }
        } else if let ts = dictionary["timestamp"] as? Timestamp {
            self.timestamp = ts.dateValue()
        } else {
            self.timestamp = Date()
        }
    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "messageId": id,
            "rideId": rideId,
            "senderId": senderId,
            "senderName": senderName,
            "senderEmail": senderEmail,
            "text": text,
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000)
        ]
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var senderFirstName: String {
        let trimmed = senderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Colleague" }
        let components = trimmed.components(separatedBy: " ")
        return components.first(where: { !$0.isEmpty }) ?? trimmed
    }
}
