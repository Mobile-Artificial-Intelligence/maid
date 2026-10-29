import { MessageNode } from "message-nodes";

export const LanguageModelTypes = [
  "Llama",
  "Ollama",
  "llmman",
  "Open AI",
  "Anthropic",
  "Mistral",
  "DeepSeek",
  "DaoXE",
  "Novita",
  "OrcaRouter",
  "AtlasCloud",
  "LiteLLM",
  "Cheaper Inference",
  "Opper",
  "API Route",
  "Runcrate",
] as const;

export type LanguageModelType = typeof LanguageModelTypes[number];

export type ModelParameters = Record<string, string | number | boolean>;

/** Everything a provider can persist; each provider declares the subset it uses. */
export interface LanguageModelSettings {
  baseURL?: string;
  apiKey?: string;
  model?: string;
  headers: Record<string, string>;
  parameters: ModelParameters;
  modelKey?: string;
  modelFiles: Record<string, string>;
  projectorKey?: string;
  projectorFiles: Record<string, string>;
}

export type LanguageModelSetting = keyof LanguageModelSettings;

export interface PromptRequest {
  model: string;
  messages: Array<MessageNode>;
  parameters: ModelParameters;
  imagesSupported: boolean;
  onUpdate: (message: string) => void;
  shouldStop: () => boolean;
}

export interface ModelList {
  models: Array<string>;
  /** Which models accept images, when the server reports it. */
  vision?: Record<string, boolean>;
}

/** A connection to one provider, built from that provider's settings. */
export interface LanguageModelClient {
  /** Set when image support is known for the whole connection (e.g. a local model with a projector). */
  imagesSupported?: boolean;
  listModels?: () => Promise<ModelList>;
  supportsImages?: (model: string) => Promise<boolean>;
  prompt: (request: PromptRequest) => Promise<void>;
  stop?: () => Promise<void>;
  /** Frees whatever the client holds outside the JS heap (e.g. a loaded model). */
  release?: () => Promise<void>;
}

export interface LanguageModelDefinition {
  /** Settings are stored as `<storagePrefix>-<setting>`, e.g. `open-ai-api-key`. */
  storagePrefix: string;
  defaultBaseURL?: string;
  /** The settings this provider stores and exposes for editing. */
  settings: ReadonlyArray<LanguageModelSetting>;
  /** The settings the client is built from; changing one rebuilds it. */
  connectWith: ReadonlyArray<LanguageModelSetting>;
  connect: (settings: LanguageModelSettings, name: string) => Promise<LanguageModelClient | undefined>;
}

export function isValidURL(url: string | undefined): url is string {
  try {
    new URL(url ?? "");
    return true;
  } catch {
    return false;
  }
}

interface LanguageModelBaseProps {
  ready: boolean;
  busy: boolean;
  imagesSupported: boolean;
  parameters: ModelParameters;
  setParameters: React.Dispatch<React.SetStateAction<ModelParameters>>;
  prompt: (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => Promise<void>;
  stop: () => Promise<void>
}

interface ModelMixin {
  models: Array<string>;
  model: string | undefined;
  setModel: React.Dispatch<React.SetStateAction<string | undefined>>;
}

interface HeadersMixin {
  headers: Record<string, string>;
  setHeaders: React.Dispatch<React.SetStateAction<Record<string, string>>>;
}

interface BaseUrlMixin {
  baseURL: string | undefined;
  setBaseURL: React.Dispatch<React.SetStateAction<string | undefined>>;
  resetBaseURL?: () => void;
}

interface ApiKeyMixin {
  apiKey: string | undefined;
  setApiKey: React.Dispatch<React.SetStateAction<string | undefined>>;
}

interface ModelFilesMixin {
  pickModelFile: () => Promise<void>;
  modelKey: string | undefined;
  setModelKey: React.Dispatch<React.SetStateAction<string | undefined>>;
  modelFiles: Record<string, string>;
  setModelFiles: React.Dispatch<React.SetStateAction<Record<string, string>>>;
  pickProjectorFile: () => Promise<void>;
  projectorKey: string | undefined;
  setProjectorKey: React.Dispatch<React.SetStateAction<string | undefined>>;
  projectorFiles: Record<string, string>;
  setProjectorFiles: React.Dispatch<React.SetStateAction<Record<string, string>>>;
}

export type LanguageModelContextProps =
& LanguageModelBaseProps
& Partial<ModelFilesMixin>
& Partial<ModelMixin>
& Partial<BaseUrlMixin>
& Partial<ApiKeyMixin>
& Partial<HeadersMixin>
& {
  type: LanguageModelType;
  setType: React.Dispatch<React.SetStateAction<LanguageModelType>>;
}
