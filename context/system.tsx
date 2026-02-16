import useMappings from '@/hooks/use-mappings';
import useSyncedImage from '@/hooks/use-synced-image';
import useSyncedString from '@/hooks/use-synced-string';
import useVoice from '@/hooks/use-voice';
import { ColorScheme, createColorScheme } from '@/utilities/color-scheme';
import supabase from '@/utilities/supabase';
import type { Session } from '@supabase/supabase-js';
import { Voice } from 'expo-speech';
import { deleteNode, MessageNode } from 'message-nodes';
import React, { createContext, Dispatch, ReactNode, SetStateAction, useContext, useEffect, useMemo, useState } from "react";
import 'react-native-url-polyfill/auto';

interface SystemContextProps {
  colorScheme: ColorScheme;

  authenticated: boolean;     // has a session (anon or permanent)
  anonymous: boolean;         // specifically anonymous user

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

  voice: Voice | undefined;
  setVoice: Dispatch<SetStateAction<Voice | undefined>>;

  accentColor: string;
  setAccentColor: (color: string) => void;
}

const SystemContext = createContext<SystemContextProps | undefined>(undefined);

function getIsAnonymous(session: Session | null): boolean {
  const user = session?.user;
  if (!user) return false;

  // Newer SDKs expose `user.is_anonymous`; keep a fallback so TS/older builds don’t explode.
  const direct = (user as any).is_anonymous;
  if (typeof direct === "boolean") return direct;

  // Fallbacks (best-effort)
  const provider = (user.app_metadata as any)?.provider;
  if (provider === "anonymous") return true;

  const identities = (user as any).identities as Array<{ provider?: string }> | undefined;
  if (identities?.some((i) => i.provider === "anonymous")) return true;

  return false;
}

export function SystemContextProvider({ children }: { children: ReactNode }) {
  const [authenticated, setAuthenticated] = useState<boolean>(false);
  const [anonymous, setAnonymous] = useState<boolean>(false);

  const applySession = (session: Session | null) => {
    const hasUser = !!session?.user;
    setAuthenticated(hasUser);
    setAnonymous(getIsAnonymous(session));
  };

  const ensureSession = async () => {
    const { data, error } = await supabase.auth.getSession();
    if (error) throw error;

    if (data.session) {
      applySession(data.session);
      return;
    }

    const { data: anonData, error: anonError } = await supabase.auth.signInAnonymously();
    if (anonError) throw anonError;

    applySession(anonData.session);
  };

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
  const [voice, setVoice] = useVoice();
  const [accentColor, setAccentColor] = useState<string>("#2196F3");

  const colorScheme = useMemo(() => createColorScheme(accentColor, "dark"), [accentColor]);

  const login = async (email: string, password: string): Promise<void> => {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw new Error(error.message);

    // session listener will also handle this, but doing it here makes UI feel instant
    applySession(data.session ?? null);
  };

  const logout = async () => {
    try {
      await supabase.auth.signOut();
      applySession(null);

      // immediately go back to “guest mode”
      await ensureSession();
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

    if (error) throw new Error(error.message);
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

  useEffect(() => {
    // 1) ensure we always have a session (anon if needed)
    ensureSession().catch((e) => console.error("Auth bootstrap failed:", e));

    // 2) keep state synced if auth changes elsewhere
    const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
      applySession(session);
    });

    return () => {
      sub.subscription.unsubscribe();
    };
  }, []);

  const value: SystemContextProps = {
    colorScheme,
    authenticated,
    anonymous,

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

    voice,
    setVoice,

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
  if (!context) throw new Error("useSystem must be used within a SystemContextProvider");
  return context;
}
