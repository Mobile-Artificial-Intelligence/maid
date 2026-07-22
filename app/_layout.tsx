
import DefaultHeader from '@/components/layout/default-header';
import { ChatContextProvider, LanguageModelProvider, SystemContextProvider, useSystem } from "@/context";
import { installConsoleCapture } from '@/utilities/logger';
import { Buffer } from "buffer";
import { Stack, type NativeStackHeaderProps } from "expo-router";
import { StatusBar } from 'expo-status-bar';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { KeyboardProvider } from 'react-native-keyboard-controller';
import { SafeAreaProvider } from 'react-native-safe-area-context';
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
      <SafeAreaProvider>
        <KeyboardProvider>
          {/* Edge-to-edge is mandatory on Android 15+, so the status bar has no
              background of its own - only the icon colour is ours to set. */}
          <StatusBar style={colorScheme.brightness === "dark" ? "light" : "dark"} />
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
        </KeyboardProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

export default RootLayout;