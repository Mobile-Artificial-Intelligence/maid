import Kokoro, { KokoroVoice, KokoroVoiceMap } from "expo-kokoro";
import { AudioSource, createAudioPlayer } from "expo-audio";
import { createContext, ReactNode, useContext, useEffect, useState } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";
import * as FileSystem from 'expo-file-system';
import { randomUUID } from "expo-crypto";

interface TextToSpeechContextProps {
  canSpeak: boolean;
  voice: KokoroVoice;
  setVoice: React.Dispatch<React.SetStateAction<KokoroVoice>>;
  textToSpeech: (text: string) => Promise<void>;
}

const TextToSpeechContext = createContext<TextToSpeechContextProps | undefined>(undefined);

export function TextToSpeechProvider({ children }: { children: ReactNode }) {
  const [speaking, setSpeaking] = useState<boolean>(false);
  const [voice, setVoice] = useState<KokoroVoice>(KokoroVoiceMap.af_heart);
  const [kokoro, setKokoro] = useState<Kokoro | undefined>(undefined);

  const saveVoice = async () => {
    try {
      await AsyncStorage.setItem("tts-voice", JSON.stringify(voice));
    } catch (error) {
      console.error("Error saving voice:", error);
    }
  };

  const loadVoice = async () => {
    try {
      const storedVoice = await AsyncStorage.getItem("tts-voice");
      if (storedVoice) {
        setVoice(JSON.parse(storedVoice));
      }
    } catch (error) {
      console.error("Error loading voice:", error);
    }
  };

  useEffect(() => {
    loadVoice();
  }, []);

  useEffect(() => {
    saveVoice();
  }, [voice]);

  useEffect(() => {
    const initTts = async () => {
      try {
        const kokoro = await Kokoro.load();
        setKokoro(kokoro);
      } 
      catch (error) {
        console.error("Error initializing speech engine:", error);
      }
    };

    initTts();
  }, []);

  const textToSpeech = async (text: string): Promise<void> => {
    setSpeaking(true);

    const player = createAudioPlayer();
    const chunks: string[] = [];

    const cleaned = text.replace(/\*/g, "").trim();

    // First split by double line breaks (paragraphs)
    const paragraphs = cleaned.split(/\n{2,}/);

    for (let i = 0; i < paragraphs.length; i++) {
      // Split into sentences
      const sentences = paragraphs[i].split(/(?<=[.!?])\s+/);

      for (let j = 0; j < sentences.length; j += 4) {
        const group = sentences
          .slice(j, j + 4)
          .map(s => s.trim())
          .filter(s => s.length > 0)
          .join(" ");
        if (group.length > 0) {
          chunks.push(group);
        }
      }
    }

    // If nothing came out, just fall back
    if (chunks.length === 0) chunks.push(text);
    const queue: Array<AudioSource> = [];

    const interval = setInterval(() => {
      if (player.playing || queue.length === 0) {
        return;
      }

      const source = queue.shift()!;
      player.replace(source);
      player.seekTo(0);
      player.play();
    }, 200);

    for (const chunk of chunks) {
      const output = `${FileSystem.cacheDirectory}${randomUUID()}.wav`;

      if (kokoro && KokoroVoiceMap[voice.id]) {
        await kokoro.generate(chunk.trim(), voice, output);
        console.log("Generated speech with Kokoro");
      } 
      else {
        throw new Error("Unsupported speech engine");
      }

      queue.push({ uri: output } as AudioSource);
    }

    do {
      await new Promise((resolve) => setTimeout(resolve, 1000));
    } 
    while (player.playing || queue.length > 0);

    clearInterval(interval);

    setSpeaking(false);
  };

  const value = {
    canSpeak: !!kokoro && !speaking,
    voice,
    setVoice,
    textToSpeech,
  };

  return (
    <TextToSpeechContext.Provider value={value}>
      {children}
    </TextToSpeechContext.Provider>
  );
}

export function useTTS() {
  const context = useContext(TextToSpeechContext);

  if (!context) {
    throw new Error("useTTS must be used within a TextToSpeechProvider");
  }

  return context;
}
