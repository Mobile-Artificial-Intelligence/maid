import useStoredString from '@/hooks/use-stored-string';
import useTheme, { ThemeMode } from '@/hooks/use-theme';
import useVoice from '@/hooks/use-voice';
import { ColorScheme } from '@/utilities/color-scheme';
import { Voice } from 'expo-speech';
import React, { createContext, Dispatch, ReactNode, SetStateAction, useContext } from "react";
import 'react-native-url-polyfill/auto';

interface SystemContextProps {
  colorScheme: ColorScheme;
  userName: string | undefined;
  setUserName: (name: string | undefined) => void;
  userImage: string | undefined;
  setUserImage: (image: string | undefined) => void;
  assistantName: string | undefined;
  setAssistantName: (name: string | undefined) => void;
  assistantImage: string | undefined;
  setAssistantImage: (image: string | undefined) => void;
  systemPrompt: string | undefined;
  setSystemPrompt: (prompt: string | undefined) => void;
  voice: Voice | undefined;
  setVoice: Dispatch<SetStateAction<Voice | undefined>>;
  accentColor: string;
  setAccentColor: (color: string) => void;
  themeMode: ThemeMode;
  setThemeMode: (mode: ThemeMode) => void;
}

const SystemContext = createContext<SystemContextProps | undefined>(undefined);

export function SystemContextProvider({ children }: { children: ReactNode }) {
  const [userName, setUserName] = useStoredString("user_name", "User");
  const [userImage, setUserImage] = useStoredString("user-image");

  const [assistantName, setAssistantName] = useStoredString("assistant_name", "Assistant");
  const [assistantImage, setAssistantImage] = useStoredString("assistant-image");

  const [systemPrompt, setSystemPrompt] = useStoredString("system_prompt", "");

  const [voice, setVoice] = useVoice();
  const { colorScheme, accentColor, setAccentColor, themeMode, setThemeMode } = useTheme();
  
  const value = {
    userName,
    setUserName,
    userImage,
    setUserImage,
    assistantName,
    setAssistantName,
    assistantImage,
    setAssistantImage,
    systemPrompt,
    setSystemPrompt,
    voice,
    setVoice,
    colorScheme,
    accentColor,
    setAccentColor,
    themeMode,
    setThemeMode
  };

  return (
    <SystemContext.Provider value={value}>
      {children}
    </SystemContext.Provider>
  );
}

export function useSystem() {
  const context = useContext(SystemContext);

  if (!context) {
    throw new Error("useSystem must be used within a SystemContextProvider");
  }

  return context;
}