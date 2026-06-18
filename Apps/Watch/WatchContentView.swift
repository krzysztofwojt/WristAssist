import SwiftUI
import WristAssistShared

struct WatchContentView: View {
    @StateObject private var viewModel = WatchVoiceViewModel()
    @State private var selectedConversationMode: ConversationMode = .auto

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Group {
                if !viewModel.hasAPIKey {
                    missingAPIKeyView
                } else if viewModel.isIdle {
                    readyView
                } else {
                    activeView
                }
            }
            .padding(.horizontal, 8)
        }
        .task {
            await viewModel.requestInitialSettings()
        }
    }

    private var missingAPIKeyView: some View {
        Text("Open WristAssist on your iPhone and save API key.")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
    }

    private var readyView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: 14) {
                microphoneButton

                Button("Click to start") {
                    viewModel.startOrStop()
                }
                .buttonStyle(.plain)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
                .frame(minWidth: 118, minHeight: 34)
                .background(Color.white)
                .clipShape(Capsule())
                .accessibilityLabel("Start conversation")
            }

            Spacer(minLength: 54)

            conversationModeSelector
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private var activeView: some View {
        VStack(spacing: 10) {
            microphoneButton

            Text(viewModel.state.displayName)
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var microphoneButton: some View {
        Button {
            viewModel.startOrStop()
        } label: {
            Image(systemName: viewModel.isRunning ? "stop.fill" : "mic.fill")
                .font(.system(size: 30, weight: .semibold))
                .frame(width: 76, height: 76)
                .background(viewModel.isRunning ? Color.red : Color.green)
                .foregroundStyle(.white)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.isRunning ? "Stop conversation" : "Start conversation")
    }

    private var conversationModeSelector: some View {
        HStack(spacing: 2) {
            ForEach(ConversationMode.allCases) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.14)) {
                        selectedConversationMode = mode
                    }
                } label: {
                    modeSelectorItem(mode.title, isSelected: selectedConversationMode == mode)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mode.accessibilityLabel)
                .accessibilityValue(selectedConversationMode == mode ? "Selected" : "Not selected")
            }
        }
        .padding(3)
        .frame(width: 120, height: 30)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }

    private func modeSelectorItem(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isSelected ? Color.black : Color.white.opacity(0.75))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isSelected ? Color.green : Color.clear)
            .clipShape(Capsule())
    }
}

private enum ConversationMode: CaseIterable, Identifiable {
    case auto
    case pushToTalk

    var id: Self { self }

    var title: String {
        switch self {
        case .auto:
            return "Auto"
        case .pushToTalk:
            return "PTT"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .auto:
            return "Auto mode"
        case .pushToTalk:
            return "Push to talk mode"
        }
    }
}
