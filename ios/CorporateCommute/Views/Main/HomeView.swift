import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dashboardVM = CommuteDashboardViewModel()
    @State private var showingSettings = false
    @State private var showingLogoutConfirmation = false

    // Carpool Deletion State
    @State private var rideToDelete: CommuteRide? = nil
    @State private var showingDeleteConfirmation = false

    // Quick Carpool Filters for Find Carpool tab
    @State private var carpoolTimeFilter: String = "All"
    private let carpoolFilters = ["All", "Morning (AM)", "Afternoon (PM)"]

    // Location Pickers for Offering Ride
    @State private var showingOriginPicker = false
    @State private var showingDestinationPicker = false
    @State private var selectedOriginLocation: CommuteLocation?
    @State private var selectedDestinationLocation: CommuteLocation?

    private var currentUserId: String {
        authViewModel.currentUser?.id ?? "current_user"
    }

    private var greetingFirstName: String {
        guard let name = authViewModel.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return "Commuter"
        }
        let parts = name.components(separatedBy: " ")
        return parts.first(where: { !$0.isEmpty }) ?? name
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 0) {
                    // Top App Header
                    headerView
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.top, 14)
                        .padding(.bottom, 12)

                    // Segmented Filter Tabs
                    segmentedTabBar
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.bottom, 16)

                    // Main Tab Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            switch dashboardVM.selectedTab {
                            case 0:
                                myCommuteTabContent
                            case 1:
                                findCarpoolTabContent
                            default:
                                myCarpoolsTabContent
                            }
                        }
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.bottom, 40)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $dashboardVM.showingOfferRideSheet) {
                offerRideSheet
            }
            .sheet(isPresented: $dashboardVM.showingIncomingRequestsSheet) {
                ManageRequestsView(dashboardVM: dashboardVM)
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $dashboardVM.showingMyRequestsSheet) {
                MyRequestsView(dashboardVM: dashboardVM)
                    .environmentObject(authViewModel)
            }
            .sheet(item: $dashboardVM.selectedChatRide) { ride in
                CarpoolChatView(
                    ride: ride,
                    currentUser: authViewModel.currentUser ?? User(name: "Commuter", email: "")
                )
            }
            .overlay(alignment: .top) {
                if dashboardVM.showRequestBanner, let msg = dashboardVM.requestAlertMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.ecoGreen)
                        Text(msg)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0))
                            .overlay(Capsule().stroke(AppTheme.ecoGreen.opacity(0.4), lineWidth: 1))
                    )
                    .padding(.top, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
                }
            }
            .onAppear {
                let uid = authViewModel.currentUser?.id ?? "current_user"
                dashboardVM.loadRequests(for: uid)
            }
            .onChange(of: authViewModel.currentUser?.id) { _, newId in
                let uid = newId ?? "current_user"
                dashboardVM.loadRequests(for: uid)
            }
            .confirmationDialog("Cancel Carpool?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                if let r = rideToDelete {
                    Button("Cancel Carpool", role: .destructive) {
                        dashboardVM.deleteRide(r)
                        rideToDelete = nil
                    }
                }
                Button("Keep Carpool", role: .cancel) {
                    rideToDelete = nil
                }
            } message: {
                Text("Are you sure you want to cancel this carpool? This will notify your colleagues and remove the listing from the schedule.")
            }
            .confirmationDialog("Log Out", isPresented: $showingLogoutConfirmation, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    authViewModel.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out of Corporate Commute?")
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(alignment: .center) {
            Button(action: { showingSettings = true }) {
                HStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [AppTheme.accentBlue, AppTheme.bgBottomLeft],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(String(greetingFirstName.prefix(1)).uppercased())
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: AppTheme.accentBlue.opacity(0.3), radius: 6)

                        Circle()
                            .fill(AppTheme.ecoGreen)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(AppTheme.bgTop, lineWidth: 2))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hi, \(greetingFirstName)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)

                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.accentBlue)
                            Text(authViewModel.currentUser?.workLocation?.name ?? authViewModel.currentUser?.officeLocation ?? "Corporate HQ")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.placeholderText)
                                .lineLimit(1)
                        }
                    }
                }
            }

            Spacer()

            HStack(spacing: 10) {
                // Post Ride Quick Button
                Button(action: {
                    if let home = authViewModel.currentUser?.homeLocation {
                        selectedOriginLocation = home
                        dashboardVM.newRideOrigin = home.name
                    }
                    if let work = authViewModel.currentUser?.workLocation {
                        selectedDestinationLocation = work
                        dashboardVM.newRideDestination = work.name
                    }
                    if let user = authViewModel.currentUser, !user.vehicleModel.isEmpty {
                        dashboardVM.newRideVehicle = "\(user.vehicleModel) (\(user.vehicleColor))"
                        dashboardVM.newRideSeats = user.vehicleSeats
                    }
                    dashboardVM.showingOfferRideSheet = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                        Text("Offer")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.accentBlue)
                    .clipShape(Capsule())
                    .shadow(color: AppTheme.accentBlue.opacity(0.35), radius: 6)
                }

                // Settings Gear
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textLight.opacity(0.9))
                        .padding(9)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }

    // MARK: - Segmented Tab Bar
    private var segmentedTabBar: some View {
        HStack(spacing: 6) {
            tabButton(title: "My Commute", index: 0)
            tabButton(title: "Find Carpool", index: 1)
            tabButton(title: "My Carpools", index: 2)
        }
        .padding(4)
        .background(Color.black.opacity(0.35))
        .cornerRadius(AppTheme.pillCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                dashboardVM.selectedTab = index
            }
        }) {
            Text(title)
                .font(.system(size: 14, weight: dashboardVM.selectedTab == index ? .bold : .medium, design: .rounded))
                .foregroundColor(dashboardVM.selectedTab == index ? .white : AppTheme.placeholderText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                        .fill(dashboardVM.selectedTab == index ? AppTheme.accentBlue : Color.clear)
                )
        }
    }

    // MARK: - Tab 0: My Commute (Dashboard)
    private var myCommuteTabContent: some View {
        VStack(spacing: 16) {
            // Next Commute Card (Real data or clean prompt)
            nextCommuteHeroCard

            // Job Location & Route Banner (Apple Maps Integrated)
            jobLocationSummaryCard

            // Quick Action Grid (Android parity + Cross-platform General Chat)
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    quickActionCard(
                        title: "Offer Ride",
                        subtitle: "Share route",
                        icon: "steeringwheel",
                        color: AppTheme.accentBlue
                    ) {
                        dashboardVM.showingOfferRideSheet = true
                    }

                    quickActionCard(
                        title: "General Chat",
                        subtitle: "All commuters",
                        icon: "bubble.left.and.bubble.right.fill",
                        color: AppTheme.accentPurple
                    ) {
                        dashboardVM.selectedChatRide = dashboardVM.generalChatRide
                    }
                }

                HStack(spacing: 12) {
                    quickActionCard(
                        title: "Requests",
                        subtitle: "\(dashboardVM.incomingRequests.filter { $0.status == .pending }.count) pending",
                        icon: "tray.and.arrow.down.fill",
                        color: Color.orange,
                        badgeCount: dashboardVM.incomingRequests.filter { $0.status == .pending }.count
                    ) {
                        dashboardVM.showingIncomingRequestsSheet = true
                    }

                    quickActionCard(
                        title: "My Sent",
                        subtitle: "\(dashboardVM.mySentRequests.count) requested",
                        icon: "paperplane.fill",
                        color: AppTheme.ecoGreen
                    ) {
                        dashboardVM.showingMyRequestsSheet = true
                    }
                }
            }

            // Booked Rides Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Your Scheduled Rides")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                    Spacer()
                    Text("\(dashboardVM.bookedRides.count) active")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.accentBlueSoft)
                        .clipShape(Capsule())
                }

                if dashboardVM.bookedRides.isEmpty {
                    emptyBookingsCard
                } else {
                    ForEach(dashboardVM.bookedRides) { ride in
                        let isHost = ride.driverId == currentUserId || ride.driverId == "current_user"
                        let pendingForRide = isHost ? dashboardVM.pendingRequests(for: ride.id) : []
                        RideCardView(
                            ride: ride,
                            isHost: isHost,
                            pendingRequests: pendingForRide,
                            onChat: {
                                dashboardVM.selectedChatRide = ride
                            },
                            onDelete: isHost ? {
                                rideToDelete = ride
                                showingDeleteConfirmation = true
                            } : nil,
                            onAcceptRequest: isHost ? { req in
                                dashboardVM.acceptRequest(req)
                            } : nil,
                            onDeclineRequest: isHost ? { req in
                                dashboardVM.declineRequest(req)
                            } : nil
                        ) {
                            dashboardVM.cancelBooking(ride, userId: currentUserId)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Next Commute Hero Card
    private var nextCommuteHeroCard: some View {
        Group {
            if let next = dashboardVM.nextRide {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppTheme.ecoGreen)
                                .frame(width: 8, height: 8)
                            Text("SCHEDULED COMMUTE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.ecoGreen)
                        }
                        Spacer()

                        Button(action: {
                            dashboardVM.selectedChatRide = next
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 11))
                                Text("Ride Chat")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(AppTheme.accentBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppTheme.accentBlueSoft)
                            .clipShape(Capsule())
                        }
                    }

                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(AppTheme.accentBlue)
                                .frame(width: 10, height: 10)
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.accentBlue, AppTheme.ecoGreen],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 2, height: 32)
                            Circle()
                                .fill(AppTheme.ecoGreen)
                                .frame(width: 10, height: 10)
                        }
                        .padding(.top, 4)

                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(next.origin)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppTheme.textLight)
                                Text("Departure \(next.departureTime)")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.placeholderText)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(next.destination)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppTheme.textLight)
                                    .lineLimit(1)
                                if !next.departureDate.isEmpty {
                                    Text("Date: \(next.departureDate)")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.placeholderText)
                                }
                            }
                        }
                    }

                    Divider()
                        .background(Color.white.opacity(0.12))

                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "car.side.fill")
                                .foregroundColor(AppTheme.accentBlue)
                            Text(next.vehicleDescription)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textLight)
                        }
                        Spacer()
                        Text("Driver: \(next.driverName)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.placeholderText)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppTheme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(AppTheme.accentBlue.opacity(0.4), lineWidth: 1)
                        )
                )
            } else {
                HStack(spacing: 14) {
                    Circle()
                        .fill(AppTheme.accentBlueSoft)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "car.2.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.accentBlue)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text("No Commute Scheduled Today")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)

                        Text("Find colleague rides or offer your own route.")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.placeholderText)
                    }

                    Spacer()

                    Button(action: {
                        withAnimation {
                            dashboardVM.selectedTab = 1
                        }
                    }) {
                        Text("Browse")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(AppTheme.accentBlue))
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(AppTheme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(AppTheme.cardBorder, lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - Job Location Card
    private var jobLocationSummaryCard: some View {
        let workLoc = authViewModel.currentUser?.workLocation ?? CommuteLocation.corporateHQ

        return HStack(spacing: 14) {
            Circle()
                .fill(AppTheme.accentBlueSoft)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.accentBlue)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("WORK LOCATION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.accentBlue)
                    .lineLimit(1)

                Text(workLoc.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Text(workLoc.address)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.placeholderText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }

            Spacer()

            Button(action: {
                openAppleMapsDirections(to: workLoc)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 12))
                    Text("Maps")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(AppTheme.accentBlue)
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private var emptyBookingsCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 38))
                .foregroundColor(AppTheme.placeholderText.opacity(0.8))
            Text("No Upcoming Carpool Bookings")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)
            Text("Find open carpools from teammates or offer your own route to start sharing your daily commute.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.placeholderText)
                .multilineTextAlignment(.center)

            Button(action: {
                withAnimation {
                    dashboardVM.selectedTab = 1
                }
            }) {
                Text("Browse Open Rides")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppTheme.accentBlue)
                    .cornerRadius(20)
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private func quickActionCard(title: String, subtitle: String, icon: String, color: Color, badgeCount: Int = 0, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 18))
                                .foregroundColor(color)
                        )

                    Spacer()

                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.placeholderText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.cardBorder, lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Tab 1: Find Carpool
    private var findCarpoolTabContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.placeholderText)

                TextField("", text: $dashboardVM.searchQuery, prompt: Text("Search routes, coworkers, job locations...").foregroundColor(AppTheme.placeholderText))
                    .tint(.white)
                    .foregroundColor(AppTheme.textLight)
                    .font(.system(size: 14))

                if !dashboardVM.searchQuery.isEmpty {
                    Button(action: { dashboardVM.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.placeholderText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                            .stroke(AppTheme.cardBorder, lineWidth: 1)
                    )
            )

            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(carpoolFilters, id: \.self) { filter in
                        let isSelected = carpoolTimeFilter == filter
                        Button(action: {
                            withAnimation(.spring(response: 0.25)) {
                                carpoolTimeFilter = filter
                            }
                        }) {
                            Text(filter)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : AppTheme.placeholderText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? AppTheme.accentBlue : AppTheme.cardBackground)
                                        .overlay(
                                            Capsule().stroke(isSelected ? AppTheme.accentBlue : AppTheme.cardBorder, lineWidth: 1)
                                        )
                                    )
                        }
                    }
                }
            }

            let displayedRides = filteredRidesWithTime

            Text("Available Colleague Rides (\(displayedRides.count))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)
                .padding(.top, 4)

            if displayedRides.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "car.2.fill")
                        .font(.system(size: 38))
                        .foregroundColor(AppTheme.placeholderText)
                    Text("No rides match your filter")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textLight)
                    Text("Try adjusting your search query or time filter.")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.placeholderText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(displayedRides) { ride in
                    let isHost = ride.driverId == currentUserId
                    RideCardView(
                        ride: ride,
                        isHost: isHost,
                        onChat: {
                            dashboardVM.selectedChatRide = ride
                        },
                        onDelete: isHost ? {
                            rideToDelete = ride
                            showingDeleteConfirmation = true
                        } : nil
                    ) {
                        if ride.isUserBooked {
                            dashboardVM.cancelBooking(ride, userId: currentUserId)
                        } else if ride.hasPendingRequest {
                            dashboardVM.requestAlertMessage = "Your request is already pending driver approval."
                            withAnimation { dashboardVM.showRequestBanner = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation { dashboardVM.showRequestBanner = false }
                            }
                        } else if let user = authViewModel.currentUser {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            dashboardVM.sendRideRequest(ride: ride, user: user)
                        } else {
                            dashboardVM.bookRide(ride, userId: currentUserId)
                        }
                    }
                }
            }
        }
    }

    private var filteredRidesWithTime: [CommuteRide] {
        let base = dashboardVM.filteredRides
        if carpoolTimeFilter == "Morning (AM)" {
            return base.filter { $0.departureTime.uppercased().contains("AM") }
        } else if carpoolTimeFilter == "Afternoon (PM)" {
            return base.filter { $0.departureTime.uppercased().contains("PM") }
        }
        return base
    }

    // MARK: - Tab 2: My Carpools (Organized Hub)
    private var myCarpoolsTabContent: some View {
        let hostedRides = dashboardVM.ridesHostedBy(userId: currentUserId)
        let joinedRides = dashboardVM.ridesJoinedBy(userId: currentUserId)

        return VStack(alignment: .leading, spacing: 18) {
            // Sub-category Filter Selector
            HStack(spacing: 8) {
                myCarpoolsFilterButton(title: "All (\(hostedRides.count + joinedRides.count))", index: 0)
                myCarpoolsFilterButton(title: "Hosted (\(hostedRides.count))", index: 1)
                myCarpoolsFilterButton(title: "Joined (\(joinedRides.count))", index: 2)
            }
            .padding(4)
            .background(Color.black.opacity(0.35))
            .cornerRadius(AppTheme.pillCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )

            // Section 1: Rides You Are Hosting
            if dashboardVM.myCarpoolsFilter == 0 || dashboardVM.myCarpoolsFilter == 1 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "steeringwheel")
                                .foregroundColor(AppTheme.accentBlue)
                            Text("Rides You're Driving")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textLight)
                        }

                        Spacer()

                        Text("\(hostedRides.count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.accentBlue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.accentBlueSoft)
                            .clipShape(Capsule())
                    }

                    if hostedRides.isEmpty {
                        emptyCarpoolsCard(
                            title: "You haven't posted any carpools",
                            subtitle: "Share your commute route with colleagues heading to the same campus.",
                            buttonTitle: "Offer a Carpool"
                        ) {
                            dashboardVM.showingOfferRideSheet = true
                        }
                    } else {
                        ForEach(hostedRides) { ride in
                            let pendingForRide = dashboardVM.pendingRequests(for: ride.id)
                            RideCardView(
                                ride: ride,
                                isHost: true,
                                pendingRequests: pendingForRide,
                                onChat: {
                                    dashboardVM.selectedChatRide = ride
                                },
                                onDelete: {
                                    rideToDelete = ride
                                    showingDeleteConfirmation = true
                                },
                                onAcceptRequest: { req in
                                    dashboardVM.acceptRequest(req)
                                },
                                onDeclineRequest: { req in
                                    dashboardVM.declineRequest(req)
                                }
                            ) {}
                        }
                    }
                }
            }

            // Section 2: Carpools You've Joined or Requested
            if dashboardVM.myCarpoolsFilter == 0 || dashboardVM.myCarpoolsFilter == 2 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .foregroundColor(AppTheme.ecoGreen)
                            Text("Rides You've Joined")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textLight)
                        }

                        Spacer()

                        Text("\(joinedRides.count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.ecoGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.ecoGreenSoft)
                            .clipShape(Capsule())
                    }

                    if joinedRides.isEmpty {
                        emptyCarpoolsCard(
                            title: "No joined carpools yet",
                            subtitle: "Search available colleague rides and request to reserve a seat.",
                            buttonTitle: "Find a Carpool"
                        ) {
                            withAnimation {
                                dashboardVM.selectedTab = 1
                            }
                        }
                    } else {
                        ForEach(joinedRides) { ride in
                            RideCardView(
                                ride: ride,
                                isHost: false,
                                onChat: {
                                    dashboardVM.selectedChatRide = ride
                                }
                            ) {
                                dashboardVM.cancelBooking(ride, userId: currentUserId)
                            }
                        }
                    }
                }
            }
        }
    }

    private func myCarpoolsFilterButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                dashboardVM.myCarpoolsFilter = index
            }
        }) {
            Text(title)
                .font(.system(size: 12, weight: dashboardVM.myCarpoolsFilter == index ? .bold : .medium))
                .foregroundColor(dashboardVM.myCarpoolsFilter == index ? .white : AppTheme.placeholderText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                        .fill(dashboardVM.myCarpoolsFilter == index ? AppTheme.accentBlue : Color.clear)
                )
        }
    }

    private func emptyCarpoolsCard(title: String, subtitle: String, buttonTitle: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.textLight)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.placeholderText)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Text(buttonTitle)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.accentBlue)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    // MARK: - Offer Ride Sheet (Apple Maps & Native Date/Time Pickers)
    private var offerRideSheet: some View {
        ZStack {
            BackgroundGradient()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Offer a Commute Ride")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                        .padding(.top, 28)

                    Text("Share your route with colleagues heading to the same campus.")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.placeholderText)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 16) {
                        // Departure Location (Apple Maps)
                        LocationRowView(
                            icon: "mappin.and.ellipse",
                            label: "DEPARTURE LOCATION",
                            location: selectedOriginLocation,
                            placeholder: "Select departure point"
                        ) {
                            showingOriginPicker = true
                        }

                        // Destination (Apple Maps)
                        LocationRowView(
                            icon: "building.2.fill",
                            label: "OFFICE DESTINATION",
                            location: selectedDestinationLocation,
                            placeholder: "Select destination office"
                        ) {
                            showingDestinationPicker = true
                        }

                        // Schedule Departure (Date & Time Card)
                        scheduleDepartureCard

                        // Vehicle Info
                        CustomTextField(
                            placeholder: "Vehicle (Model & Color)",
                            text: $dashboardVM.newRideVehicle,
                            icon: "car.side.fill",
                            autocapitalization: .words
                        )

                        // Seats Stepper
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(AppTheme.accentBlue)
                                Text("Available Seats:")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AppTheme.textLight)
                            }

                            Spacer()

                            Stepper("\(dashboardVM.newRideSeats) seats", value: $dashboardVM.newRideSeats, in: 1...6)
                                .foregroundColor(AppTheme.textLight)
                        }
                        .padding(.horizontal, 20)
                        .frame(height: AppTheme.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                                .fill(AppTheme.inputBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )

                        // Optional Trip Notes
                        CustomTextField(
                            placeholder: "Trip notes (e.g. coffee stop, music playlist)",
                            text: $dashboardVM.newRideNotes,
                            icon: "note.text"
                        )
                    }
                    .padding(.top, 8)

                    PrimaryButton(title: "Publish Carpool Route", style: .accent) {
                        dashboardVM.newRideOrigin = selectedOriginLocation?.name ?? dashboardVM.newRideOrigin
                        dashboardVM.newRideDestination = selectedDestinationLocation?.name ?? dashboardVM.newRideDestination
                        dashboardVM.offerRide(
                            driverId: currentUserId,
                            driverName: authViewModel.currentUser?.name ?? "You",
                            department: authViewModel.currentUser?.company ?? "Corporate"
                        )
                    }
                    .padding(.top, 16)

                    Button("Cancel") {
                        dashboardVM.showingOfferRideSheet = false
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.placeholderText)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .presentationDetents([.medium, .large])
        .sheet(isPresented: $showingOriginPicker) {
            LocationPickerView(
                title: "Select Departure Location",
                initialLocation: selectedOriginLocation
            ) { newOrigin in
                self.selectedOriginLocation = newOrigin
                self.dashboardVM.newRideOrigin = newOrigin.name
            }
        }
        .sheet(isPresented: $showingDestinationPicker) {
            LocationPickerView(
                title: "Select Office / Destination",
                initialLocation: selectedDestinationLocation ?? CommuteLocation.corporateHQ
            ) { newDest in
                self.selectedDestinationLocation = newDest
                self.dashboardVM.newRideDestination = newDest.name
            }
        }
    }

    // MARK: - Schedule Departure Card
    private var scheduleDepartureCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppTheme.accentBlue)
                    .font(.system(size: 16))

                Text("Departure Schedule")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)

                Spacer()

                Text(CommuteDashboardViewModel.shortDateFormatter.string(from: dashboardVM.newRideDepartureDate))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.accentBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.accentBlueSoft)
                    .clipShape(Capsule())
            }

            // Quick Preset Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    quickSchedulePreset(title: "Today", isSelected: Calendar.current.isDateInToday(dashboardVM.newRideDepartureDate)) {
                        let cal = Calendar.current
                        let hour = cal.component(.hour, from: dashboardVM.newRideDepartureDate)
                        let minute = cal.component(.minute, from: dashboardVM.newRideDepartureDate)
                        if let todayDate = cal.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) {
                            dashboardVM.newRideDepartureDate = todayDate
                        }
                    }

                    quickSchedulePreset(title: "Tomorrow", isSelected: Calendar.current.isDateInTomorrow(dashboardVM.newRideDepartureDate)) {
                        let cal = Calendar.current
                        if let tomorrow = cal.date(byAdding: .day, value: 1, to: Date()) {
                            let hour = cal.component(.hour, from: dashboardVM.newRideDepartureDate)
                            let minute = cal.component(.minute, from: dashboardVM.newRideDepartureDate)
                            if let tomorrowDate = cal.date(bySettingHour: hour, minute: minute, second: 0, of: tomorrow) {
                                dashboardVM.newRideDepartureDate = tomorrowDate
                            }
                        }
                    }

                    quickSchedulePreset(title: "8:00 AM", isSelected: false) {
                        setTimePreset(hour: 8, minute: 0)
                    }

                    quickSchedulePreset(title: "8:30 AM", isSelected: false) {
                        setTimePreset(hour: 8, minute: 30)
                    }

                    quickSchedulePreset(title: "5:00 PM", isSelected: false) {
                        setTimePreset(hour: 17, minute: 0)
                    }

                    quickSchedulePreset(title: "5:30 PM", isSelected: false) {
                        setTimePreset(hour: 17, minute: 30)
                    }
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Native Date & Time Pickers
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(AppTheme.placeholderText)
                        .font(.system(size: 13))

                    DatePicker(
                        "Date",
                        selection: $dashboardVM.newRideDepartureDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundColor(AppTheme.placeholderText)
                        .font(.system(size: 13))

                    DatePicker(
                        "Time",
                        selection: $dashboardVM.newRideDepartureDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private func quickSchedulePreset(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : AppTheme.placeholderText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.accentBlue : Color.white.opacity(0.06))
                        .overlay(
                            Capsule().stroke(isSelected ? AppTheme.accentBlue : Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
    }

    private func setTimePreset(hour: Int, minute: Int) {
        let cal = Calendar.current
        if let updated = cal.date(bySettingHour: hour, minute: minute, second: 0, of: dashboardVM.newRideDepartureDate) {
            dashboardVM.newRideDepartureDate = updated
        }
    }

    private func openAppleMapsDirections(to location: CommuteLocation) {
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
