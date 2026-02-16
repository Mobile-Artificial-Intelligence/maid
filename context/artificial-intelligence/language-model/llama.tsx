import AsyncStorage from '@react-native-async-storage/async-storage';
import { getDocumentAsync } from "expo-document-picker";
import * as FileSystem from 'expo-file-system';
import { initLlama, LlamaContext as LlamaRnContext, loadLlamaModelInfo } from 'llama.rn';
import { MessageNode } from 'message-nodes';
import { createContext, ReactNode, useContext, useEffect, useRef, useState } from "react";
import { LlamaContextProps, ParameterTypes } from "./types";

async function isGGUF(fileUri: string): Promise<boolean> {
  try {
    // Read first 4 bytes as base64, then decode to bytes
    const b64 = await FileSystem.readAsStringAsync(fileUri, {
      encoding: FileSystem.EncodingType.Base64,
      length: 4,
      position: 0,
    });

    // atob is available in RN; if not, use a small base64 decoder util
    const bin = globalThis.atob ? globalThis.atob(b64) : Buffer.from(b64, "base64").toString("binary");
    if (bin.length < 4) return false;

    const b0 = bin.charCodeAt(0) & 0xff;
    const b1 = bin.charCodeAt(1) & 0xff;
    const b2 = bin.charCodeAt(2) & 0xff;
    const b3 = bin.charCodeAt(3) & 0xff;

    return b0 === 0x47 && b1 === 0x47 && b2 === 0x55 && b3 === 0x46;
  } catch {
    return false;
  }
}

async function cleanupLocalModelFiles(modelFiles: Record<string, string>) {
  const updated = { ...modelFiles };
  const locals = Object.keys(updated).filter((key) => key.endsWith("(local)"));

  for (const localKey of locals) {
    try {
      await FileSystem.deleteAsync(updated[localKey]);
    } catch (error) {
      console.error("Error deleting old model file:", error);
    } 
    delete updated[localKey];
  }

  return updated;
}

const LlamaContext = createContext<LlamaContextProps | undefined>(undefined);

