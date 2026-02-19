import AsyncStorage from "@react-native-async-storage/async-storage";
import { Dispatch, SetStateAction, useEffect, useState } from "react";

export type ParameterTypes = string | number | boolean;

function useParameters(key: string): [Record<string, ParameterTypes>, Dispatch<SetStateAction<Record<string, ParameterTypes>>>] {
  const [parameters, setParameters] = useState<Record<string, ParameterTypes>>({});

  const saveParameters = async () => {
    try {
      const jsonValue = JSON.stringify(parameters);
      await AsyncStorage.setItem(key, jsonValue);
    } catch (error) {
      console.error("Error saving parameters:", error);
    }
  };

  useEffect(() => {
    saveParameters();
  }, [parameters]);

  const loadParameters = async () => {
    try {
      const jsonValue = await AsyncStorage.getItem(key);
      if (jsonValue) {
        const loadedParameters: Record<string, ParameterTypes> = JSON.parse(jsonValue);
        setParameters(loadedParameters);
      }
    } catch (error) {
      console.error("Error loading parameters:", error);
    }
  };

  useEffect(() => {
    loadParameters();
  }, []);

  return [parameters, setParameters];
}

export default useParameters;