import SwiftUI

struct RideCardView: View {
    let ride: CommuteRide
    let onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Driver info & Department badge
            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0), AppTheme.bgBottomLeft],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Text(String(ride.driverName.prefix(1)))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(ride.driverName)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)

                        Text(ride.driverDepartment)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.placeholderText)
                    }
                }

                Spacer()

                // Seats badge
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                    Text("\(ride.availableSeats) left")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(ride.availableSeats > 0 ? Color(red: 0.4, green: 0.9, blue: 0.6) : .gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
            }

            Divider()
                .background(Color.white.opacity(0.12))

            // Route timeline
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                            .frame(width: 8, height: 8)
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 2, height: 16)
                        Circle()
                            .fill(Color(red: 0x54 / 255.0, green: 0x00 / 255.0, blue: 0x58 / 255.0))
                            .frame(width: 8, height: 8)
                    }
                    .padding(.top, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(ride.origin)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textLight)
                            Spacer()
                            Text(ride.departureTime)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                        }

                        HStack {
                            Text(ride.destination)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textLight.opacity(0.9))
                            Spacer()
                            if let retTime = ride.returnTime {
                                Text("Ret: \(retTime)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(AppTheme.placeholderText)
                            }
                        }
                    }
                }
            }

            // Footer: Vehicle info & Action Button
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.placeholderText)
                    Text(ride.vehicleDescription)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.placeholderText)
                }

                Spacer()

                Button(action: onAction) {
                    Text(ride.isUserBooked ? "Reserved ✓" : "Join Ride")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            ride.isUserBooked ?
                                Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0) :
                                AppTheme.buttonPressed
                        )
                        .cornerRadius(16)
                }
                .disabled(ride.availableSeats == 0 && !ride.isUserBooked)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.buttonPurple.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    RideCardView(
        ride: CommuteRide(
            driverName: "Sarah Chen",
            driverDepartment: "Product",
            vehicleDescription: "Tesla Model Y",
            origin: "Downtown Hub",
            destination: "Corporate HQ",
            departureTime: "8:15 AM",
            availableSeats: 2,
            totalSeats: 4
        ),
        onAction: {}
    )
    .padding()
    .background(Color.black)
}
