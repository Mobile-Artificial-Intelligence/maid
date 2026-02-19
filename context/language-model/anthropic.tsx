import useStoredRecord from '@/hooks/use-stored-record';
import Anthropic from '@anthropic-ai/sdk';
import AsyncStorage from "@react-native-async-storage/async-storage";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import { createContext, useContext, useEffect, useState } from "react";
import { AnthropicContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.anthropic.com";

const AnthropicContext = createContext<AnthropicContextProps | undefined>(undefined);

export function AnthropicProvider({ children }: { children: React.ReactNode }) {
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useState<string | undefined>(DEFAULT_BASE_URL);
  const [headers, setHeaders] = useStoredRecord<string, string>("anthropic-headers");

  const [apiKey, setApiKey] = useState<string | undefined>(undefined);
  const [model, setModel] = useState<string | undefined>(undefined);
  const [parameters, setParameters] = useStoredRecord("anthropic-parameters");

  const [anthropic, setAnthropic] = useState<Anthropic | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  const saveBaseURL = async () => {
    try {
      if (baseURL) {
        await AsyncStorage.setItem("anthropic-base-url", baseURL);
      } else {
        await AsyncStorage.removeItem("anthropic-base-url");
      }
    } catch (error) {
      console.error("Error saving Anthropic base URL:", error);
    }
  };

  const loadBaseURL = async () => {
    try {
      const storedBaseURL = await AsyncStorage.getItem("anthropic-base-url");
      if (storedBaseURL) {
        setBaseURL(storedBaseURL);
      }
    } catch (error) {
      console.error("Error loading Anthropic base URL:", error);
    }
  };

  useEffect(() => {
    loadBaseURL();
  }, []);

  useEffect(() => {
    saveBaseURL();
  }, [baseURL]);

  const saveApiKey = async () => {
    try {
      if (apiKey) {
        await AsyncStorage.setItem("anthropic-api-key", apiKey);
      } else {
        await AsyncStorage.removeItem("anthropic-api-key");
      }
    } catch (error) {
      console.error("Error saving Anthropic API key:", error);
    }
  };

  const loadApiKey = async () => {
    try {
      const storedApiKey = await AsyncStorage.getItem("anthropic-api-key");
      if (storedApiKey) {
        setApiKey(storedApiKey);
      }
    } catch (error) {
      console.error("Error loading Anthropic API key:", error);
    }
  };

  useEffect(() => {
    loadApiKey();
  }, []);

  useEffect(() => {
    saveApiKey();
  }, [apiKey]);

  const saveModel = async () => {
    try {
      if (model) {
        await AsyncStorage.setItem("anthropic-model", model);
      } else {
        await AsyncStorage.removeItem("anthropic-model");
      }
    } catch (error) {
      console.error("Error saving Anthropic model:", error);
    }
  };

  const loadModel = async () => {
    try {
      const storedModel = await AsyncStorage.getItem("anthropic-model");
      if (storedModel) {
        setModel(storedModel);
      }
    } catch (error) {
      console.error("Error loading Anthropic model:", error);
    }
  };

  useEffect(() => {
    loadModel();
  }, []);

  useEffect(() => {
    saveModel();
  }, [model]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("Anthropic API key not set");
      return;
    }

    const anthropicInstance = new Anthropic({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setAnthropic(anthropicInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!anthropic) return;

      try {
        const response = await anthropic.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching Anthropic models:", error);
      }
    };

    fetchModels();
  }, [anthropic]);

  const promptModel = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!anthropic) {
      console.warn("Anthropic not initialized");
      return;
    }

    if (!model) {
      console.warn("Anthropic model not set");
      return;
    }

    if (busy) {
      console.warn("Prompt already in progress");
      return;
    }

    setBusy(true);

    try {
      await anthropic.messages.stream({
        model,
        max_tokens: 1024,
        stream: true,
        messages: messages.map((msg) => ({
          role: msg.role as "user" | "assistant",
          content: msg.content,
        })),
      }).on("text", (text) => {
        onUpdate(text);
      });
    } 
    catch (error) {
      console.error("Error prompting model:", error);
    }

    setBusy(false);
  };

  const resetBaseURL = () => {
    setBaseURL(DEFAULT_BASE_URL);
  };

  const value = {
    ready: !!anthropic && !!model,
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
    <AnthropicContext.Provider value={value}>
      {children}
    </AnthropicContext.Provider>
  );
}

export function useAnthropic() {
  const context = useContext(AnthropicContext);

  if (!context) {
    throw new Error("useAnthropic must be used within an AnthropicProvider");
  }

  return context;
}
