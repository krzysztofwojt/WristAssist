import Foundation

public struct RealtimeVoiceOption: Equatable, Hashable, Identifiable, Sendable {
    public var id: String { apiValue }

    public let apiValue: String
    public let displayName: String

    public init(apiValue: String, displayName: String) {
        self.apiValue = apiValue
        self.displayName = displayName
    }
}

public struct OpenAIModelOption: Equatable, Hashable, Identifiable, Sendable {
    public var id: String { apiValue }

    public let apiValue: String
    public let displayName: String

    public init(apiValue: String, displayName: String) {
        self.apiValue = apiValue
        self.displayName = displayName
    }
}

public struct ProviderSettings: Codable, Equatable, Sendable {
    public var selectedAuthMode: AuthMode
    public var hasAPIKey: Bool
    public var model: String
    public var transcriptionModel: String
    public var voice: String
    public var instructions: String

    public init(
        selectedAuthMode: AuthMode = .openAIAPIKey,
        hasAPIKey: Bool = false,
        model: String = Self.defaultModel,
        transcriptionModel: String = Self.defaultTranscriptionModel,
        voice: String = Self.defaultVoice,
        instructions: String = Self.defaultInstructions
    ) {
        self.selectedAuthMode = selectedAuthMode
        self.hasAPIKey = hasAPIKey
        self.model = Self.normalizedModel(model)
        self.transcriptionModel = Self.normalizedTranscriptionModel(transcriptionModel)
        self.voice = Self.normalizedVoice(voice)
        self.instructions = instructions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let selectedAuthMode = try container.decodeIfPresent(AuthMode.self, forKey: .selectedAuthMode) ?? .openAIAPIKey
        let hasAPIKey = try container.decodeIfPresent(Bool.self, forKey: .hasAPIKey) ?? false
        let model = try container.decodeIfPresent(String.self, forKey: .model) ?? Self.defaultModel
        let transcriptionModel = try container.decodeIfPresent(String.self, forKey: .transcriptionModel)
            ?? Self.defaultTranscriptionModel
        let voice = try container.decodeIfPresent(String.self, forKey: .voice) ?? Self.defaultVoice
        let instructions = try container.decodeIfPresent(String.self, forKey: .instructions) ?? Self.defaultInstructions

        self.init(
            selectedAuthMode: selectedAuthMode,
            hasAPIKey: hasAPIKey,
            model: model,
            transcriptionModel: transcriptionModel,
            voice: voice,
            instructions: instructions
        )
    }

    public static let defaultModel = StandalonePTTDefaults.assistantModel
    public static let defaultTranscriptionModel = StandalonePTTDefaults.transcriptionModel
    public static let defaultVoice = "marin"
    public static let defaultInstructions = "You are WristAssist, a concise voice assistant on Apple Watch. Answer briefly unless the user asks for detail."

    public static let supportedAssistantModels = [
        OpenAIModelOption(apiValue: "gpt-5.4-nano", displayName: "GPT-5.4 nano"),
        OpenAIModelOption(apiValue: "gpt-5.4-mini", displayName: "GPT-5.4 mini"),
        OpenAIModelOption(apiValue: "gpt-5.4", displayName: "GPT-5.4"),
        OpenAIModelOption(apiValue: "gpt-5.5", displayName: "GPT-5.5")
    ]

    public static let supportedTranscriptionModels = [
        OpenAIModelOption(apiValue: "gpt-4o-mini-transcribe", displayName: "GPT-4o mini Transcribe"),
        OpenAIModelOption(apiValue: "gpt-4o-transcribe", displayName: "GPT-4o Transcribe")
    ]

    public static let supportedVoices = [
        RealtimeVoiceOption(apiValue: "alloy", displayName: "Alloy"),
        RealtimeVoiceOption(apiValue: "ash", displayName: "Ash"),
        RealtimeVoiceOption(apiValue: "ballad", displayName: "Ballad"),
        RealtimeVoiceOption(apiValue: "coral", displayName: "Coral"),
        RealtimeVoiceOption(apiValue: "echo", displayName: "Echo"),
        RealtimeVoiceOption(apiValue: "sage", displayName: "Sage"),
        RealtimeVoiceOption(apiValue: "shimmer", displayName: "Shimmer"),
        RealtimeVoiceOption(apiValue: "verse", displayName: "Verse"),
        RealtimeVoiceOption(apiValue: "marin", displayName: "Marin"),
        RealtimeVoiceOption(apiValue: "cedar", displayName: "Cedar")
    ]

    public static let `default` = ProviderSettings()

    public static func normalizedModel(_ model: String) -> String {
        normalizedOptionValue(model, options: supportedAssistantModels, fallback: defaultModel)
    }

    public static func normalizedTranscriptionModel(_ model: String) -> String {
        normalizedOptionValue(model, options: supportedTranscriptionModels, fallback: defaultTranscriptionModel)
    }

    public static func normalizedVoice(_ voice: String) -> String {
        let value = voice.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard supportedVoices.contains(where: { $0.apiValue == value }) else {
            return defaultVoice
        }

        return value
    }

    private static func normalizedOptionValue(
        _ value: String,
        options: [OpenAIModelOption],
        fallback: String
    ) -> String {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let option = options.first(where: { $0.apiValue == normalized }) else {
            return fallback
        }

        return option.apiValue
    }
}
