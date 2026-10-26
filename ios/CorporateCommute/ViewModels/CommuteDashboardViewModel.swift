import Foundation
import Combine

final class CommuteDashboardViewModel: ObservableObject {
    // Tabs: 0: Dashboard/Overview, 1: Find Carpool, 2: My Carpools
    @Published var selectedTab: Int = 0
    @Published var searchQuery: String = ""

    // Sheet Presentations
    @Published var showingOfferRideSheet: Bool = false
    @Published var showingIncomingRequestsSheet: Bool = false
    @Published var showingMyRequestsSheet: Bool = false
    @Published var selectedRideForDetails: CommuteRide? = nil
    @Published var selectedChatRide: CommuteRide? = nil

    // "My Carpools" Sub-Filter: 0: All, 1: Hosted by You, 2: Joined & Requested
    @Published var myCarpoolsFilter: Int = 0

    // "Find Carpool" Filters: 0: All, 1: Morning (AM), 2: Afternoon (PM)
    @Published var selectedTimeFilter: Int = 0
    // Date filter: 0: All Dates, 1: Today, 2: Tomorrow
    @Published var selectedDateFilter: Int = 0

    // Requests Management (Parity with Android)
    @Published var incomingRequests: [RideRequest] = []
    @Published var mySentRequests: [RideRequest] = []
    @Published var requestedRideIds: Set<String> = []
    @Published var requestAlertMessage: String? = nil
    @Published var showRequestBanner: Bool = false

    // Offer Ride Form Fields
    @Published var newRideOrigin: String = "West Suburbs Hub"
    @Published var newRideDestination: String = "Corporate HQ - Bldg 4"
    @Published var newRideDepartureDate: Date = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
    @Published var newRideVehicle: String = "Honda Civic (Silver)"
    @Published var newRideSeats: Int = 3
    @Published var newRideNotes: String = ""

    // Next scheduled ride for the user
    @Published var nextRide: CommuteRide? = nil

    // Available carpools
    @Published var availableRides: [CommuteRide] = []

    private let rideService: RideServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Formatters
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()

    init(rideService: RideServiceProtocol = FirebaseManager.shared.rideService) {
        self.rideService = rideService

        // Subscribe to real-time rides stream (Firestore or Mock)
        rideService.availableRidesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rides in
                guard let self = self else { return }
                self.availableRides = rides
                if let booked = rides.first(where: { $0.isUserBooked }) {
                    self.nextRide = booked
                }
            }
            .store(in: &cancellables)

