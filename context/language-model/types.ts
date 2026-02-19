import { MessageNode } from "message-nodes";

export const LanguageModelTypes = [
  "Llama",
  "Ollama",
  "Open AI",
  "Anthropic",
  "Mistral",
  "DeepSeek",
] as const;

export type LanguageModelType = typeof LanguageModelTypes[number];

interface LanguageModelBaseProps {
  ready: boolean;
  busy: boolean;
  parameters: Record<string, string | number | boolean>;
  setParameters: React.Dispatch<React.SetStateAction<Record<string, string | number | boolean>>>;
  prompt: (
    messages: Array<MessageNode>, 
    onUpdate: (message: string) => void
  ) => Promise<void | undefined>;
}

interface ModelMixin {
  model: string | undefined;
  setModel: React.Dispatch<React.SetStateAction<string | undefined>>;
  models: Array<string>;
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
  modelFileKey: string | undefined;
  pickModelFile: () => Promise<void>;
  setModelFileKey: React.Dispatch<React.SetStateAction<string | undefined>>;
  modelFiles: Record<string, string>;
  setModelFiles: React.Dispatch<React.SetStateAction<Record<string, string>>>;
}

export type LlamaContextProps = LanguageModelBaseProps & ModelFilesMixin;

export type OllamaContextProps = LanguageModelBaseProps & ModelMixin & BaseUrlMixin & HeadersMixin;

export type OpenAIContextProps = LanguageModelBaseProps & ModelMixin & BaseUrlMixin & HeadersMixin & ApiKeyMixin;

export type DeepSeekContextProps = LanguageModelBaseProps & ModelMixin & HeadersMixin & ApiKeyMixin;

export type AnthropicContextProps = LanguageModelBaseProps & ModelMixin & BaseUrlMixin & HeadersMixin & ApiKeyMixin;

export type MistralContextProps = LanguageModelBaseProps & ModelMixin & BaseUrlMixin & ApiKeyMixin;

export type LanguageModelProps = 
| LlamaContextProps 
| OllamaContextProps 
| OpenAIContextProps 
| AnthropicContextProps 
| MistralContextProps 
| DeepSeekContextProps;

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