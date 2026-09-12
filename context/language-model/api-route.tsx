import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { ApiRouteContextProps } from "./types";

const DEFAULT_BASE_URL = "https://global.api-route.com/v1";

const ApiRouteContext = createContext<ApiRouteContextProps | undefined>(undefined);

export function ApiRouteProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("apiroute-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("apiroute-api-key");
  const [model, setModel] = useStoredString("apiroute-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("apiroute-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("apiroute-parameters");

  const [apiRoute, setApiRoute] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("API Route API key not set");
      return;
    }

    try {
      new URL(baseURL ?? "");
    } catch {
      return;
    }

    const apiRouteInstance = new OpenAI({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setApiRoute(apiRouteInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!apiRoute) return;

      try {
        const response = await apiRoute.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching API Route models:", error);
      }
    };

    fetchModels();
  }, [apiRoute]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!apiRoute) {
      console.warn("API Route not initialized");
      return;
    }

    if (!model) {
      console.warn("API Route model not set");
      return;
    }

    setBusy(true);

    const stream = await apiRoute.chat.completions.create({
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
    ready: !!apiRoute && !!model,
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
    <ApiRouteContext.Provider value={value}>
      {children}
    </ApiRouteContext.Provider>
  );
}

export function useApiRoute() {
  const context = useContext(ApiRouteContext);

  if (!context) {
    throw new Error("useApiRoute must be used within an ApiRouteProvider");
  }

  return context;
}
