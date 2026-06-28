import Foundation

public enum RealtimeClientEvent: Equatable, Sendable {
    case sessionUpdate(RealtimeSession)
    case appendInputAudio(base64PCM16: String)
    case clearInputAudio
    case commitInputAudio
    case createResponse
    case cancelResponse(responseID: String?)
    case truncateConversationItem(itemID: String, contentIndex: Int, audioEndMilliseconds: Int)

    public func encodedData() throws -> Data {
        let object = try jsonObject()
        return try JSONSerialization.data(withJSONObject: object, options: [])
    }

    public func jsonObject() throws -> [String: Any] {
        switch self {
        case .sessionUpdate(let session):
            let data = try RealtimeJSON.encoder.encode(session)
            let sessionObject = try JSONSerialization.jsonObject(with: data, options: [])
            return [
                "type": "session.update",
                "session": sessionObject
            ]

        case .appendInputAudio(let base64PCM16):
            return [
                "type": "input_audio_buffer.append",
                "audio": base64PCM16
            ]

        case .clearInputAudio:
            return ["type": "input_audio_buffer.clear"]

        case .commitInputAudio:
            return ["type": "input_audio_buffer.commit"]

        case .createResponse:
            return ["type": "response.create"]

        case .cancelResponse(let responseID):
            var object: [String: Any] = ["type": "response.cancel"]
            if let responseID {
                object["response_id"] = responseID
            }
            return object

        case .truncateConversationItem(let itemID, let contentIndex, let audioEndMilliseconds):
            return [
                "type": "conversation.item.truncate",
                "item_id": itemID,
                "content_index": contentIndex,
                "audio_end_ms": audioEndMilliseconds
            ]
        }
    }
}

public enum RealtimeJSON {
    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    public static let decoder = JSONDecoder()
}
