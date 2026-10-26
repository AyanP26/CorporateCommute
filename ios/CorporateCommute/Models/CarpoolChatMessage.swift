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
