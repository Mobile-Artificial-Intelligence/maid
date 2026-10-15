import { Brightness, ColorScheme, createColorScheme } from "@/utilities/color-scheme";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Dispatch, SetStateAction, useEffect, useMemo, useRef, useState } from "react";
import { useColorScheme } from "react-native";

export type ThemeMode = "system" | Brightness;

const themeModes: ThemeMode[] = ["system", "light", "dark"];

interface ThemeData {
  colorScheme: ColorScheme;
  accentColor: string;
  setAccentColor: Dispatch<SetStateAction<string>>;
  themeMode: ThemeMode;
  setThemeMode: Dispatch<SetStateAction<ThemeMode>>;
}

function useTheme(): ThemeData {
  const systemBrightness = useColorScheme();
  const [accentColor, setAccentColor] = useState<string>("#2196F3");
  const [themeMode, setThemeMode] = useState<ThemeMode>("system");
  const hydrated = useRef<boolean>(false);
  
  const brightness: Brightness = themeMode === "system"
    ? (systemBrightness === "light" ? "light" : "dark")
    : themeMode;

  const colorScheme = useMemo<ColorScheme>(
    () => createColorScheme(accentColor, brightness),
    [accentColor, brightness]
  );
  
  const loadTheme = async () => {
    try {
      const storedColor = await AsyncStorage.getItem("accent_color");
      if (storedColor) {
        setAccentColor(storedColor);
      }

      const storedMode = await AsyncStorage.getItem("theme_mode");
      if (themeModes.includes(storedMode as ThemeMode)) {
        setThemeMode(storedMode as ThemeMode);
      }
    } catch (error) {
      console.error("Error loading theme from storage:", error);
    } finally {
      hydrated.current = true;
    }
  };
  
  useEffect(() => {
    loadTheme();
  }, []);

  const saveTheme = async () => {
    try {
      await AsyncStorage.setItem("accent_color", accentColor);
      await AsyncStorage.setItem("theme_mode", themeMode);
    } catch (error) {
      console.error("Error saving theme to storage:", error);
    }
  };
  
  useEffect(() => {
    if (hydrated.current) {
      saveTheme();
    }
  }, [accentColor, themeMode]);

  return {
    colorScheme,
    accentColor,
    setAccentColor,
    themeMode,
    setThemeMode,
  };
}

export default useTheme;