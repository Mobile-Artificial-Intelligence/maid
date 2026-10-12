import Anthropic from '@anthropic-ai/sdk';
import { fetch as expoFetch } from "expo/fetch";
import { isValidURL, LanguageModelClient, LanguageModelSettings } from "./types";

export async function connectAnthropic(
  { baseURL, apiKey, headers }: LanguageModelSettings,
  name: string
): Promise<LanguageModelClient | undefined> {
  if (!apiKey) {
    console.warn(`${name} API key not set`);
    return;
  }

  if (!isValidURL(baseURL)) return;

  const anthropic = new Anthropic({
    apiKey,
    baseURL,
    defaultHeaders: headers,
    fetch: expoFetch as typeof fetch,
  });

  return {
    listModels: async () => {
      const response = await anthropic.models.list();
      return { models: response.data.map((model) => model.id) };
    },
    prompt: async ({ model, messages, onUpdate, shouldStop }) => {
      const stream = await anthropic.messages.stream({
        model,
        max_tokens: 1024,
        stream: true,
        messages: messages.map((msg) => ({
          role: msg.role as "user" | "assistant",
          content: msg.content,
        })),
      });

      for await (const chunk of stream) {
        if (shouldStop()) {
          stream.abort();
          break;
        }

        if (chunk.type === 'content_block_delta' && chunk.delta.type === 'text_delta') {
          onUpdate(chunk.delta.text);
        }
      }
    },
  };
}
