import AsyncStorage from "@react-native-async-storage/async-storage";
import { Dispatch, SetStateAction, useEffect, useState } from "react";

function useStoredRecord<K extends string | number | symbol = string, V = string | number | boolean>(key: string): [Record<K, V>, Dispatch<SetStateAction<Record<K, V>>>] {
  const [record, setRecord] = useState<Record<K, V>>({} as Record<K, V>);

  const saveRecord = async () => {
    try {
      const json = JSON.stringify(record);
      await AsyncStorage.setItem(key, json);
    } catch (error) {
      console.error("Error saving record: ", key, error);
    }
  };

  useEffect(() => {
    saveRecord();
  }, [record]);

  const loadRecord = async () => {
    try {
      const json = await AsyncStorage.getItem(key);
      if (json) {
        const loaded: Record<K, V> = JSON.parse(json);
        setRecord(loaded);
      }
    } catch (error) {
      console.error("Error loading record: ", key, error);
    }
  };

  useEffect(() => {
    loadRecord();
  }, []);

  return [record, setRecord];
}

export default useStoredRecord;