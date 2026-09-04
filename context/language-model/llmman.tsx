import { createContext, useContext } from "react";
import { OllamaProvider } from "./ollama";
import { OllamaContextProps } from "./types";

// llmman (https://github.com/llmmanorg/llmman) serves the Ollama API on port
// 17434, so it reuses OllamaProvider with its own settings and default URL.
export const LLMMAN_DEFAULT_BASE_URL = "http://localhost:17434";

const LlmmanContext = createContext<OllamaContextProps | undefined>(undefined);

export function LlmmanProvider({ children }: { children: React.ReactNode }) {
  return (
    <OllamaProvider
      context={LlmmanContext}
      storagePrefix="llmman"
      defaultBaseURL={LLMMAN_DEFAULT_BASE_URL}
    >
      {children}
    </OllamaProvider>
  );
}

export function useLlmman() {
  const context = useContext(LlmmanContext);

  if (!context) {
    throw new Error("useLlmman must be used within a LlmmanProvider");
  }

  return context;
}
