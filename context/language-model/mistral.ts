import { Mistral } from '@mistralai/mistralai';
import { TextChunk } from "@mistralai/mistralai/models/components";
import { isValidURL, LanguageModelClient, LanguageModelSettings } from "./types";

export async function connectMistral(
  { baseURL, apiKey }: LanguageModelSettings,
  name: string
): Promise<LanguageModelClient | undefined> {
  if (!apiKey) {
    console.warn(`${name} API key not set`);
    return;
  }

  if (!isValidURL(baseURL)) return;

  const mistral = new Mistral({
    apiKey,
    serverURL: baseURL
  });

  return {
    listModels: async () => {
      const response = await mistral.models.list();
      return { models: response.data?.map((model) => model.id) ?? [] };
    },
    prompt: async ({ model, messages, parameters, onUpdate, shouldStop }) => {
      const response = await mistral.chat.complete({
        model,
        messages: messages.map((msg) => ({
          role: msg.role as "system" | "user" | "assistant",
          content: msg.content,
        })),
        ...parameters,
      });

      const content = response.choices[0]?.message?.content ?? "";

      if (typeof content === "string") {
        onUpdate(content);
        return;
      }

      for (const chunk of content) {
        if (shouldStop()) break;
        if (chunk.type !== "text") continue;
        onUpdate((chunk as TextChunk).text);
      }
    },
  };
}
