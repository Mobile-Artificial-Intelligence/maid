import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { NovitaContextProps } from "./types";

const NovitaContext = createContext<NovitaContextProps | undefined>(undefined);

export function NovitaProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [apiKey, setApiKey] = useStoredString("novita-api-key");
  const [model, setModel] = useStoredString("novita-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("novita-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("novita-parameters");

  const [novita, setNovita] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("Novita API key not set");
      return;
    }

    const novitaInstance = new OpenAI({
      apiKey,
      baseURL: "https://api.novita.ai/openai",
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setNovita(novitaInstance);
  }, [apiKey, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!novita) return;

      try {
        const response = await novita.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching Novita models:", error);
      }
    };

    fetchModels();
  }, [novita]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!novita) {
      console.warn("Novita not initialized");
      return;
    }

    if (!model) {
      console.warn("Novita model not set");
      return;
    }

    setBusy(true);

    const stream = await novita.chat.completions.create({
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
    ready: !!novita && !!model,
    busy,
    imagesSupported: false,
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
    <NovitaContext.Provider value={value}>
      {children}
    </NovitaContext.Provider>
  );
}

export function useNovita() {
  const context = useContext(NovitaContext);

  if (!context) {
    throw new Error("useNovita must be used within a NovitaProvider");
  }

  return context;
}
