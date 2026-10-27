import SwiftUI

struct MyRequestsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var dashboardVM: CommuteDashboardViewModel

    private var currentUserId: String {
        authViewModel.currentUser?.id ?? "current_user"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 0) {
                    // Header
                    headerBar
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if dashboardVM.mySentRequests.isEmpty {
                                emptyStateCard
                            } else {
                                ForEach(dashboardVM.mySentRequests) { request in
                                    myRequestCard(request)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.bottom, 32)
                    }
                    .refreshable {
                        dashboardVM.loadRequests(for: currentUserId)
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
            .onAppear {
                dashboardVM.loadRequests(for: currentUserId)
            }
        }
    }

    private var headerBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("My Sent Requests")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)

                Text("Track your carpool request approvals")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.placeholderText)
            }

            Spacer()

            Text("\(dashboardVM.mySentRequests.count) Total")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.accentBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.accentBlueSoft)
                .clipShape(Capsule())
        }
    }

    private func myRequestCard(_ request: RideRequest) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Route & Status badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.accentBlue)
                        Text(request.route)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                }

                Spacer()

                statusBadge(request.status)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Status explanatory message (matching Android)
            HStack(spacing: 8) {
                Image(systemName: statusIcon(request.status))
                    .font(.system(size: 13))
                    .foregroundColor(badgeColor(request.status))

                Text(statusDescription(request.status))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textLight.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            // Timestamp footer
            HStack {
                Text("Sent \(timeAgoString(from: request.timestamp))")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.placeholderText)

                Spacer()

                if request.status == .accepted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Seat Confirmed")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.ecoGreen)
                }
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

    private func statusDescription(_ status: RideRequestStatus) -> String {
        switch status {
        case .pending:
            return "Waiting for driver approval"
        case .accepted:
            return "Approved! Seat confirmed"
        case .declined:
            return "Declined by driver"
        }
    }

    private func statusIcon(_ status: RideRequestStatus) -> String {
        switch status {
        case .pending: return "hourglass"
        case .accepted: return "checkmark.circle.fill"
        case .declined: return "xmark.circle.fill"
        }
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
            Image(systemName: "paperplane.fill")
                .font(.system(size: 42))
                .foregroundColor(AppTheme.placeholderText.opacity(0.7))
                .padding(.top, 12)

            Text("No Sent Requests")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)

            Text("You haven't requested to join any carpools yet. Browse available rides in the Find Carpool tab and tap 'Request to Join'.")
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
