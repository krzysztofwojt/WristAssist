import Testing
@testable import NadgarShared

struct RealtimeServerEventTests {
    @Test func decodesSessionCreated() throws {
        let data = #"{"type":"session.created"}"#.data(using: .utf8)!
        #expect(try RealtimeServerEvent(data: data) == .sessionCreated)
    }

    @Test func decodesAudioDelta() throws {
        let data = #"{"type":"response.output_audio.delta","delta":"YWJj","item_id":"item_123","response_id":"resp_123","content_index":0,"output_index":0}"#.data(using: .utf8)!
        #expect(
            try RealtimeServerEvent(data: data) == .audioDelta(
                RealtimeOutputAudioDelta(
                    base64Audio: "YWJj",
                    metadata: RealtimeOutputAudioMetadata(
                        itemID: "item_123",
                        responseID: "resp_123",
                        contentIndex: 0,
                        outputIndex: 0
                    )
                )
            )
        )
    }

    @Test func decodesAudioDoneMetadata() throws {
        let data = #"{"type":"response.output_audio.done","item_id":"item_123","response_id":"resp_123","content_index":0,"output_index":0}"#.data(using: .utf8)!
        #expect(
            try RealtimeServerEvent(data: data) == .audioDone(
                RealtimeOutputAudioMetadata(
                    itemID: "item_123",
                    responseID: "resp_123",
                    contentIndex: 0,
                    outputIndex: 0
                )
            )
        )
    }

    @Test func decodesNestedErrorMessage() throws {
        let data = #"{"type":"error","error":{"message":"bad token"}}"#.data(using: .utf8)!
        #expect(try RealtimeServerEvent(data: data) == .error("bad token"))
    }

    @Test func unknownEventPreservesType() throws {
        let data = #"{"type":"rate_limits.updated"}"#.data(using: .utf8)!
        #expect(try RealtimeServerEvent(data: data) == .unknown("rate_limits.updated"))
    }
}
