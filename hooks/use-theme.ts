import { ColorScheme, createColorScheme } from "@/utilities/color-scheme";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Dispatch, SetStateAction, useEffect, useMemo, useState } from "react";

interface ThemeData {
  colorScheme: ColorScheme;
  accentColor: string;
  setAccentColor: Dispatch<SetStateAction<string>>;
}

function useTheme(): ThemeData {
  const [accentColor, setAccentColor] = useState<string>("#2196F3");
  
  const colorScheme = useMemo<ColorScheme>(
    () => createColorScheme(accentColor, "dark"),
    [accentColor]
  );
  
  const loadAccentColor = async () => {
    try {
      const storedColor = await AsyncStorage.getItem("accent_color");
      if (storedColor) {
        setAccentColor(storedColor);
      }
    } catch (error) {
      console.error("Error loading accent color from storage:", error);
    }
  };
  
  useEffect(() => {
    loadAccentColor();
  }, []);

  const saveAccentColor = async () => {
    try {
      await AsyncStorage.setItem("accent_color", accentColor);
    } catch (error) {
      console.error("Error saving accent color to storage:", error);
    }
  };
  
  useEffect(() => {
    saveAccentColor();
  }, [accentColor]);

  return {
    colorScheme,
    accentColor,
    setAccentColor,
  };
}

export default useTheme;