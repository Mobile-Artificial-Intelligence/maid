import useSyncedImage from '@/hooks/use-synced-image';
import useSyncedString from '@/hooks/use-synced-string';
import useTheme from '@/hooks/use-theme';
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
}

const SystemContext = createContext<SystemContextProps | undefined>(undefined);

export function SystemContextProvider({ children }: { children: ReactNode }) {
  const [userName, setUserName] = useSyncedString({
    key: "user_name",
    defaultValue: "User",
  });
  const [userImage, setUserImage] = useSyncedImage({
    key: "user-image",
    bucket: "user-images"
  });

  const [assistantName, setAssistantName] = useSyncedString({
    key: "assistant_name",
    defaultValue: "Assistant",
  });
  const [assistantImage, setAssistantImage] = useSyncedImage({
    key: "assistant-image",
    bucket: "assistant-images"
  });

  const [systemPrompt, setSystemPrompt] = useSyncedString({
    key: "system_prompt",
    defaultValue: "",
  });

  const [voice, setVoice] = useVoice();
  const { colorScheme, accentColor, setAccentColor } = useTheme();
  
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
    setAccentColor
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