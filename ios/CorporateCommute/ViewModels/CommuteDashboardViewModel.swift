import Foundation
import Combine

final class CommuteDashboardViewModel: ObservableObject {
    @Published var selectedTab: Int = 0 // 0: Overview/My Rides, 1: Find Carpool, 2: Eco Impact
    @Published var searchQuery: String = ""
    @Published var showingOfferRideSheet: Bool = false
    @Published var selectedRideForDetails: CommuteRide? = nil

    // Offer ride form fields
    @Published var newRideOrigin: String = "West Suburbs Hub"
    @Published var newRideDestination: String = "Corporate HQ - Bldg 4"
    @Published var newRideTime: String = "8:15 AM"
    @Published var newRideVehicle: String = "Honda Civic (Silver)"
    @Published var newRideSeats: Int = 3

    // Eco stats
    @Published var totalRidesCompleted: Int = 18
    @Published var totalCo2SavedKg: Double = 76.4
    @Published var estimatedCostSavedDollars: Double = 142.50

    // Next scheduled ride for the user
    @Published var nextRide: CommuteRide? = CommuteRide(
        driverName: "Alex Rivera",
        driverDepartment: "Engineering",
        vehicleDescription: "Blue Electric SUV",
        origin: "North Metro Station",
        destination: "Corporate HQ - Main Entrance",
        departureTime: "8:30 AM",
        returnTime: "5:30 PM",
        availableSeats: 2,
        totalSeats: 4,
        co2SavedKg: 5.6,
        status: .scheduled,
        isUserBooked: true
    )

    // Available carpools from coworkers
    @Published var availableRides: [CommuteRide] = [
        CommuteRide(
            driverName: "Sarah Chen",
            driverDepartment: "Product & Design",
            vehicleDescription: "Tesla Model Y - White",
            origin: "Downtown Park & Ride",
            destination: "Corporate HQ - Innovation Lab",
            departureTime: "8:00 AM",
            returnTime: "5:00 PM",
            availableSeats: 3,
            totalSeats: 4,
            co2SavedKg: 6.2,
            isUserBooked: false
        ),
        CommuteRide(
            driverName: "Marcus Johnson",
            driverDepartment: "Data Science",
            vehicleDescription: "Toyota RAV4 Hybrid",
            origin: "Westside Transit Hub",
            destination: "Corporate HQ - Building B",
            departureTime: "8:45 AM",
            returnTime: "5:45 PM",
            availableSeats: 1,
            totalSeats: 4,
            co2SavedKg: 4.8,
            isUserBooked: false
        ),
        CommuteRide(
            driverName: "Emily Zhao",
            driverDepartment: "Marketing",
            vehicleDescription: "Hyundai Ioniq 5",
            origin: "East Ridge Plaza",
            destination: "Corporate HQ - Building A",
            departureTime: "9:00 AM",
            returnTime: "6:00 PM",
            availableSeats: 2,
            totalSeats: 3,
            co2SavedKg: 5.1,
            isUserBooked: false
        )
    ]

    var filteredRides: [CommuteRide] {
        if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            return availableRides
        }
        return availableRides.filter { ride in
            ride.origin.localizedCaseInsensitiveContains(searchQuery) ||
            ride.destination.localizedCaseInsensitiveContains(searchQuery) ||
            ride.driverName.localizedCaseInsensitiveContains(searchQuery) ||
            ride.driverDepartment.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    func bookRide(_ ride: CommuteRide) {
        if let index = availableRides.firstIndex(where: { $0.id == ride.id }) {
            guard availableRides[index].availableSeats > 0 else { return }
            availableRides[index].availableSeats -= 1
            availableRides[index].isUserBooked = true

            // Set as current next ride if none
            if nextRide == nil {
                nextRide = availableRides[index]
            }
        }
    }

    func cancelBooking(_ ride: CommuteRide) {
        if let index = availableRides.firstIndex(where: { $0.id == ride.id }) {
            availableRides[index].availableSeats += 1
            availableRides[index].isUserBooked = false
        }
        if nextRide?.id == ride.id {
            nextRide = nil
        }
    }

    func offerRide(driverName: String, department: String) {
        let createdRide = CommuteRide(
            driverName: driverName.isEmpty ? "You (Driver)" : driverName,
            driverDepartment: department.isEmpty ? "Corporate Team" : department,
            vehicleDescription: newRideVehicle,
            origin: newRideOrigin,
            destination: newRideDestination,
            departureTime: newRideTime,
            availableSeats: newRideSeats,
            totalSeats: newRideSeats + 1,
            co2SavedKg: 5.0,
            status: .scheduled,
            isUserBooked: true
        )
        availableRides.insert(createdRide, at: 0)
        if nextRide == nil {
            nextRide = createdRide
        }
        showingOfferRideSheet = false
    }
}
