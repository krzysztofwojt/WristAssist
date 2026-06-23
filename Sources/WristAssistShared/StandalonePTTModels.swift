import Foundation

public enum WatchPTTState: String, Codable, Equatable, Sendable {
    case ready
    case recording
    case transcribing
    case thinking
    case failed

    public var statusText: String {
        switch self {
        case .ready:
            return "Hold to talk"
        case .recording:
            return "Release to send"
        case .transcribing:
            return "Transcribing"
        case .thinking:
            return "Thinking"
        case .failed:
            return "Try again"
        }
    }
}

public enum ChatMessageRole: String, Codable, Equatable, Sendable {
    case user
    case assistant
}

public struct ChatMessage: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var role: ChatMessageRole
    public var text: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        role: ChatMessageRole,
        text: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

public enum StandalonePTTDefaults {
    public static let assistantModel = "gpt-5.5"
    public static let transcriptionModel = "gpt-4o-mini-transcribe"
    public static let audioSampleRate = 24_000
}
