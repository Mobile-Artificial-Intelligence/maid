import { Mistral } from '@mistralai/mistralai';
import { TextChunk } from "@mistralai/mistralai/models/components";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { MessageNode } from 'message-nodes';
import { createContext, useContext, useEffect, useState } from "react";
import { MistralContextProps, ParameterTypes } from "./types";

const DEFAULT_BASE_URL = "https://api.mistral.ai";

const MistralContext = createContext<MistralContextProps | undefined>(undefined);

export function MistralProvider({ children }: { children: React.ReactNode }) {
  const [busy, setBusy] = useState<boolean>(false);

  const [baseURL, setBaseURL] = useState<string | undefined>(DEFAULT_BASE_URL);
  const [apiKey, setApiKey] = useState<string | undefined>(undefined);
  const [model, setModel] = useState<string | undefined>(undefined);

  const [parameters, setParameters] = useState<Record<string, any>>({});

  const [mistral, setMistral] = useState<Mistral | undefined>(undefined);
  const [models, setModels] = useState<Array<string>>([]);

  const saveBaseURL = async () => {
    try {
      if (baseURL) {
        await AsyncStorage.setItem("mistral-base-url", baseURL);
      } else {
        await AsyncStorage.removeItem("mistral-base-url");
      }
    } catch (error) {
      console.error("Error saving Mistral base URL:", error);
    }
  };

  const loadBaseURL = async () => {
    try {
      const storedBaseURL = await AsyncStorage.getItem("mistral-base-url");
      if (storedBaseURL) {
        setBaseURL(storedBaseURL);
      }
    } catch (error) {
      console.error("Error loading Mistral base URL:", error);
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
        await AsyncStorage.setItem("mistral-api-key", apiKey);
      } else {
        await AsyncStorage.removeItem("mistral-api-key");
      }
    } catch (error) {
      console.error("Error saving Mistral API key:", error);
    }
  };

  const loadApiKey = async () => {
    try {
      const storedApiKey = await AsyncStorage.getItem("mistral-api-key");
      if (storedApiKey) {
        setApiKey(storedApiKey);
      }
    } catch (error) {
      console.error("Error loading Mistral API key:", error);
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
        await AsyncStorage.setItem("mistral-model", model);
      } else {
        await AsyncStorage.removeItem("mistral-model");
      }
    } catch (error) {
      console.error("Error saving Mistral model:", error);
    }
  };

  const loadModel = async () => {
    try {
      const storedModel = await AsyncStorage.getItem("mistral-model");
      if (storedModel) {
        setModel(storedModel);
      }
    } catch (error) {
      console.error("Error loading Mistral model:", error);
    }
  };

  useEffect(() => {
    loadModel();
  }, []);

  useEffect(() => {
    saveModel();
  }, [model]);

  const saveParameters = async () => {
    try {
      const jsonValue = JSON.stringify(parameters);
      await AsyncStorage.setItem("mistral-parameters", jsonValue);
    } catch (error) {
      console.error("Error saving Mistral parameters:", error);
    }
  };

  const loadParameters = async () => {
    try {
      const jsonValue = await AsyncStorage.getItem("mistral-parameters");
      if (jsonValue) {
        const loadedParameters: Record<string, ParameterTypes> = JSON.parse(jsonValue);
        setParameters(loadedParameters);
      }
    } catch (error) {
      console.error("Error loading Mistral parameters:", error);
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