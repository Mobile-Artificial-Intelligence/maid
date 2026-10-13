import Header from "@/components/layout/chat-header";
import DrawerContent from "@/components/layout/drawer-content";
import { useSystem } from "@/context";
import Drawer, { type DrawerHeaderProps } from "expo-router/drawer";

function ChatLayout() {
  const { colorScheme } = useSystem();

  return (
    <Drawer
      screenOptions={{
        header: (props: DrawerHeaderProps) => <Header {...props} />,
        drawerStyle: {
          backgroundColor: `${colorScheme.surface}f0`
        },
        sceneStyle: {
          backgroundColor: colorScheme.surface,
        },
      }}
      drawerContent={() => <DrawerContent />}
    >
      <Drawer.Screen name="index" />
    </Drawer>
  );
}

export default ChatLayout;
