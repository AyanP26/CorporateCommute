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
    @Published var nextRide: CommuteRide? = nil

    // Available carpools
    @Published var availableRides: [CommuteRide] = []

    private let rideService: RideServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(rideService: RideServiceProtocol = FirebaseManager.shared.rideService) {
        self.rideService = rideService

        // Subscribe to real-time rides stream (Firestore or Mock)
        rideService.availableRidesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rides in
                guard let self = self else { return }
                self.availableRides = rides
                // Update nextRide if user is booked
                if let booked = rides.first(where: { $0.isUserBooked }) {
                    self.nextRide = booked
                }
            }
            .store(in: &cancellables)

        loadInitialRides()
    }

    private func loadInitialRides() {
        Task { @MainActor in
            do {
                let rides = try await rideService.fetchRides()
                self.availableRides = rides
                if self.nextRide == nil {
                    self.nextRide = rides.first(where: { $0.isUserBooked }) ?? rides.first
                }
            } catch {
                print("[CommuteDashboardViewModel] Fetch error: \(error.localizedDescription)")
            }
        }
    }

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

    var bookedRides: [CommuteRide] {
        availableRides.filter { $0.isUserBooked }
    }

    var totalRidesTaken: Int {
        totalRidesCompleted
    }

    var totalSeatsShared: Int {
        totalRidesCompleted * 2
    }

    func bookRide(_ ride: CommuteRide, userId: String = "current_user") {
        Task { @MainActor in
            do {
                try await rideService.bookRide(rideId: ride.id, userId: userId)
                if let index = availableRides.firstIndex(where: { $0.id == ride.id }) {
                    availableRides[index].isUserBooked = true
                    if availableRides[index].availableSeats > 0 {
                        availableRides[index].availableSeats -= 1
                    }
                    self.nextRide = availableRides[index]
                }
            } catch {
                print("[CommuteDashboardViewModel] Book error: \(error.localizedDescription)")
            }
        }
    }

    func cancelBooking(_ ride: CommuteRide, userId: String = "current_user") {
        Task { @MainActor in
            do {
                try await rideService.cancelBooking(rideId: ride.id, userId: userId)
                if let index = availableRides.firstIndex(where: { $0.id == ride.id }) {
                    availableRides[index].isUserBooked = false
                    availableRides[index].availableSeats += 1
                }
                if self.nextRide?.id == ride.id {
                    self.nextRide = nil
                }
            } catch {
                print("[CommuteDashboardViewModel] Cancel error: \(error.localizedDescription)")
            }
        }
    }

    func offerRide(driverName: String, department: String, userId: String = "current_user") {
        let createdRide = CommuteRide(
            driverId: userId,
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

        Task { @MainActor in
            do {
                let saved = try await rideService.offerRide(createdRide)
                self.availableRides.insert(saved, at: 0)
                self.nextRide = saved
                self.showingOfferRideSheet = false
            } catch {
                print("[CommuteDashboardViewModel] Offer ride error: \(error.localizedDescription)")
            }
        }
    }
}
