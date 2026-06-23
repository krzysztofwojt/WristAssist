import SwiftUI
import WristAssistShared

struct WatchContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = WatchVoiceViewModel()
    private let bottomID = "chat-bottom"
    private let chatBottomReadableInset: CGFloat = 78
    private let chatAccentColor = Color(red: 0.07, green: 0.46, blue: 1)

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if viewModel.hasAPIKey {
                chatView
                    .ignoresSafeArea(.container, edges: .bottom)
            } else {
                missingAPIKeyView
            }
        }
        .task {
            await viewModel.requestInitialSettings()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                Task {
                    await viewModel.prepareForForeground()
                }
            case .inactive, .background:
                viewModel.suspendAudioWarmup()
            @unknown default:
                viewModel.suspendAudioWarmup()
            }
        }
    }

    private var missingAPIKeyView: some View {
        Text("Open WristAssist on your iPhone and save API key.")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
    }

    private var chatView: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }

                        Color.clear
                            .frame(height: chatBottomReadableInset)
                            .id(bottomID)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 6)
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    scrollToBottom(proxy)
                }
                .onChange(of: viewModel.messages) { _, _ in
                    scrollToBottom(proxy)
                }
                .onChange(of: viewModel.pttState) { _, _ in
                    scrollToBottom(proxy)
                }

                topReadableGradient
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .allowsHitTesting(false)

                pushToTalkMicrophoneButton
                    .padding(.trailing, 18)
                    .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 24)
            }

            Text(message.text)
                .font(.system(size: 13, weight: .medium))
                .lineSpacing(1)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 9)
                .padding(.vertical, 7)
                .frame(maxWidth: 170, alignment: .leading)
                .background(message.role == .user ? chatAccentColor : Color.white.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            if message.role == .assistant {
                Spacer(minLength: 24)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }

    private var topReadableGradient: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.9),
                Color.black.opacity(0.52),
                Color.black.opacity(0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 56)
        .ignoresSafeArea(.container, edges: .top)
    }

    private var pushToTalkMicrophoneButton: some View {
        Image(systemName: "mic.fill")
            .font(.system(size: 22, weight: .semibold))
            .frame(width: 66, height: 44)
            .background(microphoneButtonColor)
            .foregroundStyle(.white)
            .clipShape(Capsule(style: .continuous))
            .scaleEffect(viewModel.isPushToTalkRecording ? 1.08 : 1)
            .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
            .animation(.easeInOut(duration: 0.14), value: viewModel.isPushToTalkRecording)
            .contentShape(Capsule(style: .continuous))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        viewModel.beginPushToTalkRecording()
                    }
                    .onEnded { _ in
                        viewModel.endPushToTalkRecording()
                    }
            )
            .allowsHitTesting(viewModel.hasAPIKey && !viewModel.isProcessing)
            .accessibilityLabel("Microphone")
            .accessibilityAddTraits(.isButton)
    }

    private var microphoneButtonColor: Color {
        if viewModel.isPushToTalkRecording {
            return .red
        }

        if viewModel.isProcessing {
            return Color.white.opacity(0.2)
        }

        return chatAccentColor
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.18)) {
            proxy.scrollTo(bottomID, anchor: .bottom)
        }
    }
}
