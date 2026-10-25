import SwiftUI

struct LocationRowView: View {
    let icon: String
    let label: String
    let location: CommuteLocation?
    let placeholder: String
    let onSelect: () -> Void

    init(
        icon: String = "mappin.circle.fill",
        label: String,
        location: CommuteLocation?,
        placeholder: String = "Select location via Apple Maps",
        onSelect: @escaping () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.location = location
        self.placeholder = placeholder
        self.onSelect = onSelect
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0).opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.placeholderText)
                        .textCase(.uppercase)

                    if let loc = location {
                        Text(loc.name)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                            .lineLimit(1)

                        Text(loc.address)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.placeholderText)
                            .lineLimit(1)
                    } else {
                        Text(placeholder)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.placeholderText)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(.system(size: 13))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                }
                .foregroundColor(Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.buttonPurple.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}
