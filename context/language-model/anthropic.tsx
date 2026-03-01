import useStoredRecord from '@/hooks/use-stored-record';
import useStoredString from '@/hooks/use-stored-string';
import Anthropic from '@anthropic-ai/sdk';
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { AnthropicContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.anthropic.com";

const AnthropicContext = createContext<AnthropicContextProps | undefined>(undefined);

export function AnthropicProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("anthropic-base-url", DEFAULT_BASE_URL);
  const [headers, setHeaders] = useStoredRecord<string, string>("anthropic-headers");

  const [apiKey, setApiKey] = useStoredString("anthropic-api-key");
  const [model, setModel] = useStoredString("anthropic-model");
  const [parameters, setParameters] = useStoredRecord("anthropic-parameters");

  const [anthropic, setAnthropic] = useState<Anthropic | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("Anthropic API key not set");
      return;
    }

    try {
      new URL(baseURL ?? "");
    } catch {
      return;
    }

    try {
      const anthropicInstance = new Anthropic({
        apiKey,
        baseURL,
        defaultHeaders: headers,
        fetch: expoFetch as typeof fetch,
      });
      setAnthropic(anthropicInstance);
    } catch (error) {
      console.warn("Failed to create Anthropic instance:", error);
    }
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!anthropic) return;

      try {
        const response = await anthropic.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching Anthropic models:", error);
      }
    };

    fetchModels();
  }, [anthropic]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!anthropic) {
      console.warn("Anthropic not initialized");
      return;
    }

    if (!model) {
      console.warn("Anthropic model not set");
      return;
    }

    if (busy) {
      console.warn("Prompt already in progress");
      return;
    }

    setBusy(true);

    try {
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
        if (stopRef.current) {
          stream.abort();
          stopRef.current = false;
          break;
        }

        if (chunk.type === 'content_block_delta' && chunk.delta.type === 'text_delta') {
          onUpdate(chunk.delta.text);
        }
      }
    } 
    catch (error) {
      console.error("Error prompting model:", error);
    }

    setBusy(false);
  };

  const stop = async () => {
    stopRef.current = true;
  };

  const resetBaseURL = () => {
    setBaseURL(DEFAULT_BASE_URL);
  };

  const value = {
    ready: !!anthropic && !!model,
    busy,
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
    <AnthropicContext.Provider value={value}>
      {children}
    </AnthropicContext.Provider>
  );
}

export function useAnthropic() {
  const context = useContext(AnthropicContext);

  if (!context) {
    throw new Error("useAnthropic must be used within an AnthropicProvider");
  }

  return context;
}
