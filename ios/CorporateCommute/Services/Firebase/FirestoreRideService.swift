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
        return newRide
        #else
        return ride
        #endif
    }
}
