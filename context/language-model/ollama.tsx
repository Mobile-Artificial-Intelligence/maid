import useStoredRecord from "@/hooks/use-stored-record";
import useStoredString from "@/hooks/use-stored-string";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import { Ollama } from "ollama/browser";
import { createContext, useContext, useEffect, useState } from "react";
import { OllamaContextProps } from "./types";

const OllamaContext = createContext<OllamaContextProps | undefined>(undefined);

export function OllamaProvider({ children }: { children: React.ReactNode }) {
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useStoredString("ollama-base-url");
  const [model, setModel] = useStoredString("ollama-model");

  const [headers, setHeaders] = useStoredRecord<string, string>("ollama-headers");
  const [parameters, setParameters] = useStoredRecord("ollama-parameters");

  const [ollama, setOllama] = useState<Ollama | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);
  
  useEffect(() => {
    if (!baseURL) {
      console.warn("Ollama host not set");
      return;
    }

    try {
      new URL(baseURL);
    } catch {
      return;
    }

    try {
      const ollamaInstance = new Ollama({
        host: baseURL,
        headers,
        fetch: expoFetch as typeof fetch,
      });
      setOllama(ollamaInstance);
    } catch (error) {
      console.warn("Failed to create Ollama instance:", error);
    }
  }, [baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!ollama) return;

      try {
        const models = await ollama.list();
        setModels(models.models.map((model) => model.name));
      } catch (error) {
        console.error("Error fetching Ollama models:", error);
      }
    };

    fetchModels();
  }, [ollama]);

  const prompt = async (
    messages: Array<MessageNode>, 
    onUpdate: (message: string) => void
  ) => {
    if (!ollama) {
      console.warn("Ollama instance not ready");
      return;
    }

    if (!model) {
      console.warn("Ollama model not set");
      return;
    }
    setBusy(true);

    const response = await ollama.chat({
      model,
      messages,
      stream: true,
      ...parameters,
    });

    for await (const chunk of response) {
      onUpdate(chunk.message.content);
    }
    setBusy(false);
  };

  const value = { 
    ready: !!ollama && !!model,
    busy,
    baseURL,
    setBaseURL,
    headers,
    setHeaders,
    model, 
    setModel,  
    parameters, 
    setParameters,
    prompt,
    models
  };

  return (
    <OllamaContext.Provider value={value}>
      {children}
    </OllamaContext.Provider>
  );
}

export function useOllama() {
  const context = useContext(OllamaContext);

  if (!context) {
    throw new Error("useOllama must be used within a OllamaProvider");
  }

  return context;
}