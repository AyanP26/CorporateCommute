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
                    .fill(AppTheme.accentBlueSoft)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.accentBlue)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                        .textCase(.uppercase)
                        .lineLimit(1)

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
                            .lineLimit(1)
                    }
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 12))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(AppTheme.accentBlue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.accentBlueSoft)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
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
