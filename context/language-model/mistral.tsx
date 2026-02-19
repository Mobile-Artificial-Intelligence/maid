import useStoredRecord from '@/hooks/use-stored-record';
import useStoredString from '@/hooks/use-stored-string';
import { Mistral } from '@mistralai/mistralai';
import { TextChunk } from "@mistralai/mistralai/models/components";
import { MessageNode } from 'message-nodes';
import { createContext, useContext, useEffect, useState } from "react";
import { MistralContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.mistral.ai";

const MistralContext = createContext<MistralContextProps | undefined>(undefined);

export function MistralProvider({ children }: { children: React.ReactNode }) {
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("mistral-base-url", DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useStoredString("mistral-api-key");
  const [model, setModel] = useStoredString("mistral-model");

  const [parameters, setParameters] = useStoredRecord("mistral-parameters");

  const [mistral, setMistral] = useState<Mistral | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("Mistral API key not set");
      return;
    }

    const mistralInstance = new Mistral({
      apiKey,
      serverURL: baseURL
    });

    setMistral(mistralInstance);
  }, [apiKey, baseURL]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!mistral) return;

      try {
        const response = await mistral.models.list();
        setModels(response.data?.map((model) => model.id) ?? []);
      } catch (error) {
        console.error("Error fetching Mistral models:", error);
      }
    };

    fetchModels();
  }, [mistral]);

  const promptModel = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!mistral) {
      console.warn("Mistral not initialized");
      return;
    }

    if (!model) {
      console.warn("Mistral model not set");
      return;
    }

    setBusy(true);

    const response = await mistral.chat.complete({
      model,
      messages: messages.map((msg) => ({
        role: msg.role as "system" | "user" | "assistant",
        content: msg.content,
      })),
      ...parameters,
    });

    const content = response.choices[0]?.message?.content ?? "";

    if (typeof content === "string") {
      onUpdate(content);
    } else {
      for await (const chunk of content) {
        if (chunk.type !== "text") continue;
        onUpdate((chunk as TextChunk).text);
      }
    }
    setBusy(false);
  };

  const resetBaseURL = () => {
    setBaseURL(DEFAULT_BASE_URL);
  };

  const value = {
    ready: !!mistral && !!model,
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
    promptModel
  };

  return (
    <MistralContext.Provider value={value}>
      {children}
    </MistralContext.Provider>
  );
}

export function useMistral() {
  const context = useContext(MistralContext);

  if (!context) {
    throw new Error("useMistral must be used within an OpenAIProvider");
  }

  return context;
}