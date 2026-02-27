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
    "expo-asset",
    "expo-router",
    [
      "expo-splash-screen",
      {
        image: "./assets/images/splash.png",
        imageWidth: 200,
        resizeMode: "contain",
        backgroundColor: "#000000",
      },
    ],
    "expo-audio",
    "expo-font",
    "expo-web-browser",
    "expo-secure-store",
    "expo-localization",
    [
      "expo-build-properties",
      {
        android: {
          // You don't have ProGuard enabled right now, so this is optional.
          // Keep it commented until/if you turn minify on.
          // extraProguardRules: `
          // # llama.rn
          // -keep class com.rnllama.** { *; }
          // `,
        },
      },
    ],
    [
      "llama.rn",
      {
        enableEntitlements: true,
        entitlementsProfile: "production",
        forceCxx20: true,
        enableOpenCLAndHexagon: true
      },
    ],
    [
      "expo-speech-recognition",
      {
        microphonePermission: "Allow $(PRODUCT_NAME) to use the microphone.",
        speechRecognitionPermission: "Allow $(PRODUCT_NAME) to use speech recognition.",
        androidSpeechServicePackages: ["com.google.android.googlequicksearchbox", "com.google.android.tts"]
      }
    ]
  ],

  experiments: {
    typedRoutes: true,
  },
});
