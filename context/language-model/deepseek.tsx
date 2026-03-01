import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { DeepSeekContextProps } from "./types";

const DeepSeekContext = createContext<DeepSeekContextProps | undefined>(undefined);

export function DeepSeekProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [apiKey, setApiKey] = useStoredString("deepseek-api-key");
  const [model, setModel] = useStoredString("deepseek-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("deepseek-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("deepseek-parameters");

  const [deepSeek, setDeepSeek] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("DeepSeek API key not set");
      return;
    }

    const deepSeekInstance = new OpenAI({
      apiKey,
      baseURL: "https://api.deepseek.com",
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setDeepSeek(deepSeekInstance);
  }, [apiKey, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!deepSeek) return;

      try {
        const response = await deepSeek.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching DeepSeek models:", error);
      }
    };

    fetchModels();
  }, [deepSeek]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!deepSeek) {
      console.warn("DeepSeek not initialized");
      return;
    }

    if (!model) {
      console.warn("DeepSeek model not set");
      return;
    }

    setBusy(true);

    const stream = await deepSeek.chat.completions.create({
      model,
      messages: messages.map((msg) => ({
        role: msg.role as "system" | "user" | "assistant",
        content: msg.content,
      })),
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
    setBusy(false);
  };

  const stop = async () => {
    stopRef.current = true;
  };

  const value = {
    ready: !!deepSeek && !!model,
    busy,
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
    <DeepSeekContext.Provider value={value}>
      {children}
    </DeepSeekContext.Provider>
  );
}

export function useDeepSeek() {
  const context = useContext(DeepSeekContext);

  if (!context) {
    throw new Error("useDeepSeek must be used within a DeepSeekProvider");
  }

  return context;
}