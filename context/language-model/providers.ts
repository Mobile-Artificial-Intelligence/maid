import { connectAnthropic } from "./anthropic";
import { connectLiteLLM } from "./litellm";
import { connectLlama } from "./llama";
import { connectMistral } from "./mistral";
import { connectOllama } from "./ollama";
import { connectOpenAI } from "./openai";
import { LanguageModelDefinition, LanguageModelSetting, LanguageModelType } from "./types";

// llmman (https://github.com/llmmanorg/llmman) serves the Ollama API on port 17434.
export const LLMMAN_DEFAULT_BASE_URL = "http://localhost:17434";

const REMOTE_SETTINGS: ReadonlyArray<LanguageModelSetting> = ["baseURL", "apiKey", "model", "headers", "parameters"];
const REMOTE_CONNECTION: ReadonlyArray<LanguageModelSetting> = ["baseURL", "apiKey", "headers"];

const OLLAMA_SETTINGS: ReadonlyArray<LanguageModelSetting> = ["baseURL", "model", "headers", "parameters"];
const OLLAMA_CONNECTION: ReadonlyArray<LanguageModelSetting> = ["baseURL", "headers"];

// A provider that only differs from OpenAI by where it is hosted. A fixed base
// URL is always used and never shown in settings.
function openAICompatible(storagePrefix: string, defaultBaseURL: string, fixedBaseURL = false): LanguageModelDefinition {
  return {
    storagePrefix,
    defaultBaseURL,
    settings: fixedBaseURL ? REMOTE_SETTINGS.filter((setting) => setting !== "baseURL") : REMOTE_SETTINGS,
    connectWith: REMOTE_CONNECTION,
    connect: connectOpenAI,
  };
}

/**
 * Every selectable provider. Only the selected one has its settings loaded
 * and a client connected; the rest stay in storage until they are selected.
 */
export const LanguageModelDefinitions: Record<LanguageModelType, LanguageModelDefinition> = {
  "Llama": {
    storagePrefix: "llama",
    settings: ["modelKey", "modelFiles", "projectorKey", "projectorFiles", "parameters"],
    // Parameters configure the llama.rn context, so changing them reloads the model.
    connectWith: ["modelKey", "modelFiles", "projectorKey", "projectorFiles", "parameters"],
    connect: connectLlama,
  },
  "Ollama": {
    storagePrefix: "ollama",
    settings: OLLAMA_SETTINGS,
    connectWith: OLLAMA_CONNECTION,
    connect: connectOllama,
  },
  "llmman": {
    storagePrefix: "llmman",
    defaultBaseURL: LLMMAN_DEFAULT_BASE_URL,
    settings: OLLAMA_SETTINGS,
    connectWith: OLLAMA_CONNECTION,
    connect: connectOllama,
  },
  "Open AI": openAICompatible("open-ai", "https://api.openai.com/v1"),
  "Anthropic": {
    storagePrefix: "anthropic",
    defaultBaseURL: "https://api.anthropic.com",
    settings: REMOTE_SETTINGS,
    connectWith: REMOTE_CONNECTION,
    connect: connectAnthropic,
  },
  "Mistral": {
    storagePrefix: "mistral",
    defaultBaseURL: "https://api.mistral.ai",
    settings: ["baseURL", "apiKey", "model", "parameters"],
    connectWith: ["baseURL", "apiKey"],
    connect: connectMistral,
  },
  "DeepSeek": openAICompatible("deepseek", "https://api.deepseek.com", true),
  "DaoXE": openAICompatible("daoxe", "https://api.daoxe.com/v1"),
  "Novita": openAICompatible("novita", "https://api.novita.ai/openai", true),
  "OrcaRouter": openAICompatible("orcarouter", "https://api.orcarouter.ai/v1"),
  "AtlasCloud": openAICompatible("atlascloud", "https://api.atlascloud.ai/v1"),
  "LiteLLM": {
    storagePrefix: "litellm",
    // A LiteLLM proxy is self-hosted, so this is only a starting point; on a
    // phone it is usually the LAN address of the machine running the proxy.
    defaultBaseURL: "http://localhost:4000/v1",
    settings: REMOTE_SETTINGS,
    connectWith: REMOTE_CONNECTION,
    connect: connectLiteLLM,
  },
  "Cheaper Inference": openAICompatible("cheaperinference", "https://api.cheaperinference.com/v1"),
  "Opper": openAICompatible("opper", "https://api.opper.ai/v3/compat"),
  "API Route": openAICompatible("apiroute", "https://global.api-route.com/v1"),
  "Runcrate": openAICompatible("runcrate", "https://api.runcrate.ai/v1"),
};
