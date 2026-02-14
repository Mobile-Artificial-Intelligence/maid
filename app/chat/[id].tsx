import ChatView from "@/components/views/chat-view";
import { useLocalSearchParams } from "expo-router";

function Index() {
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <ChatView id={id} />
  );
}

export default Index;
