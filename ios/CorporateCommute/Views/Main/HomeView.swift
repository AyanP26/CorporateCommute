import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dashboardVM = CommuteDashboardViewModel()
    @State private var showingLogoutConfirmation = false

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
            HStack(spacing: 12) {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0), AppTheme.bgBottomLeft],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(authViewModel.currentUser?.name.prefix(1) ?? "C"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Hi, \(authViewModel.currentUser?.name ?? "Commuter")")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)

                    HStack(spacing: 4) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 11))
                        Text("HQ - Innovation Campus")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.placeholderText)
                }
            }

            Spacer()

            HStack(spacing: 10) {
                Button(action: { dashboardVM.showingOfferRideSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                }

                Button(action: { showingLogoutConfirmation = true }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textLight.opacity(0.8))
                        .padding(8)
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
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { dashboardVM.selectedTab = index } }) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(dashboardVM.selectedTab == index ? .white : AppTheme.placeholderText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    dashboardVM.selectedTab == index ?
                        AppTheme.buttonPurple :
                        Color.clear
                )
                .cornerRadius(22)
        }
    }

    // MARK: - Tab 0: My Commute
    private var myCommuteTabContent: some View {
        VStack(spacing: 20) {
            // Hero Card: Next Scheduled Commute
            if let ride = dashboardVM.nextRide {
                nextRideHeroCard(ride: ride)
            } else {
                noRideScheduledCard
            }

            // Quick Actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Actions")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)

                HStack(spacing: 12) {
                    quickActionCard(
                        title: "Offer Ride",
                        subtitle: "Share your car",
                        icon: "car.side.fill",
                        color: Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0)
                    ) {
                        dashboardVM.showingOfferRideSheet = true
                    }

                    quickActionCard(
                        title: "Find Carpool",
                        subtitle: "Join coworkers",
                        icon: "magnifyingglass",
                        color: Color(red: 0x54 / 255.0, green: 0x00 / 255.0, blue: 0x58 / 255.0)
                    ) {
                        withAnimation { dashboardVM.selectedTab = 1 }
                    }
                }
            }

            // Popular routes today
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's Carpools")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                    Spacer()
                    Button("See All") {
                        withAnimation { dashboardVM.selectedTab = 1 }
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                }

                ForEach(dashboardVM.availableRides.prefix(2)) { ride in
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

    private func nextRideHeroCard(ride: CommuteRide) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image("CarIllustration")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 30)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next Scheduled Commute")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                        Text("Today • Departure \(ride.departureTime)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                    }
                }

                Spacer()

                Text("Confirmed")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.9, blue: 0.5))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.3, green: 0.9, blue: 0.5).opacity(0.18))
                    .cornerRadius(12)
            }

            Divider()
                .background(Color.white.opacity(0.12))

            // Route visual
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Circle()
                        .fill(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                        .frame(width: 10, height: 10)
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0), AppTheme.bgBottomLeft],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 2, height: 26)
                    Circle()
                        .fill(AppTheme.bgBottomLeft)
                        .frame(width: 10, height: 10)
                }

                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PICKUP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.placeholderText)
                        Text(ride.origin)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textLight)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("DESTINATION")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.placeholderText)
                        Text(ride.destination)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textLight)
                    }
                }
            }

            // Driver & Vehicle
            HStack {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(ride.driverName.prefix(1)))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(ride.driverName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textLight)
                        Text("\(ride.vehicleDescription) • \(ride.driverDepartment)")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.placeholderText)
                    }
                }

                Spacer()

                Button(action: { dashboardVM.cancelBooking(ride) }) {
                    Text("Cancel")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.buttonPurple.opacity(0.95),
                            Color(red: 0x22 / 255.0, green: 0x00 / 255.0, blue: 0x36 / 255.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0).opacity(0.35), lineWidth: 1.5)
                )
        )
    }

    private var noRideScheduledCard: some View {
        VStack(spacing: 12) {
            Image("CarIllustration")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 60)

            Text("No Ride Scheduled Today")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)

            Text("Join an existing colleague carpool or offer one to earn commuter points!")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.placeholderText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Button(action: { withAnimation { dashboardVM.selectedTab = 1 } }) {
                Text("Browse Carpools")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
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

                TextField("", text: $dashboardVM.searchQuery, prompt: Text("Search routes, coworkers, departments...").foregroundColor(AppTheme.placeholderText))
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
            // Eco Summary Card
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
                        value: "$\(Int(dashboardVM.estimatedCostSavedDollars))",
                        title: "Fuel Saved",
                        subtitle: "Carpooling savings"
                    )

                    ecoStatItem(
                        value: "\(dashboardVM.totalRidesCompleted)",
                        title: "Rides Shared",
                        subtitle: "This semester"
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.buttonPurple.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(red: 0.4, green: 0.9, blue: 0.6).opacity(0.3), lineWidth: 1)
                    )
            )

            // Corporate Benefits Notice
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

    // MARK: - Offer Ride Sheet
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
                        CustomTextField(placeholder: "Departure Location", text: $dashboardVM.newRideOrigin)
                        CustomTextField(placeholder: "Office / Destination", text: $dashboardVM.newRideDestination)
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
                        dashboardVM.offerRide(
                            driverName: authViewModel.currentUser?.name ?? "You",
                            department: "Corporate"
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
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
