import Foundation
import Combine

protocol RideServiceProtocol: AnyObject {
    var availableRidesPublisher: AnyPublisher<[CommuteRide], Never> { get }

    func fetchRides() async throws -> [CommuteRide]
    func bookRide(rideId: String, userId: String) async throws
    func cancelBooking(rideId: String, userId: String) async throws
    func offerRide(_ ride: CommuteRide) async throws -> CommuteRide
    func deleteRide(rideId: String) async throws

    // Ride Requests (Parity with Android)
    func sendRideRequest(ride: CommuteRide, passenger: User) async throws -> RideRequest
    func fetchIncomingRequests(for driverId: String) async throws -> [RideRequest]
    func fetchMySentRequests(for passengerId: String) async throws -> [RideRequest]
    func updateRequestStatus(requestId: String, status: RideRequestStatus) async throws
    func observeRequests(onUpdate: @escaping ([RideRequest]) -> Void) -> (() -> Void)?

    // Carpool Group Chat
    func fetchMessages(for rideId: String) async throws -> [CarpoolChatMessage]
    func sendMessage(rideId: String, text: String, sender: User) async throws -> CarpoolChatMessage
    func observeMessages(for rideId: String, onUpdate: @escaping ([CarpoolChatMessage]) -> Void) -> (() -> Void)?
}
