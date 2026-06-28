import Foundation

public struct RealtimeOutputAudioMetadata: Equatable, Sendable {
    public var itemID: String?
    public var responseID: String?
    public var contentIndex: Int
    public var outputIndex: Int?

    public init(
        itemID: String?,
        responseID: String?,
        contentIndex: Int = 0,
        outputIndex: Int? = nil
    ) {
        self.itemID = itemID
        self.responseID = responseID
        self.contentIndex = contentIndex
        self.outputIndex = outputIndex
    }
}

public struct RealtimeOutputAudioDelta: Equatable, Sendable {
    public var base64Audio: String
    public var metadata: RealtimeOutputAudioMetadata

    public init(base64Audio: String, metadata: RealtimeOutputAudioMetadata) {
        self.base64Audio = base64Audio
        self.metadata = metadata
    }
}

public enum RealtimeServerEvent: Equatable, Sendable {
    case sessionCreated
    case inputSpeechStarted
    case inputSpeechStopped
    case responseCreated
    case responseDone
    case audioDelta(RealtimeOutputAudioDelta)
    case audioDone(RealtimeOutputAudioMetadata)
    case error(String)
    case unknown(String)

    public init(data: Data) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = object as? [String: Any],
              let type = dictionary["type"] as? String
        else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Realtime server event must be a JSON object with a type field."
                )
            )
        }

        switch type {
        case "session.created":
            self = .sessionCreated
        case "input_audio_buffer.speech_started":
            self = .inputSpeechStarted
        case "input_audio_buffer.speech_stopped":
            self = .inputSpeechStopped
        case "response.created":
            self = .responseCreated
        case "response.done":
            self = .responseDone
        case "response.audio.delta", "response.output_audio.delta":
            self = .audioDelta(
                RealtimeOutputAudioDelta(
                    base64Audio: (dictionary["delta"] as? String) ?? (dictionary["audio"] as? String) ?? "",
                    metadata: Self.audioMetadata(from: dictionary)
                )
            )
        case "response.audio.done", "response.output_audio.done":
            self = .audioDone(Self.audioMetadata(from: dictionary))
        case "error":
            self = .error(Self.errorMessage(from: dictionary))
        default:
            self = .unknown(type)
        }
    }

    private static func errorMessage(from dictionary: [String: Any]) -> String {
        if let message = dictionary["message"] as? String {
            return message
        }

        if let error = dictionary["error"] as? [String: Any],
           let message = error["message"] as? String {
            return message
        }

        return "Realtime API returned an error."
    }

    private static func audioMetadata(from dictionary: [String: Any]) -> RealtimeOutputAudioMetadata {
        RealtimeOutputAudioMetadata(
            itemID: dictionary["item_id"] as? String,
            responseID: responseID(from: dictionary),
            contentIndex: integerValue(from: dictionary["content_index"]) ?? 0,
            outputIndex: integerValue(from: dictionary["output_index"])
        )
    }

    private static func responseID(from dictionary: [String: Any]) -> String? {
        if let responseID = dictionary["response_id"] as? String {
            return responseID
        }

        if let response = dictionary["response"] as? [String: Any],
           let responseID = response["id"] as? String {
            return responseID
        }

        return nil
    }

    private static func integerValue(from value: Any?) -> Int? {
        if let value = value as? Int {
            return value
        }

        if let value = value as? Double {
            return Int(value)
        }

        if let value = value as? NSNumber {
            return value.intValue
        }

        return nil
    }
}
