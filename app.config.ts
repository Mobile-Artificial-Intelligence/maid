// app.config.ts
import type { ExpoConfig } from "expo/config";

export default ({ config }: { config: ExpoConfig }): ExpoConfig => ({
  ...config,
  name: "maid",
  slug: "maid",
  orientation: "portrait",
  icon: "./assets/images/icon.png",
  scheme: "maid",
  userInterfaceStyle: "automatic",
  newArchEnabled: true,

  ios: {
    supportsTablet: true,
    bundleIdentifier: "com.danemadsen.maid",
  },

  android: {
    adaptiveIcon: {
      foregroundImage: "./assets/images/adaptive-icon.png",
      backgroundColor: "#000000",
    },
    package: "com.danemadsen.maid",
    permissions: [
      "android.permission.RECORD_AUDIO",
      "android.permission.MODIFY_AUDIO_SETTINGS",
    ],
  },

  web: {
    bundler: "metro",
    output: "static",
    favicon: "./assets/images/favicon.png",
  },

  plugins: [
    "expo-router",
    [
      "expo-splash-screen",
      {
        image: "./assets/images/adaptive-icon.png",
        imageWidth: 200,
        resizeMode: "contain",
        backgroundColor: "#000000",
      },
    ],
    "expo-audio",
    "expo-font",
    "expo-web-browser",
    "expo-secure-store",
  ],

  experiments: {
    typedRoutes: true,
  },
});
