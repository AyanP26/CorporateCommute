import SwiftUI

struct ManageRequestsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dashboardVM: CommuteDashboardViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 0) {
                    // Header Bar
                    headerBar
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if dashboardVM.incomingRequests.isEmpty {
                                emptyStateCard
                            } else {
                                ForEach(dashboardVM.incomingRequests) { request in
                                    incomingRequestCard(request)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.textLight)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Manage Requests")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)

                Text("Incoming colleague requests for your carpools")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.placeholderText)
            }

            Spacer()

            let pendingCount = dashboardVM.incomingRequests.filter { $0.status == .pending }.count
            if pendingCount > 0 {
                Text("\(pendingCount) Pending")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.18))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Incoming Request Card (Liquid Glass)
    private func incomingRequestCard(_ request: RideRequest) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Passenger info & Status badge
            HStack(alignment: .center) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(LinearGradient(
                            colors: [AppTheme.accentBlue, AppTheme.bgBottomLeft],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Text(String(request.passengerName.prefix(1)).uppercased())
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .shadow(color: AppTheme.accentBlue.opacity(0.3), radius: 6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(request.passengerName)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text(request.passengerEmail)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.placeholderText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                }

                Spacer()

                // Status Badge
                statusBadge(request.status)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Route
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.accentBlue)

                Text(request.route)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textLight)
                    .lineLimit(1)
            }

            // Timestamp
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.placeholderText)
                Text("Requested \(timeAgoString(from: request.timestamp))")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.placeholderText)
            }

            // Action Buttons (Accept / Decline) if Pending
            if request.status == .pending {
                HStack(spacing: 12) {
                    // Accept Button
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dashboardVM.acceptRequest(request)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Accept")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.ecoGreen)
                                .shadow(color: AppTheme.ecoGreen.opacity(0.35), radius: 6)
                        )
                    }

                    // Decline Button
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dashboardVM.declineRequest(request)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Decline")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(AppTheme.errorRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.errorRed.opacity(0.12))
                                .overlay(Capsule().stroke(AppTheme.errorRed.opacity(0.35), lineWidth: 1))
                        )
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private func statusBadge(_ status: RideRequestStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(badgeColor(status))
                .frame(width: 6, height: 6)
            Text(status.title)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(badgeColor(status))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(badgeColor(status).opacity(0.15))
        .clipShape(Capsule())
    }

    private func badgeColor(_ status: RideRequestStatus) -> Color {
        switch status {
        case .pending: return Color.orange
        case .accepted: return AppTheme.ecoGreen
        case .declined: return AppTheme.errorRed
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray.fill")
                .font(.system(size: 42))
                .foregroundColor(AppTheme.placeholderText.opacity(0.7))
                .padding(.top, 12)

            Text("No Ride Requests")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)

            Text("You don't have any incoming ride requests at the moment. When colleagues request to join your offered routes, they'll appear here.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.placeholderText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )
        )
        .padding(.top, 24)
    }

    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
