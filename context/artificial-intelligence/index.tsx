import { ReactNode } from "react";
import { LanguageModelProvider } from "./language-model";

export function ArtificialIntelligenceProvider({ children }: { children: ReactNode }) {
  return (
    <LanguageModelProvider>
      {children}
    </LanguageModelProvider>
  );
}

export * from "./language-model";
