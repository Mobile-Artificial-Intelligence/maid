import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useState } from "react";
import { OpenAIContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.openai.com/v1";

const OpenAIContext = createContext<OpenAIContextProps | undefined>(undefined);

export function OpenAIProvider({ children }: { children: React.ReactNode }) {
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("open-ai-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("open-ai-api-key");
  const [model, setModel] = useStoredString("open-ai-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("open-ai-headers");
  const [parameters, setParameters] = useStoredRecord("open-ai-parameters");

  const [openai, setOpenAI] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("OpenAI API key not set");
      return;
    }

    const openaiInstance = new OpenAI({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setOpenAI(openaiInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!openai) return;

      try {
        const response = await openai.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching OpenAI models:", error);
      }
    };

    fetchModels();
  }, [openai]);

  const promptModel = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!openai) {
      console.warn("OpenAI not initialized");
      return;
    }

    if (!model) {
      console.warn("OpenAI model not set");
      return;
    }

    setBusy(true);

    const stream = await openai.chat.completions.create({
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
      const chunk = event.choices[0]?.delta?.content;
      if (chunk) {
        onUpdate(chunk);
      }
    }
    setBusy(false);
  };

  const resetBaseURL = () => {
    setBaseURL(DEFAULT_BASE_URL);
  };

  const value = {
    ready: !!openai && !!model,
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
    promptModel
  };

  return (
    <OpenAIContext.Provider value={value}>
      {children}
    </OpenAIContext.Provider>
  );
}

export function useOpenAI() {
  const context = useContext(OpenAIContext);

  if (!context) {
    throw new Error("useOpenAI must be used within an OpenAIProvider");
  }

  return context;
}