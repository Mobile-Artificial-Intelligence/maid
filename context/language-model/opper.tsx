import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { OpperContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.opper.ai/v3/compat";

const OpperContext = createContext<OpperContextProps | undefined>(undefined);

export function OpperProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("opper-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("opper-api-key");
  const [model, setModel] = useStoredString("opper-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("opper-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("opper-parameters");

  const [opper, setOpper] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("Opper API key not set");
      return;
    }

    try {
      new URL(baseURL ?? "");
    } catch {
      return;
    }

    const opperInstance = new OpenAI({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setOpper(opperInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!opper) return;

      try {
        const response = await opper.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching Opper models:", error);
      }
    };

    fetchModels();
  }, [opper]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!opper) {
      console.warn("Opper not initialized");
      return;
    }

    if (!model) {
      console.warn("Opper model not set");
      return;
    }

    setBusy(true);

    const stream = await opper.chat.completions.create({
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
    ready: !!opper && !!model,
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
    <OpperContext.Provider value={value}>
      {children}
    </OpperContext.Provider>
  );
}

export function useOpper() {
  const context = useContext(OpperContext);

  if (!context) {
    throw new Error("useOpper must be used within an OpperProvider");
  }

  return context;
}
