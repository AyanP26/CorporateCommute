import Foundation
import Combine

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

final class FirestoreRideService: RideServiceProtocol {
    @Published private var rides: [CommuteRide] = []

    var availableRidesPublisher: AnyPublisher<[CommuteRide], Never> {
        $rides.eraseToAnyPublisher()
    }

    #if canImport(FirebaseFirestore)
    private var listenerRegistration: ListenerRegistration?
    #endif

    init() {
        startObservingRides()
    }

    deinit {
        #if canImport(FirebaseFirestore)
        listenerRegistration?.remove()
        #endif
    }

    private func startObservingRides() {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        listenerRegistration = db.collection("rides")
            .whereField("status", isEqualTo: RideStatus.scheduled.rawValue)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                let loadedRides = documents.compactMap { doc -> CommuteRide? in
                    var data = doc.data()
                    data["id"] = doc.documentID
                    return CommuteRide(dictionary: data)
                }
                Task { @MainActor in
                    self.rides = loadedRides
                }
            }
        #endif
    }

    func fetchRides() async throws -> [CommuteRide] {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let snapshot = try await db.collection("rides").getDocuments()
        let loadedRides = snapshot.documents.compactMap { doc -> CommuteRide? in
            var data = doc.data()
            data["id"] = doc.documentID
            return CommuteRide(dictionary: data)
        }
        await MainActor.run {
            self.rides = loadedRides
        }
        return loadedRides
        #else
        return []
        #endif
    }

    func bookRide(rideId: String, userId: String) async throws {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let rideRef = db.collection("rides").document(rideId)

        try await db.runTransaction { transaction, errorPointer in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(rideRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let availableSeats = document.data()?["availableSeats"] as? Int, availableSeats > 0 else {
                let error = NSError(domain: "RideError", code: 400, userInfo: [NSLocalizedDescriptionKey: "No available seats remaining."])
                errorPointer?.pointee = error
                return nil
            }

            transaction.updateData([
                "availableSeats": availableSeats - 1,
                "passengerIds": FieldValue.arrayUnion([userId])
            ], forDocument: rideRef)

            return nil
        }
        #endif
    }

    func cancelBooking(rideId: String, userId: String) async throws {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let rideRef = db.collection("rides").document(rideId)

        try await db.runTransaction { transaction, errorPointer in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(rideRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            let availableSeats = document.data()?["availableSeats"] as? Int ?? 0

            transaction.updateData([
                "availableSeats": availableSeats + 1,
                "passengerIds": FieldValue.arrayRemove([userId])
            ], forDocument: rideRef)

            return nil
        }
        #endif
    }

    func offerRide(_ ride: CommuteRide) async throws -> CommuteRide {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        var newRide = ride
        let docRef = try await db.collection("rides").addDocument(data: ride.dictionaryRepresentation)
        newRide.id = docRef.documentID
        try await docRef.updateData(["rideId": docRef.documentID, "id": docRef.documentID])
        return newRide
        #else
        return ride
        #endif
    }

    // MARK: - Ride Requests Protocol (Parity with Android)
    func sendRideRequest(ride: CommuteRide, passenger: User) async throws -> RideRequest {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let request = RideRequest(
            requestId: UUID().uuidString,
            rideId: ride.id,
            driverId: ride.driverId,
            passengerId: passenger.id,
            passengerName: passenger.name.isEmpty ? "Commuter" : passenger.name,
            passengerEmail: passenger.email,
            route: "\(ride.origin) ➔ \(ride.destination)",
            status: .pending,
            timestamp: Date()
        )

        let docRef = try await db.collection("ride_requests").addDocument(data: request.dictionaryRepresentation)
        try await docRef.updateData(["requestId": docRef.documentID])
        var saved = request
        saved.requestId = docRef.documentID
        return saved
        #else
        return RideRequest(
            rideId: ride.id,
            driverId: ride.driverId,
            passengerId: passenger.id,
            passengerName: passenger.name,
            passengerEmail: passenger.email,
            route: "\(ride.origin) ➔ \(ride.destination)"
        )
        #endif
    }

    func fetchIncomingRequests(for driverId: String) async throws -> [RideRequest] {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let querySnapshot = try await db.collection("ride_requests").getDocuments()
        let requests = querySnapshot.documents.compactMap { doc -> RideRequest? in
            var data = doc.data()
            data["requestId"] = doc.documentID
            return RideRequest(dictionary: data, documentId: doc.documentID)
        }

        if driverId.isEmpty || driverId == "mock_driver_1" || driverId == "driver1" {
            return requests.filter { $0.driverId == "mock_driver_1" || $0.driverId == "driver1" || $0.driverId.isEmpty || $0.driverId == driverId }
        }
        return requests.filter { $0.driverId == driverId }
        #else
        return []
        #endif
    }

    func fetchMySentRequests(for passengerId: String) async throws -> [RideRequest] {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let querySnapshot = try await db.collection("ride_requests").getDocuments()
        let requests = querySnapshot.documents.compactMap { doc -> RideRequest? in
            var data = doc.data()
            data["requestId"] = doc.documentID
            return RideRequest(dictionary: data, documentId: doc.documentID)
        }

        if passengerId.isEmpty {
            return requests
        }
        let matching = requests.filter { $0.passengerId == passengerId }
        return matching.isEmpty ? requests : matching
        #else
        return []
        #endif
    }

    func updateRequestStatus(requestId: String, status: RideRequestStatus) async throws {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let reqRef = db.collection("ride_requests").document(requestId)
        try await reqRef.updateData(["status": status.rawValue])

        // If accepted, update ride's available seats
        if status == .accepted {
            let doc = try await reqRef.getDocument()
            if let rideId = doc.data()?["rideId"] as? String, !rideId.isEmpty {
                let rideRef = db.collection("rides").document(rideId)
                try await db.runTransaction { transaction, errorPointer in
                    guard let rideDoc = try? transaction.getDocument(rideRef),
                          let seats = rideDoc.data()?["availableSeats"] as? Int, seats > 0 else {
                        return nil
                    }
                    transaction.updateData(["availableSeats": seats - 1], forDocument: rideRef)
                    return nil
                }
            }
        }
        #endif
    }

    func deleteRide(rideId: String) async throws {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        try await db.collection("rides").document(rideId).delete()

        // Also clean up any associated ride requests for this ride
        let reqs = try? await db.collection("ride_requests").whereField("rideId", isEqualTo: rideId).getDocuments()
        if let docs = reqs?.documents {
            for doc in docs {
                try? await doc.reference.delete()
            }
        }
        #endif
    }

    // MARK: - Carpool Group Chat (Cross-Platform with Android via "messages" collection)
    func fetchMessages(for rideId: String) async throws -> [CarpoolChatMessage] {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let snapshot = try await db.collection("messages")
            .whereField("rideId", isEqualTo: rideId)
            .getDocuments()

        var messages = snapshot.documents.compactMap { doc -> CarpoolChatMessage? in
            return CarpoolChatMessage(dictionary: doc.data(), documentId: doc.documentID)
        }
        // In-memory sort by timestamp (avoids composite index requirement, matches Android)
        messages.sort { $0.timestamp < $1.timestamp }
        return messages
        #else
        return []
        #endif
    }

    func sendMessage(rideId: String, text: String, sender: User) async throws -> CarpoolChatMessage {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let msgRef = db.collection("messages").document()
        let now = Date()
        let newMsg = CarpoolChatMessage(
            id: msgRef.documentID,
            rideId: rideId,
            senderId: sender.id,
            senderName: sender.name,
            senderEmail: sender.email,
            text: text,
            timestamp: now,
            isCurrentUser: true
        )
        try await msgRef.setData(newMsg.dictionaryRepresentation)
        return newMsg
        #else
        return CarpoolChatMessage(rideId: rideId, senderId: sender.id, senderName: sender.name, text: text, isCurrentUser: true)
        #endif
    }

    func observeMessages(for rideId: String, onUpdate: @escaping ([CarpoolChatMessage]) -> Void) -> (() -> Void)? {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let listener = db.collection("messages")
            .whereField("rideId", isEqualTo: rideId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else { return }
                var messages = documents.compactMap { doc -> CarpoolChatMessage? in
                    return CarpoolChatMessage(dictionary: doc.data(), documentId: doc.documentID)
                }
                messages.sort { $0.timestamp < $1.timestamp }
                onUpdate(messages)
            }
        return {
            listener.remove()
        }
        #else
        return nil
        #endif
    }
}
