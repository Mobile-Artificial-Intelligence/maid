import AsyncStorage from '@react-native-async-storage/async-storage';
import { Voice } from "expo-speech";
import { Dispatch, SetStateAction, useEffect, useRef, useState } from "react";

function useVoice(): [Voice | undefined, Dispatch<SetStateAction<Voice | undefined>>] {
  const [voice, setVoice] = useState<Voice | undefined>(undefined);
  const hydrated = useRef<boolean>(false);

  const loadVoice = async () => {
    try {
      const voiceJson = await AsyncStorage.getItem("voice");
      if (voiceJson) {
        setVoice(JSON.parse(voiceJson));
      }
    } catch (error) {
      console.error("Error loading voice from storage:", error);
    } finally {
      hydrated.current = true;
    }
  };

  useEffect(() => {
    loadVoice();
  }, []);

  const saveVoice = async () => {
    try {
      if (voice) {
        await AsyncStorage.setItem("voice", JSON.stringify(voice));
      } else {
        await AsyncStorage.removeItem("voice");
      }
    } catch (error) {
      console.error("Error saving voice to storage:", error);
    }
  };

  useEffect(() => {
    if (hydrated.current) {
      saveVoice();
    }
  }, [voice]);

  return [voice, setVoice];
}

export default useVoice;