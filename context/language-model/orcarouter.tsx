import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { OrcaRouterContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.orcarouter.ai/v1";

const OrcaRouterContext = createContext<OrcaRouterContextProps | undefined>(undefined);

export function OrcaRouterProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("orcarouter-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("orcarouter-api-key");
  const [model, setModel] = useStoredString("orcarouter-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("orcarouter-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("orcarouter-parameters");

  const [orcarouter, setOrcarouter] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("OrcaRouter API key not set");
      return;
    }

    try {
      new URL(baseURL ?? "");
    } catch {
      return;
    }

    const orcarouterInstance = new OpenAI({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setOrcarouter(orcarouterInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!orcarouter) return;

      try {
        const response = await orcarouter.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching OrcaRouter models:", error);
      }
    };

    fetchModels();
  }, [orcarouter]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!orcarouter) {
      console.warn("OrcaRouter not initialized");
      return;
    }

    if (!model) {
      console.warn("OrcaRouter model not set");
      return;
    }

    setBusy(true);

    const stream = await orcarouter.chat.completions.create({
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
    ready: !!orcarouter && !!model,
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
    <OrcaRouterContext.Provider value={value}>
      {children}
    </OrcaRouterContext.Provider>
  );
}

export function useOrcaRouter() {
  const context = useContext(OrcaRouterContext);

  if (!context) {
    throw new Error("useOrcaRouter must be used within an OrcaRouterProvider");
  }

  return context;
}
