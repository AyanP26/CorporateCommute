import Foundation
import Combine

final class MockRideService: RideServiceProtocol {
    @Published private var rides: [CommuteRide] = [
        CommuteRide(
            driverId: "mock_driver_1",
            driverName: "Sarah Chen",
            driverDepartment: "Product & Design",
            vehicleDescription: "Tesla Model Y - White",
            origin: "Downtown Park & Ride",
            destination: "Corporate HQ - Innovation Lab",
            departureTime: "8:00 AM",
            returnTime: "5:00 PM",
            availableSeats: 3,
            totalSeats: 4,
            co2SavedKg: 6.2
        ),
        CommuteRide(
            driverId: "mock_driver_2",
            driverName: "Marcus Johnson",
            driverDepartment: "Data Science",
            vehicleDescription: "Toyota RAV4 Hybrid",
            origin: "Westside Transit Hub",
            destination: "Corporate HQ - Building B",
            departureTime: "8:45 AM",
            returnTime: "5:45 PM",
            availableSeats: 1,
            totalSeats: 4,
            co2SavedKg: 4.8
        ),
        CommuteRide(
            driverId: "mock_driver_3",
            driverName: "Emily Zhao",
            driverDepartment: "Marketing",
            vehicleDescription: "Hyundai Ioniq 5",
            origin: "East Ridge Plaza",
            destination: "Corporate HQ - Building A",
            departureTime: "9:00 AM",
            returnTime: "6:00 PM",
            availableSeats: 2,
            totalSeats: 3,
            co2SavedKg: 5.1
        )
    ]

    // Sample Ride Requests for parity testing
    private var requests: [RideRequest] = [
        RideRequest(
            requestId: "sample_req_1",
            rideId: "mock_driver_1",
            driverId: "mock_driver_1",
            passengerId: "mock_passenger_1",
            passengerName: "Alex Rivera",
            passengerEmail: "alex.rivera@corporate.com",
            route: "Downtown Park & Ride ➔ Corporate HQ",
            status: .pending,
            timestamp: Date().addingTimeInterval(-1800)
        ),
        RideRequest(
            requestId: "sample_req_2",
            rideId: "mock_driver_2",
            driverId: "mock_driver_2",
            passengerId: "mock_passenger_2",
            passengerName: "Elena Rostova",
            passengerEmail: "elena.r@corporate.com",
            route: "Westside Transit Hub ➔ Building B",
            status: .accepted,
            timestamp: Date().addingTimeInterval(-3600)
        )
    ]

    var availableRidesPublisher: AnyPublisher<[CommuteRide], Never> {
        $rides.eraseToAnyPublisher()
    }

    func fetchRides() async throws -> [CommuteRide] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return rides
    }

    func bookRide(rideId: String, userId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        await MainActor.run {
            if let index = rides.firstIndex(where: { $0.id == rideId }) {
                guard rides[index].availableSeats > 0 else { return }
                rides[index].availableSeats -= 1
                if !rides[index].passengerIds.contains(userId) {
                    rides[index].passengerIds.append(userId)
                }
                rides[index].isUserBooked = true
            }
        }
    }

    func cancelBooking(rideId: String, userId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        await MainActor.run {
            if let index = rides.firstIndex(where: { $0.id == rideId }) {
                rides[index].availableSeats += 1
                rides[index].passengerIds.removeAll(where: { $0 == userId })
                rides[index].isUserBooked = false
            }
        }
    }

    func offerRide(_ ride: CommuteRide) async throws -> CommuteRide {
        try await Task.sleep(nanoseconds: 300_000_000)
        await MainActor.run {
            rides.insert(ride, at: 0)
        }
        return ride
    }

    // MARK: - Ride Requests Protocol
    func sendRideRequest(ride: CommuteRide, passenger: User) async throws -> RideRequest {
        try await Task.sleep(nanoseconds: 200_000_000)
        let newRequest = RideRequest(
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
        requests.insert(newRequest, at: 0)
        return newRequest
    }

    func fetchIncomingRequests(for driverId: String) async throws -> [RideRequest] {
        try await Task.sleep(nanoseconds: 200_000_000)
        if driverId.isEmpty || driverId == "mock_driver_1" || driverId == "driver1" {
            return requests.filter { $0.driverId == "mock_driver_1" || $0.driverId == driverId || $0.driverId.isEmpty }
        }
        return requests.filter { $0.driverId == driverId }
    }

    func fetchMySentRequests(for passengerId: String) async throws -> [RideRequest] {
        try await Task.sleep(nanoseconds: 200_000_000)
        if passengerId.isEmpty {
            return requests
        }
        let matching = requests.filter { $0.passengerId == passengerId }
        return matching.isEmpty ? requests : matching
    }

    func updateRequestStatus(requestId: String, status: RideRequestStatus) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        if let index = requests.firstIndex(where: { $0.requestId == requestId }) {
            requests[index].status = status
            // If accepted, decrement available seats for corresponding ride
            if status == .accepted {
                let rideId = requests[index].rideId
                if let rideIndex = rides.firstIndex(where: { $0.id == rideId }), rides[rideIndex].availableSeats > 0 {
                    rides[rideIndex].availableSeats -= 1
                }
            }
        }
    }

    // MARK: - Carpool Group Chat (Mock)
    private var chatMessagesByRideId: [String: [CarpoolChatMessage]] = [
        "mock_ride_1": [
            CarpoolChatMessage(
                rideId: "mock_ride_1",
                senderId: "mock_driver_1",
                senderName: "Sarah Chen",
                text: "Good morning team! Heading out from West Hub at 8:15 AM sharp.",
                timestamp: Date().addingTimeInterval(-1800)
            ),
            CarpoolChatMessage(
                rideId: "mock_ride_1",
                senderId: "mock_user_2",
                senderName: "David Miller",
                text: "Sounds great Sarah! I'll be waiting by the East transit island.",
                timestamp: Date().addingTimeInterval(-1200)
            )
        ]
    ]

    func fetchMessages(for rideId: String) async throws -> [CarpoolChatMessage] {
        try await Task.sleep(nanoseconds: 100_000_000)
        return chatMessagesByRideId[rideId] ?? []
    }

    func sendMessage(rideId: String, text: String, sender: User) async throws -> CarpoolChatMessage {
        let msg = CarpoolChatMessage(
            rideId: rideId,
            senderId: sender.id,
            senderName: sender.name,
            senderEmail: sender.email,
            text: text,
            timestamp: Date(),
            isCurrentUser: true
        )
        if chatMessagesByRideId[rideId] == nil {
            chatMessagesByRideId[rideId] = []
        }
        chatMessagesByRideId[rideId]?.append(msg)
        return msg
    }

    func observeMessages(for rideId: String, onUpdate: @escaping ([CarpoolChatMessage]) -> Void) -> (() -> Void)? {
        let current = chatMessagesByRideId[rideId] ?? []
        onUpdate(current)
        return nil
    }
}
