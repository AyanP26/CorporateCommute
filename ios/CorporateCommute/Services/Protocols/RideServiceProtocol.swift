import Foundation
import Combine

protocol RideServiceProtocol: AnyObject {
    var availableRidesPublisher: AnyPublisher<[CommuteRide], Never> { get }

    func fetchRides() async throws -> [CommuteRide]
    func bookRide(rideId: String, userId: String) async throws
    func cancelBooking(rideId: String, userId: String) async throws
    func offerRide(_ ride: CommuteRide) async throws -> CommuteRide
}
