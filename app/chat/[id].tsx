import ChatView from "@/components/views/chat-view";
import { useSystem } from "@/context";
import { useLocalSearchParams } from "expo-router";
import { useEffect } from "react";

function Index() {
  const { setRoot } = useSystem();
  const { id } = useLocalSearchParams<{ id: string }>();

  useEffect(() => {
    setRoot(id);
  }, [id]);

  return (
    <ChatView />
  );
}

export default Index;
