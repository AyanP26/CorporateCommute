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
}