        loadInitialRides()
    }

    func loadRequests(for userId: String) {
        Task { @MainActor in
            do {
                async let incoming = rideService.fetchIncomingRequests(for: userId)
                async let mySent = rideService.fetchMySentRequests(for: userId)
                let (inc, sent) = try await (incoming, mySent)
                self.incomingRequests = inc
                self.mySentRequests = sent
                self.requestedRideIds = Set(sent.map { $0.rideId })

                // Update hasPendingRequest on availableRides
                for index in 0..<self.availableRides.count {
                    let rId = self.availableRides[index].id
                    self.availableRides[index].hasPendingRequest = self.requestedRideIds.contains(rId)
                }
            } catch {
                print("[CommuteDashboardViewModel] Load requests error: \(error.localizedDescription)")
            }
        }
    }

    func sendRideRequest(ride: CommuteRide, user: User) {
        Task { @MainActor in
            do {
                let newReq = try await rideService.sendRideRequest(ride: ride, passenger: user)
                self.mySentRequests.insert(newReq, at: 0)
                self.requestedRideIds.insert(ride.id)

                if let idx = self.availableRides.firstIndex(where: { $0.id == ride.id }) {
                    self.availableRides[idx].hasPendingRequest = true
                }

                self.requestAlertMessage = "Ride request sent to \(ride.driverName)! 🚗"
                self.showRequestBanner = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.showRequestBanner = false
                }
            } catch {
                self.requestAlertMessage = "Failed to send request: \(error.localizedDescription)"
                self.showRequestBanner = true
            }
        }
    }

    func acceptRequest(_ request: RideRequest) {
        Task { @MainActor in
            do {
                try await rideService.updateRequestStatus(requestId: request.requestId, status: .accepted)
                if let idx = self.incomingRequests.firstIndex(where: { $0.requestId == request.requestId }) {
                    self.incomingRequests[idx].status = .accepted
                }
                if let rideIdx = self.availableRides.firstIndex(where: { $0.id == request.rideId }), self.availableRides[rideIdx].availableSeats > 0 {
                    self.availableRides[rideIdx].availableSeats -= 1
                }
            } catch {
                print("[CommuteDashboardViewModel] Accept error: \(error.localizedDescription)")
            }
        }
    }

    func declineRequest(_ request: RideRequest) {
        Task { @MainActor in
            do {
                try await rideService.updateRequestStatus(requestId: request.requestId, status: .declined)
                if let idx = self.incomingRequests.firstIndex(where: { $0.requestId == request.requestId }) {
                    self.incomingRequests[idx].status = .declined
                }
            } catch {
                print("[CommuteDashboardViewModel] Decline error: \(error.localizedDescription)")
            }
        }
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

    // MARK: - Find Carpool Filtering
    var filteredRides: [CommuteRide] {
        var result = availableRides

        // Text search
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { ride in
                ride.origin.localizedCaseInsensitiveContains(query) ||
                ride.destination.localizedCaseInsensitiveContains(query) ||
                ride.driverName.localizedCaseInsensitiveContains(query) ||
                ride.driverDepartment.localizedCaseInsensitiveContains(query)
            }
        }

        // Time of day filter
        if selectedTimeFilter == 1 {
            result = result.filter { $0.departureTime.uppercased().contains("AM") }
        } else if selectedTimeFilter == 2 {
            result = result.filter { $0.departureTime.uppercased().contains("PM") }
        }

        return result
    }

    // MARK: - "My Carpools" Organization
    func ridesHostedBy(userId: String) -> [CommuteRide] {
        let uid = userId.trimmingCharacters(in: .whitespacesAndNewlines)
        return availableRides.filter { ride in
            if !uid.isEmpty && (ride.driverId == uid || ride.driverId == "current_user") {
                return true
            }
            return false
        }
    }

    func ridesJoinedBy(userId: String) -> [CommuteRide] {
        let uid = userId.trimmingCharacters(in: .whitespacesAndNewlines)
        return availableRides.filter { ride in
            let isDriver = !uid.isEmpty && (ride.driverId == uid || ride.driverId == "current_user")
            guard !isDriver else { return false }
            return ride.isUserBooked || requestedRideIds.contains(ride.id)
        }
    }

    var bookedRides: [CommuteRide] {
        availableRides.filter { $0.isUserBooked }
    }

    func bookRide(_ ride: CommuteRide, userId: String) {
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

    func deleteRide(_ ride: CommuteRide, completion: ((Bool, String) -> Void)? = nil) {
        guard ride.canBeDeleted else {
            let msg = "Cannot cancel carpool: pickup is scheduled in less than 24 hours."
            self.requestAlertMessage = msg
            self.showRequestBanner = true
            completion?(false, msg)
            return
        }

        Task { @MainActor in
            do {
                try await rideService.deleteRide(rideId: ride.id)
                self.availableRides.removeAll { $0.id == ride.id }
                if self.nextRide?.id == ride.id {
                    self.nextRide = self.availableRides.first(where: { $0.isUserBooked })
                }
                let msg = "Carpool successfully cancelled."
                self.requestAlertMessage = msg
                self.showRequestBanner = true
                completion?(true, msg)

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.showRequestBanner = false
                }
            } catch {
                let err = "Failed to cancel carpool: \(error.localizedDescription)"
                self.requestAlertMessage = err
                self.showRequestBanner = true
                completion?(false, err)
            }
        }
    }

    // General Commuter Chat ride model representation for cross-platform chat with Android
    var generalChatRide: CommuteRide {
        CommuteRide(
            id: "general_commuter_chat",
            driverId: "general_channel",
            driverName: "Company Network",
            origin: "General Commuter Chat",
            destination: "All Campuses",
            departureDate: "Today",
            departureTime: "Live",
            availableSeats: 0
        )
    }

    func cancelBooking(_ ride: CommuteRide, userId: String) {
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

    func offerRide(driverId: String, driverName: String, department: String) {
        let formattedTime = Self.timeFormatter.string(from: newRideDepartureDate)
        let formattedDate = Self.shortDateFormatter.string(from: newRideDepartureDate)

        let createdRide = CommuteRide(
            driverId: driverId.isEmpty ? "current_user" : driverId,
            driverName: driverName.isEmpty ? "You (Driver)" : driverName,
            driverDepartment: department.isEmpty ? "Corporate Team" : department,
            vehicleDescription: newRideVehicle.isEmpty ? "Vehicle" : newRideVehicle,
            origin: newRideOrigin,
            destination: newRideDestination,
            departureDate: formattedDate,
            departureTime: formattedTime,
            availableSeats: newRideSeats,
            totalSeats: newRideSeats + 1,
            notes: newRideNotes,
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
