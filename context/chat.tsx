import useMappings from "@/hooks/use-mappings";
import useStoredString from "@/hooks/use-stored-string";
import getSupabase from "@/utilities/supabase";
import { deleteNode, MessageNode } from "message-nodes";
import { createContext, Dispatch, ReactNode, SetStateAction, useContext, useState } from "react";

interface ChatContextProps {
  editing: string | undefined;
  setEditing: Dispatch<SetStateAction<string | undefined>>;
  root: string | undefined;
  setRoot: Dispatch<SetStateAction<string | undefined>>;
  mappings: Record<string, MessageNode<string>>;
  setMappings: Dispatch<SetStateAction<Record<string, MessageNode<string>>>>;
  deleteMessage: (id: string) => void;
}

const ChatContext = createContext<ChatContextProps | undefined>(undefined);

export function ChatContextProvider({ children }: { children: ReactNode }) {
  const [root, setRoot] = useStoredString("root-message-id");
  const [editing, setEditing] = useState<string | undefined>(undefined);
  const [mappings, setMappings] = useMappings();

  const deleteMessage = async (id: string) => {
    setMappings((prev) => deleteNode(prev, id));
    
    const { error } = await getSupabase()
      .from("messages")
      .delete()
      .eq("id", id);

    if (error) {
      console.error("Error deleting message:", error);
    }
  };

  const value = {
    editing,
    setEditing,
    root,
    setRoot,
    mappings,
    setMappings,
    deleteMessage,
  };

  return (
    <ChatContext.Provider value={value}>
      {children}
    </ChatContext.Provider>
  );
}

export function useChat() {
  const context = useContext(ChatContext);

  if (!context) {
    throw new Error("useChat must be used within a ChatContextProvider");
  }

  return context;
}