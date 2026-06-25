import Foundation
import Testing
@testable import WristAssistShared

struct ProviderSettingsTests {
    @Test func initializerNormalizesSupportedModelsAndVoice() {
        let settings = ProviderSettings(
            model: " GPT-5.4-MINI ",
            transcriptionModel: " GPT-4O-TRANSCRIBE ",
            voice: " CEDAR ",
            instructions: "Be concise."
        )

        #expect(settings.model == "gpt-5.4-mini")
        #expect(settings.transcriptionModel == "gpt-4o-transcribe")
        #expect(settings.voice == "cedar")
    }

    @Test func unsupportedModelsFallBackToDefaults() {
        let settings = ProviderSettings(model: "legacy-model", transcriptionModel: "legacy-transcribe")

        #expect(settings.model == ProviderSettings.defaultModel)
        #expect(settings.transcriptionModel == ProviderSettings.defaultTranscriptionModel)
    }

    @Test func unsupportedVoiceFallsBackToDefaultVoice() {
        let settings = ProviderSettings(voice: "unknown")

        #expect(settings.voice == ProviderSettings.defaultVoice)
    }

    @Test func decodedSettingsAreNormalized() throws {
        let data = """
        {
          "selectedAuthMode": "openAIAPIKey",
          "hasAPIKey": true,
          "model": " GPT-5.4 ",
          "transcriptionModel": " GPT-4O-TRANSCRIBE ",
          "voice": " MARIN ",
          "instructions": "Answer briefly."
        }
        """.data(using: .utf8)!

        let settings = try JSONDecoder().decode(ProviderSettings.self, from: data)

        #expect(settings.model == "gpt-5.4")
        #expect(settings.transcriptionModel == "gpt-4o-transcribe")
        #expect(settings.voice == "marin")
        #expect(settings.instructions == "Answer briefly.")
    }

    @Test func decodedSettingsDefaultMissingTranscriptionModel() throws {
        let data = """
        {
          "selectedAuthMode": "openAIAPIKey",
          "hasAPIKey": true,
          "model": "gpt-5.4-mini",
          "voice": "marin",
          "instructions": "Answer briefly."
        }
        """.data(using: .utf8)!

        let settings = try JSONDecoder().decode(ProviderSettings.self, from: data)

        #expect(settings.model == "gpt-5.4-mini")
        #expect(settings.transcriptionModel == ProviderSettings.defaultTranscriptionModel)
    }

    @Test func supportedModelOptionsExposeDisplayNamesAndAPIValues() {
        #expect(ProviderSettings.supportedAssistantModels.map(\.displayName).contains("GPT-5.4 nano"))
        #expect(ProviderSettings.supportedAssistantModels.map(\.apiValue).contains("gpt-5.4-nano"))
        #expect(ProviderSettings.supportedTranscriptionModels.map(\.displayName).contains("GPT-4o mini Transcribe"))
        #expect(ProviderSettings.supportedTranscriptionModels.map(\.apiValue).contains("gpt-4o-mini-transcribe"))
    }

    @Test func supportedVoicesExposeCapitalizedDisplayNamesAndLowercaseAPIValues() {
        #expect(ProviderSettings.supportedVoices.map(\.displayName).contains("Marin"))
        #expect(!ProviderSettings.supportedVoices.map(\.displayName).contains("marin"))
        #expect(ProviderSettings.supportedVoices.map(\.apiValue).contains("marin"))
        #expect(!ProviderSettings.supportedVoices.map(\.apiValue).contains("Marin"))
    }
}
