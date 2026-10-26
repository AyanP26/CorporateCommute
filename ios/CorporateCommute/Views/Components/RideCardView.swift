import SwiftUI

struct RideCardView: View {
    let ride: CommuteRide
    let onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Driver info & Department badge
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
                            Text(String(ride.driverName.prefix(1)).uppercased())
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .shadow(color: AppTheme.accentBlue.opacity(0.3), radius: 6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(ride.driverName)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)

                        Text(ride.driverDepartment)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.placeholderText)
                    }
                }

                Spacer()

                // Seats badge
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                    Text(ride.availableSeats > 0 ? "\(ride.availableSeats) left" : "Full")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .foregroundColor(ride.availableSeats > 0 ? AppTheme.ecoGreen : AppTheme.placeholderText)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(ride.availableSeats > 0 ? AppTheme.ecoGreenSoft : Color.white.opacity(0.06))
                        .overlay(
                            Capsule().stroke(
                                ride.availableSeats > 0 ? AppTheme.ecoGreen.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                        )
                )
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Route timeline
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    Circle()
                        .fill(AppTheme.accentBlue)
                        .frame(width: 9, height: 9)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.accentBlue, AppTheme.bgBottomLeft],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: 24)
                    Circle()
                        .fill(AppTheme.ecoGreen)
                        .frame(width: 9, height: 9)
                }
                .padding(.top, 4)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PICKUP")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.accentBlue)
                            Text(ride.origin)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textLight)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(ride.departureTime)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.accentBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.accentBlueSoft)
                                .cornerRadius(8)

                            if !ride.departureDate.isEmpty {
                                Text(ride.departureDate)
                                    .font(.system(size: 10))
                                    .foregroundColor(AppTheme.placeholderText)
                            }
                        }
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DROP-OFF")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.ecoGreen)
                            Text(ride.destination)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textLight.opacity(0.95))
                                .lineLimit(1)
                        }

                        Spacer()

                        if let retTime = ride.returnTime {
                            Text("Return: \(retTime)")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(AppTheme.placeholderText)
                        }
                    }
                }
            }

            // Optional Notes (matching Android's tvNotes)
            if !ride.notes.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "note.text")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.placeholderText)
                    Text(ride.notes)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.placeholderText.opacity(0.9))
                        .lineLimit(2)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
            }

            // Footer: Vehicle info & Action Button
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: "car.side.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.placeholderText)
                    Text(ride.vehicleDescription)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.placeholderText)
                        .lineLimit(1)
                }

                Spacer()

                Button(action: onAction) {
                    HStack(spacing: 5) {
                        if ride.isUserBooked {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                            Text("Reserved")
                        } else if ride.hasPendingRequest {
                            Image(systemName: "hourglass")
                                .font(.system(size: 11))
                            Text("Requested")
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 11))
                            Text("Request Join")
                        }
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        ride.isUserBooked ?
                            AppTheme.accentBlue :
                            (ride.hasPendingRequest ? Color.orange.opacity(0.85) : AppTheme.buttonPurple)
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(ride.isUserBooked ? 0.3 : 0.15), lineWidth: 1)
                    )
                }
                .disabled(ride.availableSeats == 0 && !ride.isUserBooked && !ride.hasPendingRequest)
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
}

#Preview {
    RideCardView(
        ride: CommuteRide(
            driverName: "Sarah Chen",
            driverDepartment: "Product Engineering",
            vehicleDescription: "Tesla Model Y • Blue",
            origin: "Downtown Hub",
            destination: "Corporate HQ - Innovation Campus",
            departureTime: "8:15 AM",
            availableSeats: 2,
            totalSeats: 4
        ),
        onAction: {}
    )
    .padding()
    .background(Color.black)
}
