import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { CheaperInferenceContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.cheaperinference.com/v1";

const CheaperInferenceContext = createContext<CheaperInferenceContextProps | undefined>(undefined);

export function CheaperInferenceProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("cheaperinference-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("cheaperinference-api-key");
  const [model, setModel] = useStoredString("cheaperinference-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("cheaperinference-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("cheaperinference-parameters");

  const [cheaperInference, setCheaperInference] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("Cheaper Inference API key not set");
      return;
    }

    try {
      new URL(baseURL ?? "");
    } catch {
      return;
    }

    const cheaperInferenceInstance = new OpenAI({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setCheaperInference(cheaperInferenceInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!cheaperInference) return;

      try {
        const response = await cheaperInference.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching Cheaper Inference models:", error);
      }
    };

    fetchModels();
  }, [cheaperInference]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!cheaperInference) {
      console.warn("Cheaper Inference not initialized");
      return;
    }

    if (!model) {
      console.warn("Cheaper Inference model not set");
      return;
    }

    setBusy(true);

    const stream = await cheaperInference.chat.completions.create({
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
    ready: !!cheaperInference && !!model,
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
    <CheaperInferenceContext.Provider value={value}>
      {children}
    </CheaperInferenceContext.Provider>
  );
}

export function useCheaperInference() {
  const context = useContext(CheaperInferenceContext);

  if (!context) {
    throw new Error("useCheaperInference must be used within a CheaperInferenceProvider");
  }

  return context;
}
