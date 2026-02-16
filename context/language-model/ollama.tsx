import AsyncStorage from "@react-native-async-storage/async-storage";
import { fetch as expoFetch } from "expo/fetch";
import { MessageNode } from "message-nodes";
import { Ollama } from "ollama/browser";
import { createContext, useContext, useEffect, useState } from "react";
import { OllamaContextProps, ParameterTypes } from "./types";

const OllamaContext = createContext<OllamaContextProps | undefined>(undefined);

export function OllamaProvider({ children }: { children: React.ReactNode }) {
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useState<string | undefined>(undefined);
  const [headers, setHeaders] = useState<Record<string, string>>({});

  const [model, setModel] = useState<string | undefined>(undefined);
  const [parameters, setParameters] = useState<Record<string, any>>({});

  const [ollama, setOllama] = useState<Ollama | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  const saveBaseURL = async () => {
    try {
      if (baseURL) {
        await AsyncStorage.setItem("ollama-base-url", baseURL);
      } else {
        await AsyncStorage.removeItem("ollama-base-url");
      }
    } catch (error) {
      console.error("Error saving Ollama base URL:", error);
    }
  };

  const loadBaseURL = async () => {
    try {
      const storedBaseURL = await AsyncStorage.getItem("ollama-base-url");
      if (storedBaseURL) {
        setBaseURL(storedBaseURL);
      }
    } catch (error) {
      console.error("Error loading Ollama base URL:", error);
    }
  };

  useEffect(() => {
    loadBaseURL();
  }, []);

  useEffect(() => {
    saveBaseURL();
  }, [baseURL]);

  const saveModel = async () => {
    try {
      if (model) {
        await AsyncStorage.setItem("ollama-model", model);
      } else {
        await AsyncStorage.removeItem("ollama-model");
      }
    } catch (error) {
      console.error("Error saving Ollama model:", error);
    }
  };

  const loadModel = async () => {
    try {
      const storedModel = await AsyncStorage.getItem("ollama-model");
      if (storedModel) {
        setModel(storedModel);
      }
    } catch (error) {
      console.error("Error loading Ollama model:", error);
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
      await AsyncStorage.setItem("ollama-headers", jsonValue);
    } catch (error) {
      console.error("Error saving Ollama headers:", error);
    }
  };

  const loadHeaders = async () => {
    try {
      const jsonValue = await AsyncStorage.getItem("ollama-headers");
      if (jsonValue) {
        const loadedHeaders: Record<string, string> = JSON.parse(jsonValue);
        setHeaders(loadedHeaders);
      }
    } catch (error) {
      console.error("Error loading Ollama headers:", error);
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
      await AsyncStorage.setItem("ollama-parameters", jsonValue);
    } catch (error) {
      console.error("Error saving Ollama parameters:", error);
    }
  };

  const loadParameters = async () => {
    try {
      const jsonValue = await AsyncStorage.getItem("ollama-parameters");
      if (jsonValue) {
        const loadedParameters: Record<string, ParameterTypes> = JSON.parse(jsonValue);
        setParameters(loadedParameters);
      }
    } catch (error) {
      console.error("Error loading Ollama parameters:", error);
    }
  };

  useEffect(() => {
    loadParameters();
  }, []);

  useEffect(() => {
    saveParameters();
  }, [parameters]);

  useEffect(() => {
    if (!baseURL) {
      console.warn("Ollama host not set");
      return;
    }

    const ollamaInstance = new Ollama({
      host: baseURL,
      headers,
      fetch: expoFetch as typeof fetch,
    });

    setOllama(ollamaInstance);
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

  const promptModel = async (
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
    busy: busy,
    baseURL,
    setBaseURL,
    headers,
    setHeaders,
    model, 
    setModel,  
    parameters, 
    setParameters,
    promptModel,
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