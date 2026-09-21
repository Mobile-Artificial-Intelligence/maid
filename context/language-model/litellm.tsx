import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { LiteLLMContextProps } from "./types";

// A LiteLLM proxy is self-hosted, so this is only a starting point; on a phone
// it is usually the LAN address of the machine running the proxy.
const DEFAULT_BASE_URL = "http://localhost:4000/v1";

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

// Attached images travel as OpenAI image_url parts; LiteLLM translates them
// into each provider's own format (Anthropic, Gemini, Bedrock, ...).
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

const LiteLLMContext = createContext<LiteLLMContextProps | undefined>(undefined);

export function LiteLLMProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("litellm-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("litellm-api-key");
  const [model, setModel] = useStoredString("litellm-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("litellm-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("litellm-parameters");

  const [litellm, setLiteLLM] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);
  const [vision, setVision] = useState<Record<string, boolean>>({});

  useEffect(() => {
    try {
      new URL(baseURL ?? "");
    } catch {
      return;
    }

    try {
      const litellmInstance = new OpenAI({
        apiKey: apiKey || KEYLESS_PLACEHOLDER,
        baseURL: `${proxyRoot(baseURL!)}/v1`,
        defaultHeaders: headers,
        fetch: expoFetch as typeof fetch,
      });
      setLiteLLM(litellmInstance);
    } catch (error) {
      console.warn("Failed to create LiteLLM instance:", error);
    }
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!litellm || !baseURL) return;

      try {
        const info = await discoverLiteLLMModels(baseURL, apiKey, headers, expoFetch as typeof fetch);
        setModels(info.models);
        setVision(info.vision);
      } catch (error) {
        console.error("Error fetching LiteLLM models:", error);
      }
    };

    fetchModels();
  }, [litellm]);

  const imagesSupported = !!model && vision[model] === true;

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!litellm) {
      console.warn("LiteLLM not initialized");
      return;
    }

    if (!model) {
      console.warn("LiteLLM model not set");
      return;
    }

    setBusy(true);

    try {
      const stream = await litellm.chat.completions.create({
        model,
        messages: toChatMessages(messages, imagesSupported),
        stream: true,
        ...parameters,
      }, {
        maxRetries: 3,
      });

      for await (const event of stream) {
        if (stopRef.current) {
          stream.controller.abort();
          stopRef.current = false;
          break;
        }

        const chunk = event.choices[0]?.delta?.content;
        if (chunk) {
          onUpdate(chunk);
        }
      }
    } finally {
      setBusy(false);
    }
  };

  const stop = async () => {
    stopRef.current = true;
  };

  const resetBaseURL = () => {
    setBaseURL(DEFAULT_BASE_URL);
  };

  const value = {
    ready: !!litellm && !!model,
    busy,
    imagesSupported,
    baseURL,
    setBaseURL,
    resetBaseURL,
    apiKey,
    setApiKey,
    model,
    setModel,
    models,
    parameters,
    setParameters,
    headers,
    setHeaders,
    prompt,
    stop
  };

  return (
    <LiteLLMContext.Provider value={value}>
      {children}
    </LiteLLMContext.Provider>
  );
}

export function useLiteLLM() {
  const context = useContext(LiteLLMContext);

  if (!context) {
    throw new Error("useLiteLLM must be used within a LiteLLMProvider");
  }

  return context;
}
