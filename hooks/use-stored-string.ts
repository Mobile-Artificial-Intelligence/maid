import AsyncStorage from '@react-native-async-storage/async-storage';
import { Dispatch, SetStateAction, useEffect, useRef, useState } from "react";

function useStoredString(key: string, initial?: string): [string | undefined,  Dispatch<SetStateAction<string | undefined>>] {
  const [value, setValue] = useState<string | undefined>(initial);
  const hydrated = useRef<boolean>(false);

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
    if (hydrated.current) {
      saveValue();
    }
  }, [value]);

  const loadValue = async () => {
    try {
      const storedValue = await AsyncStorage.getItem(key);
      if (storedValue) {
        setValue(storedValue);
      }
    } catch (error) {
      console.error(`Error loading ${key} from storage:`, error);
    } finally {
      hydrated.current = true;
    }
  };

  useEffect(() => {
    loadValue();
  }, []);

  return [value, setValue];
}

export default useStoredString;