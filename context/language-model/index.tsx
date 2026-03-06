import AsyncStorage from "@react-native-async-storage/async-storage";
import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { AnthropicProvider, useAnthropic } from "./anthropic";
import { DeepSeekProvider, useDeepSeek } from "./deepseek";
import { LlamaProvider, useLlama } from "./llama";
import { MistralProvider, useMistral } from "./mistral";
import { NovitaProvider, useNovita } from "./novita";
import { OllamaProvider, useOllama } from "./ollama";
import { OpenAIProvider, useOpenAI } from "./open-ai";
import { LanguageModelContextProps, LanguageModelProps, LanguageModelType, LanguageModelTypes } from "./types";

const LanguageModelContext = createContext<LanguageModelContextProps | undefined>(undefined);

function LanguageModelManagementProvider({ children }: { children: React.ReactNode }) {
  const llama = useLlama();
  const ollama = useOllama();
  const openAI = useOpenAI();
  const anthropic = useAnthropic();
  const mistral = useMistral();
  const deepSeek = useDeepSeek();
  const novita = useNovita();
  const [type, setType] = useState<LanguageModelType>("Llama");

  const loadType = async () => {
    try {
      const storedType = await AsyncStorage.getItem("language-model-type");
      if (storedType) {
        setType(storedType as LanguageModelType);
      }
    } catch (error) {
      console.error("Error loading language model type:", error);
    }
  };

  const saveType = async () => {
    try {
      if (LanguageModelTypes.includes(type)) {
        await AsyncStorage.setItem("language-model-type", type);
      } else {
        await AsyncStorage.removeItem("language-model-type");
      }
    } catch (error) {
      console.error("Error saving language model type:", error);
    }
  };

  useEffect(() => {
    loadType();
  }, []);

  useEffect(() => {
    saveType();
  }, [type]);

  const getProps = (): LanguageModelProps => {
    switch (type) {
      case "Llama":
        return llama;
      case "Ollama":
        return ollama;
      case "Open AI":
        return openAI;
      case "Anthropic":
        return anthropic;
      case "Mistral":
        return mistral;
      case "DeepSeek":
        return deepSeek;
      case "Novita":
        return novita;
      default:
        throw new Error(`Unsupported model type: ${type}`);
    }
  };

  const values = useMemo<LanguageModelContextProps>(() => ({
    type,
    setType,
    ...getProps(),
  }), [type, llama, ollama, openAI, anthropic, mistral, deepSeek, novita]);

  return (
    <LanguageModelContext.Provider value={values}>
      {children}
    </LanguageModelContext.Provider>
  );
}

export function LanguageModelProvider({ children }: { children: React.ReactNode }) {
  return (
    <LlamaProvider>
      <OllamaProvider>
        <OpenAIProvider>
          <AnthropicProvider>
            <MistralProvider>
              <DeepSeekProvider>
                <NovitaProvider>
                  <LanguageModelManagementProvider>
                    {children}
                  </LanguageModelManagementProvider>
                </NovitaProvider>
              </DeepSeekProvider>
            </MistralProvider>
          </AnthropicProvider>
        </OpenAIProvider>
      </OllamaProvider>
    </LlamaProvider>
  );
}

export function useLLM() {
  const context = useContext(LanguageModelContext);

  if (!context) {
    throw new Error("useLLM must be used within a LanguageModelProvider");
  }

  return context;
}

export { LanguageModelTypes } from "./types";
