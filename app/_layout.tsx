
import DefaultHeader from '@/components/layout/default-header';
import { ChatContextProvider, LanguageModelProvider, SystemContextProvider, useSystem } from "@/context";
import { installConsoleCapture } from '@/utilities/logger';
import { NativeStackHeaderProps } from "@react-navigation/native-stack";
import { Buffer } from "buffer";
import { Stack } from "expo-router";
import { StatusBar } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import "react-native-url-polyfill/auto";

(global as any).Buffer = Buffer;

installConsoleCapture();

function RootLayout() {
  return (
    <SystemContextProvider>
      <LanguageModelProvider>
        <ChatContextProvider>
          <RootLayoutContent />
        </ChatContextProvider>
      </LanguageModelProvider>
    </SystemContextProvider>
  );
}

function RootLayoutContent() {
  const { colorScheme } = useSystem();
  
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <StatusBar backgroundColor={colorScheme.surface} />
      <Stack
        screenOptions={{
          header: (props: NativeStackHeaderProps) => <DefaultHeader {...props} />,
          contentStyle: {
            backgroundColor: colorScheme.surface,
          },
        }}
      >
        <Stack.Screen 
          name="chat" 
          options={{ 
            headerShown: false
          }} 
        />
        <Stack.Screen 
          name="account" 
          options={{ 
            headerShown: true 
          }} 
        />
        <Stack.Screen 
          name="download" 
          options={{ 
            headerShown: true 
          }} 
        />
        <Stack.Screen 
          name="settings" 
          options={{ 
            headerShown: true 
          }} 
        />
        <Stack.Screen 
          name="about" 
          options={{ 
            headerShown: true 
          }} 
        />
      </Stack>
    </GestureHandlerRootView>
  );
}

export default RootLayout;