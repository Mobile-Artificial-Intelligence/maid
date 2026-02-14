import useMappings from '@/hooks/use-mappings';
import useSyncedImage from '@/hooks/use-synced-image';
import useSyncedString from '@/hooks/use-synced-string';
import { ColorScheme, createColorScheme } from '@/utilities/color-scheme';
import supabase from '@/utilities/supabase';
import { deleteNode, MessageNode } from 'message-nodes';
import React, { createContext, Dispatch, ReactNode, SetStateAction, useContext, useEffect, useState } from "react";
import 'react-native-url-polyfill/auto';

interface SystemContextProps {
  colorScheme: ColorScheme;
  authenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  register: (email: string, password: string) => Promise<void>;
  deleteMessage: (id: string) => void;
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
  editing: string | undefined;
  setEditing: Dispatch<SetStateAction<string | undefined>>;
  mappings: Record<string, MessageNode<string>>;
  setMappings: Dispatch<SetStateAction<Record<string, MessageNode<string>>>>;
  accentColor: string;
  setAccentColor: (color: string) => void;
}

const SystemContext = createContext<SystemContextProps | undefined>(undefined);

export function SystemContextProvider({ children }: { children: ReactNode }) {
  const [authenticated, setAuthenticated] = useState<boolean>(false);

  const [userName, setUserName] = useSyncedString(authenticated, {
    key: "user_name",
    defaultValue: "User",
  });
  const [userImage, setUserImage] = useSyncedImage(authenticated, {
    key: "user-image",
    bucket: "user-images"
  });

  const [assistantName, setAssistantName] = useSyncedString(authenticated, {
    key: "assistant_name",
    defaultValue: "Assistant",
  });
  const [assistantImage, setAssistantImage] = useSyncedImage(authenticated, {
    key: "assistant-image",
    bucket: "assistant-images"
  });

  const [systemPrompt, setSystemPrompt] = useSyncedString(authenticated, {
    key: "system_prompt",
    defaultValue: "",
  });

  const [editing, setEditing] = useState<string | undefined>(undefined);
  const [mappings, setMappings] = useMappings(authenticated);

  const [accentColor, setAccentColor] = useState<string>("#2196F3");

  const colorScheme = createColorScheme(accentColor, "dark");

  const login = async (email: string, password: string): Promise<void> => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setAuthenticated(false);
      throw new Error(error.message);
    }

    if (!data?.user) {
      setAuthenticated(false);
      throw new Error("Unexpected response from Supabase.");
    }

    setAuthenticated(true);
    return;
  };

  const logout = async () => {
    try {
      await supabase.auth.signOut();
      setAuthenticated(false);
    } catch (error) {
      console.error("Error during logout:", error);
    }
  };

  const register = async (email: string, password: string): Promise<void> => {
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { user_name: userName } },
    });

    if (error) {
      throw new Error(error.message);
    }

    return;
  };

  const deleteMessage = async (id: string) => {
    setMappings((prev) => deleteNode(prev, id));
    
    const { error } = await supabase
      .from("messages")
      .delete()
      .eq("id", id);

    if (error) {
      console.error("Error deleting message:", error);
    }
  };

  const checkAuthentication = async () => {
    const session = await supabase.auth.getSession();
    setAuthenticated(!!session.data.session);
  };

  useEffect(() => {
    checkAuthentication();
  }, []);

  const value = {
    colorScheme,
    authenticated,
    login,
    logout,
    register,
    deleteMessage,
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
    editing,
    setEditing,
    mappings,
    setMappings,
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