export function LlamaProvider({ children }: { children: ReactNode }) {
  const loadIdRef = useRef<number>(0);
  const [ready, setReady] = useState<boolean>(false);
  const [prompting, setPrompting] = useState<boolean>(false);
  const [loading, setLoading] = useState<boolean>(false);

  const [modelFiles, setModelFiles] = useState<Record<string, string>>({});

  const [modelFileKey, setModelFileKey] = useState<string | undefined>(undefined);
  const [parameters, setParameters] = useState<Record<string, ParameterTypes>>({});

  const [llama, setLlama] = useState<LlamaRnContext | undefined>(undefined);

  const saveModelFiles = async () => {
    if (!modelFileKey) return;

    try {
      await AsyncStorage.setItem("llama-model-file-key", modelFileKey);
      const jsonValue = JSON.stringify(modelFiles);
      await AsyncStorage.setItem("llama-model-files", jsonValue);
    } catch (error) {
      console.error("Error saving model file:", error);
    }
  };

  const loadModelFiles = async () => {
    try {
      const storedKey = await AsyncStorage.getItem("llama-model-file-key");
      if (storedKey) {
        setModelFileKey(storedKey);
      }

      const jsonValue = await AsyncStorage.getItem("llama-model-files");
      if (jsonValue) {
        const loadedModelFiles: Record<string, string> = JSON.parse(jsonValue);
        setModelFiles(loadedModelFiles);
      }
    } catch (error) {
      console.error("Error loading model file:", error);
    }
  };

  useEffect(() => {
    if (modelFileKey) {
      saveModelFiles();
    }
    else {
      loadModelFiles();
    }
  }, [modelFileKey, modelFiles]);

  const saveParameters = async () => {
    try {
      const jsonValue = JSON.stringify(parameters);
      await AsyncStorage.setItem("llama-parameters", jsonValue);
    } catch (error) {
      console.error("Error saving parameters:", error);
    }
  };

  const loadParameters = async () => {
    try {
      const jsonValue = await AsyncStorage.getItem("llama-parameters");
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

  useEffect(() => {
    saveParameters();
  }, [parameters]);

  useEffect(() => {
    if (llama && !prompting && !loading) {
      setReady(true);
    }
    else {
      setReady(false);
    }
  }, [llama, prompting, loading]);

  useEffect(() => {
    let cancelled = false;
    let timeout: ReturnType<typeof setTimeout> | null = null;

    const loadModel = async () => {
      if (!modelFileKey || !modelFiles[modelFileKey]) {
        return;
      }

      const modelFile = modelFiles[modelFileKey];

      // Ensure the selected file is a GGUF model before proceeding
      const isGguf = await isGGUF(modelFile);
      if (!isGguf) {
        return;
      }

      const currentLoadId = ++loadIdRef.current;

      timeout = setTimeout(async () => {
        if (loading) return;

        setLoading(true);

        try {
          const info = await loadLlamaModelInfo(modelFile) as Record<string, any>;
          const ctx_key = Object.keys(info).find(key => key.toLowerCase().endsWith("context_length"));
          const n_ctx = ctx_key ? Number(info[ctx_key]) : 2048;

          const llamaContext = await initLlama({
            model: modelFile,
            use_mlock: true,
            n_ctx,
            n_gpu_layers: 99,
            ...parameters,
          });

          // if a newer load started, ignore this one
          if (cancelled || currentLoadId !== loadIdRef.current) {
            await llamaContext.release?.(); // optional cleanup if API supports
            return;
          }

          setLlama(llamaContext);
        } catch (error) {
          console.error("Error initializing model:", error);
        } finally {
          if (!cancelled) {
            setLoading(false);
          }
        }
      }, 400);
    };

    loadModel();

    return () => {
      cancelled = true;
      if (timeout !== null) {
        clearTimeout(timeout);
      }
    };
  }, [modelFileKey, modelFiles, parameters]);

  const pickModelFile = async () => {
    const file = await getDocumentAsync({
      multiple: false,
    });
    if (file.assets === null) return;
    const asset = file.assets[0];

    if (!/\.gguf$/i.test(asset.uri) || !isGGUF(asset.uri)) {
      alert("Please select a valid GGUF model file");
      return;
    }

    const name = `${asset.name.replace(/\.[^/.]+$/, "")} (local)`;
    const newPath = FileSystem.documentDirectory + asset.name;

    await FileSystem.moveAsync({
      from: asset.uri,
      to: newPath,
    });

    const updatedModelFiles = await cleanupLocalModelFiles(modelFiles);

    setModelFiles({ ...updatedModelFiles, [name]: newPath });
    setModelFileKey(name);
  };

  const promptModel = async (
    messages: Array<MessageNode>, 
    onUpdate: (message: string) => void
  ) => {
    if (!llama) {
      console.warn("LLM not initialized");
      return;
    }

    if (prompting) {
      console.warn("Prompt already in progress");
      return;
    }

    setPrompting(true);

    try {
      const result = await llama.completion({
        messages: messages
      }, (data) => onUpdate(data.token));
    
      console.log('Timings:', result.timings);
    } 
    catch (error) {
      console.error("Error prompting model:", error);
    }

    setPrompting(false);
  };

  const value = {
    ready,
    busy: prompting || loading,
    modelFileKey,
    pickModelFile,
    setModelFileKey,
    modelFiles,
    setModelFiles,
    parameters,
    setParameters,
    promptModel,
  };

  return (
    <LlamaContext.Provider value={value}>
      {children}
    </LlamaContext.Provider>
  );
}

export function useLlama() {
  const context = useContext(LlamaContext);

  if (!context) {
    throw new Error("useLlama must be used within an LlamaProvider");
  }

  return context;
}