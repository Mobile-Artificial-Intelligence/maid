import useParameters from "@/hooks/use-parameters";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useState } from "react";
import { OpenAIContextProps } from "./types";

const DEFAULT_BASE_URL = "https://api.openai.com/v1";

const OpenAIContext = createContext<OpenAIContextProps | undefined>(undefined);

export function OpenAIProvider({ children }: { children: React.ReactNode }) {
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useState<string | undefined>(DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useState<string | undefined>(undefined);
  const [model, setModel] = useState<string | undefined>(undefined);

  const [headers, setHeaders] = useState<Record<string, string>>({});
  const [parameters, setParameters] = useParameters("open-ai-parameters");

  const [openai, setOpenAI] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  const saveBaseURL = async () => {
    try {
      if (baseURL) {
        await AsyncStorage.setItem("open-ai-base-url", baseURL);
      } else {
        await AsyncStorage.removeItem("open-ai-base-url");
      }
    } catch (error) {
      console.error("Error saving OpenAI base URL:", error);
    }
  };

  const loadBaseURL = async () => {
    try {
      const storedBaseURL = await AsyncStorage.getItem("open-ai-base-url");
      if (storedBaseURL) {
        setBaseURL(storedBaseURL);
      }
    } catch (error) {
      console.error("Error loading OpenAI base URL:", error);
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
        await AsyncStorage.setItem("open-ai-api-key", apiKey);
      } else {
        await AsyncStorage.removeItem("open-ai-api-key");
      }
    } catch (error) {
      console.error("Error saving OpenAI API key:", error);
    }
  };

  const loadApiKey = async () => {
    try {
      const storedApiKey = await AsyncStorage.getItem("open-ai-api-key");
      if (storedApiKey) {
        setApiKey(storedApiKey);
      }
    } catch (error) {
      console.error("Error loading OpenAI API key:", error);
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
        await AsyncStorage.setItem("open-ai-model", model);
      } else {
        await AsyncStorage.removeItem("open-ai-model");
      }
    } catch (error) {
      console.error("Error saving OpenAI model:", error);
    }
  };

  const loadModel = async () => {
    try {
      const storedModel = await AsyncStorage.getItem("open-ai-model");
      if (storedModel) {
        setModel(storedModel);
      }
    } catch (error) {
      console.error("Error loading OpenAI model:", error);
    }
  };

  useEffect(() => {
    loadModel();
  }, []);

  useEffect(() => {
    saveModel();
  }, [model]);

  const saveHeaders = async () => {
    try {
      const jsonValue = JSON.stringify(headers);
      await AsyncStorage.setItem("open-ai-headers", jsonValue);
    } catch (error) {
      console.error("Error saving OpenAI headers:", error);
    }
  };

  const loadHeaders = async () => {
    try {
      const jsonValue = await AsyncStorage.getItem("open-ai-headers");
      if (jsonValue) {
        const loadedHeaders: Record<string, string> = JSON.parse(jsonValue);
        setHeaders(loadedHeaders);
      }
    } catch (error) {
      console.error("Error loading OpenAI headers:", error);
    }
  };

  useEffect(() => {
    loadHeaders();
  }, []);

  useEffect(() => {
    saveHeaders();
  }, [headers]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("OpenAI API key not set");
      return;
    }

    const openaiInstance = new OpenAI({
      apiKey,
      baseURL,
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setOpenAI(openaiInstance);
  }, [apiKey, baseURL, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!openai) return;

      try {
        const response = await openai.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching OpenAI models:", error);
      }
    };

    fetchModels();
  }, [openai]);

  const promptModel = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!openai) {
      console.warn("OpenAI not initialized");
      return;
    }

    if (!model) {
      console.warn("OpenAI model not set");
      return;
    }

    setBusy(true);

    const stream = await openai.chat.completions.create({
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
      const chunk = event.choices[0]?.delta?.content;
      if (chunk) {
        onUpdate(chunk);
      }
    }
    setBusy(false);
  };

  const resetBaseURL = () => {
    setBaseURL(DEFAULT_BASE_URL);
  };

  const value = {
    ready: !!openai && !!model,
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
    <OpenAIContext.Provider value={value}>
      {children}
    </OpenAIContext.Provider>
  );
}

export function useOpenAI() {
  const context = useContext(OpenAIContext);

  if (!context) {
    throw new Error("useOpenAI must be used within an OpenAIProvider");
  }

  return context;
}