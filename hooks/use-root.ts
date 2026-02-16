import AsyncStorage from '@react-native-async-storage/async-storage';
import { Dispatch, SetStateAction, useEffect, useState } from "react";

function useRoot(): [string | undefined,  Dispatch<SetStateAction<string | undefined>>] {
  const [root, setRoot] = useState<string | undefined>(undefined);

  const loadRoot = async () => {
    try {
      const storedRoot = await AsyncStorage.getItem("root");
      if (storedRoot) {
        setRoot(storedRoot);
      }
    } catch (error) {
      console.error("Error loading root from storage:", error);
    }
  };

  useEffect(() => {
    loadRoot();
  }, []);

  const saveRoot = async () => {
    try {
      if (root) {
        await AsyncStorage.setItem("root", root);
      } 
      else {
        await AsyncStorage.removeItem("root");
      }
    } catch (error) {
      console.error("Error saving root to storage:", error);
    }
  };

  useEffect(() => {
    saveRoot();
  }, [root]);

  return [root, setRoot];
}

export default useRoot;