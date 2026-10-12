import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { isValidURL, LanguageModelClient, LanguageModelSettings } from "./types";

// Attached images travel as OpenAI image_url parts, and only to models known
// to accept them; LiteLLM translates them into each provider's own format.
export function toChatMessages(messages: Array<MessageNode>, imagesSupported: boolean) {
  return messages.map((message) => {
    const role = message.role as "system" | "user" | "assistant";
    const images: Array<string> | undefined = (message.metadata as any)?.images;

    if (imagesSupported && role === "user" && images && images.length > 0) {
      return {
        role,
        content: [
          { type: "text" as const, text: message.content as string },
          ...images.map((url) => ({ type: "image_url" as const, image_url: { url } })),
        ],
      };
    }

    return { role, content: message.content as string };
  });
}

export function createOpenAIClient(openai: OpenAI): LanguageModelClient {
  return {
    listModels: async () => {
      const response = await openai.models.list();
      return { models: response.data.map((model) => model.id) };
    },
    prompt: async ({ model, messages, parameters, imagesSupported, onUpdate, shouldStop }) => {
      const stream = await openai.chat.completions.create({
        model,
        messages: toChatMessages(messages, imagesSupported),
        stream: true,
        ...parameters,
      }, {
        maxRetries: 3,
      });

      for await (const event of stream) {
        if (shouldStop()) {
          stream.controller.abort();
          break;
        }

        const chunk = event.choices[0]?.delta?.content;
        if (chunk) {
          onUpdate(chunk);
        }
      }
    },
  };
}

/** Connects any provider that speaks the OpenAI chat completions API. */
export async function connectOpenAI(
  { baseURL, apiKey, headers }: LanguageModelSettings,
  name: string
): Promise<LanguageModelClient | undefined> {
  if (!apiKey) {
    console.warn(`${name} API key not set`);
    return;
  }

  if (!isValidURL(baseURL)) return;

  return createOpenAIClient(new OpenAI({
    apiKey,
    baseURL,
    defaultHeaders: headers,
    fetch: expoFetch as typeof fetch,
  }));
}
