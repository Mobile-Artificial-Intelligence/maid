import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { DaoXEContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.daoxe.com/v1";

const DaoXEContext = createContext<DaoXEContextProps | undefined>(undefined);

export function DaoXEProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("daoxe-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("daoxe-api-key");
  const [model, setModel] = useStoredString("daoxe-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("daoxe-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("daoxe-parameters");

  const [daoxe, setDaoXE] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("DaoXE API key not set");
      return;
    }

    try {
      new URL(baseURL ?? "");
    } catch {
      return;
    }

    const daoxeInstance = new OpenAI({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setDaoXE(daoxeInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!daoxe) return;

      try {
        const response = await daoxe.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching DaoXE models:", error);
      }
    };

    fetchModels();
  }, [daoxe]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!daoxe) {
      console.warn("DaoXE not initialized");
      return;
    }

    if (!model) {
      console.warn("DaoXE model not set");
      return;
    }

    setBusy(true);

    const stream = await daoxe.chat.completions.create({
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

  const resetBaseURL = () => {
    setBaseURL(DEFAULT_BASE_URL);
  };

  const value = {
    ready: !!daoxe && !!model,
    busy,
    imagesSupported: false,
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
    <DaoXEContext.Provider value={value}>
      {children}
    </DaoXEContext.Provider>
  );
}

export function useDaoXE() {
  const context = useContext(DaoXEContext);

  if (!context) {
    throw new Error("useDaoXE must be used within a DaoXEProvider");
  }

  return context;
}
