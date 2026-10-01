import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { AtlasCloudContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.atlascloud.ai/v1";

const AtlasCloudContext = createContext<AtlasCloudContextProps | undefined>(undefined);

export function AtlasCloudProvider({ children }: { children: React.ReactNode }) {
  const stopRef = useRef<boolean>(false);
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("atlascloud-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("atlascloud-api-key");
  const [model, setModel] = useStoredString("atlascloud-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("atlascloud-headers");
  const [parameters, setParameters] = useStoredRecord<string, string | number | boolean>("atlascloud-parameters");

  const [atlascloud, setAtlascloud] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("AtlasCloud API key not set");
      return;
    }

    try {
      new URL(baseURL ?? "");
    } catch {
      return;
    }

    const atlascloudInstance = new OpenAI({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setAtlascloud(atlascloudInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!atlascloud) return;

      try {
        const response = await atlascloud.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching AtlasCloud models:", error);
      }
    };

    fetchModels();
  }, [atlascloud]);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!atlascloud) {
      console.warn("AtlasCloud not initialized");
      return;
    }

    if (!model) {
      console.warn("AtlasCloud model not set");
      return;
    }

    setBusy(true);

    const stream = await atlascloud.chat.completions.create({
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
    ready: !!atlascloud && !!model,
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
    <AtlasCloudContext.Provider value={value}>
      {children}
    </AtlasCloudContext.Provider>
  );
}

export function useAtlasCloud() {
  const context = useContext(AtlasCloudContext);

  if (!context) {
    throw new Error("useAtlasCloud must be used within an AtlasCloudProvider");
  }

  return context;
}
