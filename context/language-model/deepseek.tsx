import AsyncStorage from "@react-native-async-storage/async-storage";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import OpenAI from 'openai';
import { createContext, useContext, useEffect, useState } from "react";
import { DeepSeekContextProps, ParameterTypes } from "./types";

const DeepSeekContext = createContext<DeepSeekContextProps | undefined>(undefined);

export function DeepSeekProvider({ children }: { children: React.ReactNode }) {
  const [busy, setBusy] = useState<boolean>(false);

  const [apiKey, setApiKey] = useState<string | undefined>(undefined);
  const [model, setModel] = useState<string | undefined>(undefined);

  const [headers, setHeaders] = useState<Record<string, string>>({});
  const [parameters, setParameters] = useState<Record<string, any>>({});

  const [deepSeek, setDeepSeek] = useState<OpenAI | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  const saveApiKey = async () => {
    try {
      if (apiKey) {
        await AsyncStorage.setItem("deepseek-api-key", apiKey);
      } else {
        await AsyncStorage.removeItem("deepseek-api-key");
      }
    } catch (error) {
      console.error("Error saving DeepSeek API key:", error);
    }
  };

  const loadApiKey = async () => {
    try {
      const storedApiKey = await AsyncStorage.getItem("deepseek-api-key");
      if (storedApiKey) {
        setApiKey(storedApiKey);
      }
    } catch (error) {
      console.error("Error loading DeepSeek API key:", error);
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
        await AsyncStorage.setItem("deepseek-model", model);
      } else {
        await AsyncStorage.removeItem("deepseek-model");
      }
    } catch (error) {
      console.error("Error saving DeepSeek model:", error);
    }
  };

  const loadModel = async () => {
    try {
      const storedModel = await AsyncStorage.getItem("deepseek-model");
      if (storedModel) {
        setModel(storedModel);
      }
    } catch (error) {
      console.error("Error loading DeepSeek model:", error);
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
      await AsyncStorage.setItem("deepseek-headers", jsonValue);
    } catch (error) {
      console.error("Error saving DeepSeek headers:", error);
    }
  };

  const loadHeaders = async () => {
    try {
      const jsonValue = await AsyncStorage.getItem("deepseek-headers");
      if (jsonValue) {
        const loadedHeaders: Record<string, string> = JSON.parse(jsonValue);
        setHeaders(loadedHeaders);
      }
    } catch (error) {
      console.error("Error loading DeepSeek headers:", error);
    }
  };

  useEffect(() => {
    loadHeaders();
  }, []);

  useEffect(() => {
    saveHeaders();
  }, [headers]);

  const saveParameters = async () => {
    try {
      const jsonValue = JSON.stringify(parameters);
      await AsyncStorage.setItem("deepseek-parameters", jsonValue);
    } catch (error) {
      console.error("Error saving DeepSeek parameters:", error);
    }
  };

  const loadParameters = async () => {
    try {
      const jsonValue = await AsyncStorage.getItem("deepseek-parameters");
      if (jsonValue) {
        const loadedParameters: Record<string, ParameterTypes> = JSON.parse(jsonValue);
        setParameters(loadedParameters);
      }
    } catch (error) {
      console.error("Error loading DeepSeek parameters:", error);
    }
  };

  useEffect(() => {
    loadParameters();
  }, []);

  useEffect(() => {
    saveParameters();
  }, [parameters]);

  useEffect(() => {
    if (!apiKey) {
      console.warn("DeepSeek API key not set");
      return;
    }

    const deepSeekInstance = new OpenAI({
      apiKey,
      baseURL: "https://api.deepseek.com",
      defaultHeaders: headers,
      fetch: expoFetch as typeof fetch,
    });

    setDeepSeek(deepSeekInstance);
  }, [apiKey, headers]);

  useEffect(() => {
    const fetchModels = async () => {
      if (!deepSeek) return;

      try {
        const response = await deepSeek.models.list();
        setModels(response.data.map((model) => model.id));
      } catch (error) {
        console.error("Error fetching DeepSeek models:", error);
      }
    };

    fetchModels();
  }, [deepSeek]);

  const promptModel = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!deepSeek) {
      console.warn("DeepSeek not initialized");
      return;
    }

    if (!model) {
      console.warn("DeepSeek model not set");
      return;
    }

    setBusy(true);

    const stream = await deepSeek.chat.completions.create({
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

  const value = {
    ready: !!deepSeek && !!model,
    busy,
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
    <DeepSeekContext.Provider value={value}>
      {children}
    </DeepSeekContext.Provider>
  );
}

export function useDeepSeek() {
  const context = useContext(DeepSeekContext);

  if (!context) {
    throw new Error("useDeepSeek must be used within a DeepSeekProvider");
  }

  return context;
}