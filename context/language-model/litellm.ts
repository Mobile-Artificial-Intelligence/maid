import { fetch as expoFetch } from "expo/fetch";
import OpenAI from 'openai';
import { createOpenAIClient } from "./openai";
import { isValidURL, LanguageModelClient, LanguageModelSettings } from "./types";

// A proxy started without a master key accepts any bearer token, but the
// OpenAI client refuses an empty one.
const KEYLESS_PLACEHOLDER = "sk-no-key";

export interface LiteLLMModelInfo {
  models: Array<string>;
  vision: Record<string, boolean>;
}

// The proxy's admin routes (/model/info) live at its root, not under /v1.
export function proxyRoot(baseURL: string): string {
  return baseURL.trim().replace(/\/+$/, "").replace(/\/v1$/, "");
}

/**
 * Lists the chat models a LiteLLM proxy serves and which of them accept images.
 *
 * `/model/info` reports each deployment's mode and capabilities, so embedding,
 * image-generation and audio deployments stay out of the model picker. Keys
 * limited to specific models may not be allowed to read it; those fall back to
 * the OpenAI-compatible `/v1/models` list, without vision information.
 */
export async function discoverLiteLLMModels(
  baseURL: string,
  apiKey: string | undefined,
  headers: Record<string, string>,
  fetchImpl: typeof fetch,
): Promise<LiteLLMModelInfo> {
  const requestHeaders: Record<string, string> = { ...headers };
  if (apiKey) {
    requestHeaders.Authorization = `Bearer ${apiKey}`;
  }

  try {
    const response = await fetchImpl(`${proxyRoot(baseURL)}/model/info`, { headers: requestHeaders });
    if (response.ok) {
      const payload = await response.json() as {
        data?: Array<{
          model_name?: string | null;
          model_info?: { mode?: string | null; supports_vision?: boolean | null } | null;
        }>;
      };

      const models: Array<string> = [];
      const vision: Record<string, boolean> = {};
      for (const entry of payload.data ?? []) {
        const name = entry.model_name?.trim();
        const mode = entry.model_info?.mode?.trim().toLowerCase();
        if (!name || (mode && mode !== "chat" && mode !== "responses")) continue;
        if (!models.includes(name)) models.push(name);
        vision[name] = vision[name] || entry.model_info?.supports_vision === true;
      }

      if (models.length > 0) {
        return { models, vision };
      }
    }
  } catch (error) {
    console.warn("LiteLLM /model/info unavailable, falling back to /v1/models:", error);
  }

  const response = await fetchImpl(`${proxyRoot(baseURL)}/v1/models`, { headers: requestHeaders });
  if (!response.ok) {
    throw new Error(`LiteLLM returned ${response.status} listing models`);
  }

  const payload = await response.json() as { data?: Array<{ id?: string | null }> };
  return {
    models: (payload.data ?? []).map((model) => model.id?.trim() ?? "").filter(Boolean),
    vision: {},
  };
}

export async function connectLiteLLM(
  { baseURL, apiKey, headers }: LanguageModelSettings
): Promise<LanguageModelClient | undefined> {
  if (!isValidURL(baseURL)) return;

  const client = createOpenAIClient(new OpenAI({
    apiKey: apiKey || KEYLESS_PLACEHOLDER,
    baseURL: `${proxyRoot(baseURL)}/v1`,
    defaultHeaders: headers,
    fetch: expoFetch as typeof fetch,
  }));

  return {
    ...client,
    listModels: () => discoverLiteLLMModels(baseURL, apiKey, headers, expoFetch as typeof fetch),
  };
}
