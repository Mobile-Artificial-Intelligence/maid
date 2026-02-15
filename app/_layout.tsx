
import DefaultHeader from '@/components/layout/default-header';
import DrawerContent from '@/components/layout/drawer-content';
import { ArtificialIntelligenceProvider, SystemContextProvider, useSystem } from "@/context";
import { installConsoleCapture } from '@/utilities/logger';
import { Buffer } from "buffer";
import Drawer from 'expo-router/drawer';
import { StatusBar } from "react-native";
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import "react-native-url-polyfill/auto";

(global as any).Buffer = Buffer;

installConsoleCapture();

function RootLayout() {
  return (
    <SystemContextProvider>
      <ArtificialIntelligenceProvider>
        <RootLayoutContent />
      </ArtificialIntelligenceProvider>
    </SystemContextProvider>
  );
}

function RootLayoutContent() {
  const { colorScheme } = useSystem();
  
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <StatusBar backgroundColor={colorScheme.surface} />
      <Drawer
        screenOptions={{
          header: (props: any) => <DefaultHeader {...props} />,
          drawerStyle: {
            backgroundColor: colorScheme.surface
          },
          sceneStyle: {
            backgroundColor: colorScheme.surface,
          },
          overlayColor: `${colorScheme.scrim}52`
        }}
        drawerContent={(props: any) => <DrawerContent />}
      >
        <Drawer.Screen 
          name="chat" 
          options={{ 
            headerShown: false
          }} 
        />
        <Drawer.Screen 
          name="account" 
          options={{ 
            headerShown: true 
          }} 
        />
        <Drawer.Screen 
          name="download" 
          options={{ 
            headerShown: true 
          }} 
        />
        <Drawer.Screen 
          name="settings" 
          options={{ 
            headerShown: true 
          }} 
        />
        <Drawer.Screen 
          name="about" 
          options={{ 
            headerShown: true 
          }} 
        />
      </Drawer>
    </GestureHandlerRootView>
  );
}

export default RootLayout;