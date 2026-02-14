import Header from "@/components/layout/chat-header";
import { Stack } from "expo-router";

function ChatLayout() {
  return (
    <Stack
      screenOptions={{
        header: (props: any) => <Header openDrawer={props.navigation.openDrawer} />,
      }}
    >
      <Stack.Screen name="index" options={{ animation: "none" }} />
      <Stack.Screen name="[id]" options={{ animation: "none" }} />
    </Stack>
  );
}

export default ChatLayout;
