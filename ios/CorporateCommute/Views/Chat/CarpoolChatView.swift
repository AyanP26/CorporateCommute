import SwiftUI
import Combine

struct CarpoolChatView: View {
    let ride: CommuteRide
    let currentUser: User
    @Environment(\.dismiss) private var dismiss

    @State private var messages: [CarpoolChatMessage] = []
    @State private var messageText: String = ""
    @State private var isSending: Bool = false
    @State private var listenerCancellation: (() -> Void)? = nil

    private var isGeneralChat: Bool {
        ride.id == "general_commuter_chat"
    }

    private let rideService: RideServiceProtocol = FirebaseManager.shared.rideService

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 0) {
                    // Custom Header
                    chatHeaderView

                    // Messages List
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                // Channel Summary Banner
                                channelSummaryBanner
                                    .padding(.horizontal, 16)
                                    .padding(.top, 12)

                                if messages.isEmpty {
                                    emptyChatPlaceholder
                                        .padding(.top, 28)
                                } else {
                                    ForEach(messages) { message in
                                        let isMe = message.senderId == currentUser.id || message.isCurrentUser
                                        CarpoolMessageBubble(message: message, isCurrentUser: isMe)
                                            .id(message.id)
                                    }
                                }
                            }
                            .padding(.bottom, 16)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .onChange(of: messages.count) { _, _ in
                            if let lastId = messages.last?.id {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }

                    // Input Bar
                    messageInputBar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                startObservingMessages()
            }
            .onDisappear {
                listenerCancellation?()
            }
        }
    }

    // MARK: - Header
    private var chatHeaderView: some View {
        HStack(spacing: 12) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textLight)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(isGeneralChat ? "General Commuter Chat" : "\(ride.origin) ➔ \(ride.destination)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.ecoGreen)
                        .frame(width: 7, height: 7)

                    Text(isGeneralChat ? "Company-Wide Network • Live" : "Driver: \(ride.driverName) • \(ride.departureTime)")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.placeholderText)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Room badge
            HStack(spacing: 4) {
                Image(systemName: isGeneralChat ? "globe" : "car.2.fill")
                    .font(.system(size: 11))
                Text(isGeneralChat ? "General" : "Ride Chat")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(AppTheme.accentBlue)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.accentBlueSoft)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(
            Color.black.opacity(0.35)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Summary Banner
    private var channelSummaryBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.accentPurple)

            VStack(alignment: .leading, spacing: 2) {
                Text(isGeneralChat ? "General Commuter Channel" : "Carpool Coordination Chat")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textLight)
                    .lineLimit(1)

                Text(isGeneralChat ? "Live chat synced across iOS and Android coworkers." : "Coordinate pickup and schedule with confirmed riders.")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.placeholderText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: - Empty State
    private var emptyChatPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.badge.filled.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.accentBlue, AppTheme.accentPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 20)

            Text("No Messages Yet")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textLight)

            Text(isGeneralChat
                 ? "Send a message to all commuters across campus! Ask about rides, traffic updates, or coordinate carpools."
                 : "Say hi to your carpool group! Coordinate pickup spots, arrival times, or any route changes.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.placeholderText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Quick suggestion chips
            VStack(spacing: 8) {
                Text("QUICK SUGGESTIONS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.placeholderText)
                    .padding(.top, 8)

                if isGeneralChat {
                    quickPromptButton("👋 Hey everyone! Heading to Innovation Campus today.")
                    quickPromptButton("🚗 Anyone leaving Tysons around 5:00 PM?")
                    quickPromptButton("ℹ️ Route 7 traffic is smooth this morning.")
                } else {
                    quickPromptButton("👋 Hey everyone! Ready for our commute.")
                    quickPromptButton("📍 I'll be waiting at the main entrance.")
                    quickPromptButton("⏰ Running about 3 minutes late!")
                }
            }
            .padding(.top, 8)
        }
    }

    private func quickPromptButton(_ text: String) -> some View {
        Button(action: {
            messageText = text
            sendMessage()
        }) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textLight.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
        }
    }

    // MARK: - Message Input Bar
    private var messageInputBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField(isGeneralChat ? "Message all commuters..." : "Message carpool...", text: $messageText)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textLight)
                    .tint(.white) // White vertical typing indicator
                    .accentColor(AppTheme.accentBlue)

                if !messageText.isEmpty {
                    Button(action: { messageText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.placeholderText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                    .fill(AppTheme.inputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )

            // Send Button
            Button(action: sendMessage) {
                ZStack {
                    Circle()
                        .fill(
                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.white.opacity(0.1)
                                : AppTheme.accentBlue
                        )
                        .frame(width: 44, height: 44)

                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(
                                messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? AppTheme.placeholderText
                                    : .white
                            )
                    }
                }
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color.black.opacity(0.4)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1),
            alignment: .top
        )
    }

    // MARK: - Send Action
    private func sendMessage() {
        let textToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        messageText = ""
        isSending = true

        Task { @MainActor in
            do {
                let sent = try await rideService.sendMessage(rideId: ride.id, text: textToSend, sender: currentUser)
                if !messages.contains(where: { $0.id == sent.id }) {
                    messages.append(sent)
                }
                isSending = false
            } catch {
                isSending = false
                print("[CarpoolChatView] Send error: \(error.localizedDescription)")
            }
        }
    }

    private func startObservingMessages() {
        // Initial fetch from "messages" collection (same as Android)
        Task { @MainActor in
            do {
                let fetched = try await rideService.fetchMessages(for: ride.id)
                self.messages = fetched
            } catch {
                print("[CarpoolChatView] Fetch error: \(error.localizedDescription)")
            }
        }

        // Real-time snapshot listener
        self.listenerCancellation = rideService.observeMessages(for: ride.id) { updatedMessages in
            Task { @MainActor in
                self.messages = updatedMessages
            }
        }
    }
}

// MARK: - Message Bubble Component
struct CarpoolMessageBubble: View {
    let message: CarpoolChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser {
                Spacer(minLength: 48)
            } else {
                // Sender Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.accentBlue, AppTheme.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text(String(message.senderFirstName.prefix(1)).uppercased())
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 3) {
                if !isCurrentUser {
                    Text(message.senderFirstName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                        .padding(.leading, 4)
                }

                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                    Text(message.text)
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.textLight)
                        .multilineTextAlignment(.leading)

                    Text(message.formattedTime)
                        .font(.system(size: 10))
                        .foregroundColor(isCurrentUser ? Color.white.opacity(0.65) : AppTheme.placeholderText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isCurrentUser ?
                        AnyShapeStyle(
                            LinearGradient(
                                colors: [AppTheme.accentBlue, AppTheme.buttonPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        ) :
                        AnyShapeStyle(
                            Color.white.opacity(0.08)
                        )
                )
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isCurrentUser ? Color.white.opacity(0.2) : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
            }

            if !isCurrentUser {
                Spacer(minLength: 48)
            }
        }
        .padding(.horizontal, 16)
    }
}
