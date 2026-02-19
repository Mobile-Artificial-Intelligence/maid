import AsyncStorage from '@react-native-async-storage/async-storage';
import { Dispatch, SetStateAction, useEffect, useState } from "react";

function useStoredString(key: string, initial?: string): [string | undefined,  Dispatch<SetStateAction<string | undefined>>] {
  const [value, setValue] = useState<string | undefined>(initial);

  const loadValue = async () => {
    try {
      const storedValue = await AsyncStorage.getItem(key);
      if (storedValue) {
        setValue(storedValue);
      }
    } catch (error) {
      console.error(`Error loading ${key} from storage:`, error);
    }
  };

  useEffect(() => {
    loadValue();
  }, []);

  const saveValue = async () => {
    try {
      if (value) {
        await AsyncStorage.setItem(key, value);
      } 
      else {
        await AsyncStorage.removeItem(key);
      }
    } catch (error) {
      console.error(`Error saving ${key} to storage:`, error);
    }
  };

  useEffect(() => {
    saveValue();
  }, [value]);

  return [value, setValue];
}

export default useStoredString;