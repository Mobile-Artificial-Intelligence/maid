import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import { Ollama } from "ollama/browser";
import { isValidURL, LanguageModelClient, LanguageModelSettings } from "./types";

function parseMessages(messages: Array<MessageNode>) {
  return messages.map((message) => {
    const images: Array<string> | undefined = (message.metadata as any)?.images;

    if (images && images.length > 0) {
      return {
        role: message.role,
        content: message.content as string,
        images: images.map(img => img.replace(/^data:[^;]+;base64,/, "")),
      };
    }

    return {
      role: message.role,
      content: message.content as string,
    };
  });
}

/** Connects any server that speaks the Ollama API (Ollama itself, llmman). */
export async function connectOllama(
  { baseURL, headers }: LanguageModelSettings,
  name: string
): Promise<LanguageModelClient | undefined> {
  if (!baseURL) {
    console.warn(`${name} host not set`);
    return;
  }

  if (!isValidURL(baseURL)) return;

  const ollama = new Ollama({
    host: baseURL,
    headers,
    fetch: expoFetch as typeof fetch,
  });

  return {
    listModels: async () => {
      const response = await ollama.list();
      return { models: response.models.map((model) => model.name) };
    },
    supportsImages: async (model) => {
      const modelInfo = await ollama.show({ model });
      return modelInfo.capabilities.includes("vision");
    },
    prompt: async ({ model, messages, parameters, onUpdate, shouldStop }) => {
      const response = await ollama.chat({
        model,
        messages: parseMessages(messages),
        stream: true,
        ...parameters,
      });

      for await (const chunk of response) {
        if (shouldStop()) {
          ollama.abort();
          break;
        }

        onUpdate(chunk.message.content);
      }
    },
  };
}
