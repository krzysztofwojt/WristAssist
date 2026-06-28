# OpenClaw-Style Conversation State

This note records the intended conversation-state direction for Nadgar.
The current app can start a fresh session on each launch, but the state model
should stay compatible with a future single continuous conversation.

## OpenClaw Pattern

OpenClaw separates the stable conversation route from the current model
context:

- `sessionKey` identifies the conversation bucket, such as a direct message,
  group, channel, cron job, or webhook.
- `sessionId` identifies the current model context and transcript for that
  bucket.

Commands such as `/new` or `/reset` do not erase the user's whole conversation
experience. They create a new `sessionId` for the same `sessionKey`, so the
same chat route continues while the model context starts fresh.

Long conversations are not treated as infinite prompt context. OpenClaw keeps
transcripts and session metadata separately, and can compact older context into
summaries when the active context grows too large.

## Nadgar State Model

For Nadgar, keep the model simpler than OpenClaw while preserving the same
core separation:

- `conversationKey = "default"`: stable key for the user's watch conversation.
- `currentSessionId`: local identifier for the current app/model session.
- `openAIConversationId` or `lastResponseId`: pointer to the remote OpenAI
  state used for the current model context.
- `messages`: local UI history used to render the chat bubbles.
- `sessionStartedAt`: timestamp for the current session start.
- `lastInteractionAt`: timestamp for the latest user/model interaction.
- `summary`: optional future field for compacted history.

The local `messages` list is required for the watch UI and should be treated as
the display history. The OpenAI state pointer is separate and should be treated
as the model-context pointer. The app should not send the entire visible
history on every request when an OpenAI state pointer is available.

## V0 Behavior

For the first implementation, it is acceptable to create a fresh
`currentSessionId` and fresh OpenAI state whenever the app launches.

The chat UI can still use the local `messages` list for the active app session,
and each push-to-talk turn should append:

- the transcribed user message,
- the assistant text response,
- any local playback/status metadata needed by the UI.

## Future Continuous Conversation

To move from V0 to a single continuous conversation, keep
`conversationKey = "default"` stable and persist its OpenAI state pointer.

On app launch:

1. Load the saved record for `conversationKey = "default"`.
2. Reuse the saved `openAIConversationId` or `lastResponseId` if available.
3. Reuse the saved local message history for the chat UI, subject to any local
   retention limit.
4. Create a new model state only when the user explicitly resets the
   conversation, local state is missing, or the remote state is no longer
   usable.

This keeps the watch experience close to a messenger-style continuous thread,
while still allowing the model context to be reset or compacted independently
of the visible conversation history.

## Verification Checklist

- The document exists under `docs/`.
- The document separates local UI history from model/OpenAI state.
- The document does not recommend sending the entire conversation history on
  every request.
- The document records that current V0 behavior can create a new session on app
  launch.
- The document records the future migration path to a single continuous
  conversation.
