import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dashboardVM = CommuteDashboardViewModel()
    @State private var showingSettings = false
    @State private var showingLogoutConfirmation = false

    // Location Pickers for Offering Ride
    @State private var showingOriginPicker = false
    @State private var showingDestinationPicker = false
    @State private var selectedOriginLocation: CommuteLocation?
    @State private var selectedDestinationLocation: CommuteLocation?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 0) {
                    // Top App Header
                    headerView
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.top, 16)
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
                                ecoImpactTabContent
                            }
                        }
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.bottom, 40)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $dashboardVM.showingOfferRideSheet) {
                offerRideSheet
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
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0), AppTheme.bgBottomLeft],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(authViewModel.currentUser?.name.prefix(1) ?? "C").uppercased())
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hi, \(authViewModel.currentUser?.name ?? "Commuter")")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)

                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
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
                // Post Ride
                Button(action: {
                    // Prepopulate with user settings if available
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
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                }

                // Settings Gear
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textLight.opacity(0.85))
                        .padding(9)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
            }
        }
    }

    // MARK: - Segmented Tab Bar
    private var segmentedTabBar: some View {
        HStack(spacing: 8) {
            tabButton(title: "My Commute", index: 0)
            tabButton(title: "Find Carpool", index: 1)
            tabButton(title: "Eco Stats", index: 2)
        }
        .padding(4)
        .background(Color.black.opacity(0.35))
        .cornerRadius(AppTheme.pillCornerRadius)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                dashboardVM.selectedTab = index
            }
        }) {
            Text(title)
                .font(.system(size: 14, weight: dashboardVM.selectedTab == index ? .bold : .medium, design: .rounded))
                .foregroundColor(dashboardVM.selectedTab == index ? .white : AppTheme.placeholderText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                        .fill(dashboardVM.selectedTab == index ? Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0) : Color.clear)
                )
        }
    }

    // MARK: - Tab 0: My Commute
    private var myCommuteTabContent: some View {
        VStack(spacing: 16) {
            // Next Commute Card
            nextCommuteHeroCard

            // Job Location & Route Banner (Apple Maps Integrated)
            jobLocationSummaryCard

            // Quick Action Row
            HStack(spacing: 12) {
                quickActionCard(
                    title: "Offer Ride",
                    subtitle: "Share commute",
                    icon: "steeringwheel",
                    color: Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0)
                ) {
                    dashboardVM.showingOfferRideSheet = true
                }

                quickActionCard(
                    title: "User Settings",
                    subtitle: "Job & car details",
                    icon: "slider.horizontal.3",
                    color: Color(red: 0.4, green: 0.9, blue: 0.6)
                ) {
                    showingSettings = true
                }
            }

            // Booked Rides Header
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Your Scheduled Rides")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                    Spacer()
                    Text("\(dashboardVM.bookedRides.count) active")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                }

                if dashboardVM.bookedRides.isEmpty {
                    emptyBookingsCard
                } else {
                    ForEach(dashboardVM.bookedRides) { ride in
                        RideCardView(ride: ride) {
                            dashboardVM.cancelBooking(ride)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Next Commute Hero Card
    private var nextCommuteHeroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0.3, green: 0.85, blue: 0.5))
                        .frame(width: 8, height: 8)
                    Text("TODAY'S COMMUTE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.85, blue: 0.5))
                }
                Spacer()
                Text("Confirmed")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.6))
                    .cornerRadius(8)
            }

            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    Circle()
                        .fill(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                        .frame(width: 12, height: 12)
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 2, height: 26)
                    Circle()
                        .fill(Color(red: 0.4, green: 0.9, blue: 0.6))
                        .frame(width: 12, height: 12)
                }
                .padding(.top, 4)

                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(authViewModel.currentUser?.homeLocation?.name ?? "Home")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                        Text("Departure 8:15 AM")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.placeholderText)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(authViewModel.currentUser?.workLocation?.name ?? authViewModel.currentUser?.officeLocation ?? "Corporate HQ - Innovation Campus")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                            .lineLimit(1)
                        Text("Arrival ~ 8:45 AM")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.placeholderText)
                    }
                }
            }

            Divider()
                .background(Color.white.opacity(0.12))

            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "car.side.fill")
                        .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                    Text("Tesla Model 3 • Blue")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textLight)
                }
                Spacer()
                Text("2 colleagues joining")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.placeholderText)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.buttonPurple)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0).opacity(0.4), lineWidth: 1)
                )
        )
    }

    // MARK: - Job Location Card
    private var jobLocationSummaryCard: some View {
        let workLoc = authViewModel.currentUser?.workLocation ?? CommuteLocation.corporateHQ

        return HStack(spacing: 14) {
            Circle()
                .fill(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0).opacity(0.2))
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("JOB LOCATION (APPLE MAPS)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))

                Text(workLoc.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)
                    .lineLimit(1)

                Text(workLoc.address)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.placeholderText)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: {
                openAppleMapsDirections(to: workLoc)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 12))
                    Text("Navigate")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.buttonPurple.opacity(0.7))
        )
    }

    private var emptyBookingsCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.placeholderText)
            Text("No Upcoming Carpool Bookings")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)
            Text("Find open carpools from teammates or offer your own route to start earning eco credits.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.placeholderText)
                .multilineTextAlignment(.center)

            Button(action: { dashboardVM.selectedTab = 1 }) {
                Text("Browse Open Rides")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                    .cornerRadius(20)
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.buttonPurple.opacity(0.75))
        )
    }

    private func quickActionCard(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(color)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.placeholderText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.buttonPurple.opacity(0.85))
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
                    .fill(AppTheme.buttonPurple)
            )

            Text("Available Colleague Rides (\(dashboardVM.filteredRides.count))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)
                .padding(.top, 4)

            if dashboardVM.filteredRides.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "car.2.fill")
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.placeholderText)
                    Text("No rides match '\(dashboardVM.searchQuery)'")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.placeholderText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(dashboardVM.filteredRides) { ride in
                    RideCardView(ride: ride) {
                        if ride.isUserBooked {
                            dashboardVM.cancelBooking(ride)
                        } else {
                            dashboardVM.bookRide(ride)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tab 2: Eco Impact
    private var ecoImpactTabContent: some View {
        VStack(spacing: 18) {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Sustainability Impact")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.6))
                        Text("Green Commuter")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                    }
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.6))
                }

                Divider()
                    .background(Color.white.opacity(0.12))

                HStack(spacing: 12) {
                    ecoStatItem(
                        value: "\(Int(dashboardVM.totalCo2SavedKg)) kg",
                        title: "CO₂ Offset",
                        subtitle: "≈ 3.8 trees planted"
                    )

                    ecoStatItem(
                        value: "\(dashboardVM.totalRidesTaken)",
                        title: "Shared Trips",
                        subtitle: "Carpools taken"
                    )

                    ecoStatItem(
                        value: "\(dashboardVM.totalSeatsShared)",
                        title: "Seats Shared",
                        subtitle: "Traffic relieved"
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.buttonPurple)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(red: 0.4, green: 0.9, blue: 0.6).opacity(0.3), lineWidth: 1)
                    )
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                    Text("Company Commuter Rewards")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                }

                Text("You have accumulated 360 Corporate Commuter Credits! Redeemable for campus cafeteria passes and preferred EV parking spots.")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.placeholderText)
                    .lineSpacing(3)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(AppTheme.buttonPurple.opacity(0.7))
            )
        }
    }

    private func ecoStatItem(value: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textLight.opacity(0.9))

            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.placeholderText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.25))
        .cornerRadius(16)
    }

    // MARK: - Offer Ride Sheet (Apple Maps Integrated)
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
                        // Apple Maps Location Pickers
                        LocationRowView(
                            icon: "mappin.and.ellipse",
                            label: "Departure Location (Apple Maps)",
                            location: selectedOriginLocation,
                            placeholder: "Tap to select departure on Apple Maps"
                        ) {
                            showingOriginPicker = true
                        }

                        LocationRowView(
                            icon: "building.2.fill",
                            label: "Office Destination (Apple Maps)",
                            location: selectedDestinationLocation,
                            placeholder: "Tap to select office destination"
                        ) {
                            showingDestinationPicker = true
                        }

                        CustomTextField(placeholder: "Departure Time (e.g. 8:15 AM)", text: $dashboardVM.newRideTime)
                        CustomTextField(placeholder: "Vehicle (Model & Color)", text: $dashboardVM.newRideVehicle)

                        HStack {
                            Text("Available Seats:")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textLight)

                            Spacer()

                            Stepper("\(dashboardVM.newRideSeats) seats", value: $dashboardVM.newRideSeats, in: 1...6)
                                .foregroundColor(AppTheme.textLight)
                        }
                        .padding(.horizontal, 20)
                        .frame(height: AppTheme.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                                .fill(AppTheme.buttonPurple)
                        )
                    }
                    .padding(.top, 8)

                    PrimaryButton(title: "Publish Carpool Route") {
                        dashboardVM.newRideOrigin = selectedOriginLocation?.name ?? dashboardVM.newRideOrigin
                        dashboardVM.newRideDestination = selectedDestinationLocation?.name ?? dashboardVM.newRideDestination
                        dashboardVM.offerRide(
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
