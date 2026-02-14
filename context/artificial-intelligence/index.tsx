import { ReactNode } from "react";
import { LanguageModelProvider } from "./language-model";
import { TextToSpeechProvider } from "./text-to-speech";

export function ArtificialIntelligenceProvider({ children }: { children: ReactNode }) {
  return (
    <TextToSpeechProvider>
      <LanguageModelProvider>
        {children}
      </LanguageModelProvider>
    </TextToSpeechProvider>
  );
}

export * from "./language-model";
export { useTTS } from "./text-to-speech";