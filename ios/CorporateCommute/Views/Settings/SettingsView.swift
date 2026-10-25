import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    // Editable state
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var company: String = ""
    @State private var jobTitle: String = ""
    @State private var workLocation: CommuteLocation?
    @State private var homeLocation: CommuteLocation?
    @State private var preferredRole: String = "Flexible"
    @State private var vehicleModel: String = ""
    @State private var vehicleColor: String = ""
    @State private var vehicleSeats: Int = 3
    @State private var notificationsEnabled: Bool = true

    // Sheets & Dialogs
    @State private var showingWorkLocationPicker = false
    @State private var showingHomeLocationPicker = false
    @State private var showingLogoutConfirmation = false
    @State private var showSavedBanner = false

    private let roles = ["Rider", "Driver", "Flexible"]

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // User Avatar & Email Header
                        profileHeader
                            .padding(.top, 12)

                        // Workplace & Job Location (Apple Maps integrated)
                        jobLocationSection

                        // Home Commute Location (Apple Maps integrated)
                        homeLocationSection

                        // Commute & Carpool Preferences
                        commutePreferencesSection

                        // Vehicle Details (if Driver or Flexible)
                        if preferredRole != "Rider" {
                            vehicleSection
                        }

                        // App Notifications
                        notificationsSection

                        // Save Button
                        PrimaryButton(title: "Save Settings") {
                            saveSettings()
                        }
                        .padding(.top, 8)

                        // Logout Button
                        Button(action: { showingLogoutConfirmation = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                            }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.red.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                                    .fill(Color.red.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                                            .stroke(Color.red.opacity(0.25), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, AppTheme.horizontalPadding)
                }
            }
            .navigationTitle("User Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textLight)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                }
            }
            .sheet(isPresented: $showingWorkLocationPicker) {
                LocationPickerView(
                    title: "Select Job Location",
                    initialLocation: workLocation ?? CommuteLocation.corporateHQ
                ) { newLoc in
                    self.workLocation = newLoc
                }
            }
            .sheet(isPresented: $showingHomeLocationPicker) {
                LocationPickerView(
                    title: "Select Home Address",
                    initialLocation: homeLocation
                ) { newLoc in
                    self.homeLocation = newLoc
                }
            }
            .confirmationDialog("Log Out", isPresented: $showingLogoutConfirmation, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    authViewModel.logout()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
            .overlay(alignment: .top) {
                if showSavedBanner {
                    savedNotificationBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onAppear {
                loadCurrentUserData()
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0), AppTheme.bgBottomLeft],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 72, height: 72)
                .overlay(
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )
                .shadow(color: Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0).opacity(0.3), radius: 10)

            VStack(spacing: 4) {
                Text(name.isEmpty ? "Corporate Commuter" : name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)

                Text(authViewModel.currentUser?.email ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.placeholderText)
            }

            VStack(spacing: 12) {
                CustomTextField(placeholder: "Full Name", text: $name)
                CustomTextField(placeholder: "Phone Number", text: $phoneNumber)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.buttonPurple.opacity(0.7))
        )
    }

    // MARK: - Job Location Section (Apple Maps)
    private var jobLocationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Work & Job Details", icon: "briefcase.fill")

            CustomTextField(placeholder: "Company / Employer", text: $company)
            CustomTextField(placeholder: "Job Title (e.g. Software Engineer)", text: $jobTitle)

            LocationRowView(
                icon: "building.2.crop.circle.fill",
                label: "Job / Office Location (Apple Maps)",
                location: workLocation,
                placeholder: "Set primary workplace location..."
            ) {
                showingWorkLocationPicker = true
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.buttonPurple.opacity(0.7))
        )
    }

    // MARK: - Home Location Section (Apple Maps)
    private var homeLocationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Home Commute Origin", icon: "house.fill")

            LocationRowView(
                icon: "house.circle.fill",
                label: "Home Address (Apple Maps)",
                location: homeLocation,
                placeholder: "Set your departure home address..."
            ) {
                showingHomeLocationPicker = true
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.buttonPurple.opacity(0.7))
        )
    }

    // MARK: - Commute Preferences
    private var commutePreferencesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Commute Role", icon: "person.2.fill")

            Picker("Preferred Role", selection: $preferredRole) {
                ForEach(roles, id: \.self) { role in
                    Text(role).tag(role)
                }
            }
            .pickerStyle(.segmented)
            .padding(4)
            .background(Color.black.opacity(0.35))
            .cornerRadius(12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.buttonPurple.opacity(0.7))
        )
    }

    // MARK: - Vehicle Details
    private var vehicleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Vehicle Details", icon: "car.fill")

            CustomTextField(placeholder: "Vehicle Make & Model (e.g. Tesla Model 3)", text: $vehicleModel)
            CustomTextField(placeholder: "Vehicle Color", text: $vehicleColor)

            HStack {
                Text("Passenger Seats Available:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textLight)

                Spacer()

                Stepper("\(vehicleSeats) seats", value: $vehicleSeats, in: 1...7)
                    .foregroundColor(AppTheme.textLight)
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                    .fill(AppTheme.buttonPurple)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.buttonPurple.opacity(0.7))
        )
    }

    // MARK: - Notifications
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Notifications", icon: "bell.fill")

            Toggle(isOn: $notificationsEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ride Match Alerts")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textLight)
                    Text("Receive updates when coworker routes match your schedule")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.placeholderText)
                }
            }
            .tint(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.buttonPurple.opacity(0.7))
        )
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)
        }
    }

    private var savedNotificationBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Settings saved successfully!")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0))
                .overlay(Capsule().stroke(Color.green.opacity(0.4), lineWidth: 1))
        )
        .padding(.top, 16)
        .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
    }

    private func loadCurrentUserData() {
        guard let user = authViewModel.currentUser else { return }
        name = user.name
        phoneNumber = user.phoneNumber
        company = user.company
        jobTitle = user.jobTitle
        workLocation = user.workLocation
        homeLocation = user.homeLocation
        preferredRole = user.preferredRole
        vehicleModel = user.vehicleModel
        vehicleColor = user.vehicleColor
        vehicleSeats = user.vehicleSeats
        notificationsEnabled = user.notificationsEnabled
    }

    private func saveSettings() {
        guard var user = authViewModel.currentUser else { return }
        user.name = name.trimmingCharacters(in: .whitespaces)
        user.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespaces)
        user.company = company.trimmingCharacters(in: .whitespaces)
        user.jobTitle = jobTitle.trimmingCharacters(in: .whitespaces)
        user.workLocation = workLocation
        user.homeLocation = homeLocation
        user.officeLocation = workLocation?.name ?? user.officeLocation
        user.preferredRole = preferredRole
        user.vehicleModel = vehicleModel.trimmingCharacters(in: .whitespaces)
        user.vehicleColor = vehicleColor.trimmingCharacters(in: .whitespaces)
        user.vehicleSeats = vehicleSeats
        user.notificationsEnabled = notificationsEnabled

        Task {
            let success = await authViewModel.saveUserProfile(user)
            if success {
                withAnimation {
                    showSavedBanner = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showSavedBanner = false
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
