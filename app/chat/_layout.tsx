import Header from "@/components/layout/chat-header";
import DrawerContent from "@/components/layout/drawer-content";
import { useSystem } from "@/context";
import { DrawerHeaderProps } from "@react-navigation/drawer";
import Drawer from "expo-router/drawer";

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
      drawerContent={(props: any) => <DrawerContent />}
    >
      <Drawer.Screen name="index" />
    </Drawer>
  );
}

export default ChatLayout;
