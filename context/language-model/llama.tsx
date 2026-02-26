import useStoredRecord from '@/hooks/use-stored-record';
import useStoredString from '@/hooks/use-stored-string';
import { getDocumentAsync } from "expo-document-picker";
import * as FileSystem from 'expo-file-system';
import { initLlama, LlamaContext as LlamaRnContext, loadLlamaModelInfo } from 'llama.rn';
import { MessageNode } from 'message-nodes';
import { createContext, ReactNode, useContext, useEffect, useRef, useState } from "react";
import { LlamaContextProps } from "./types";

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
  const [busy, setBusy] = useState<boolean>(false);

  const [modelFiles, setModelFiles] = useStoredRecord<string, string>("llama-model-files");
  const [modelFileKey, setModelFileKey] = useStoredString("llama-model-file-key");

  const [parameters, setParameters] = useStoredRecord("llama-parameters");

  const [llama, setLlama] = useState<LlamaRnContext | undefined>(undefined);

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
        if (busy) return;

        setBusy(true);

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
            setBusy(false);
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

    if (!/\.gguf$/i.test(asset.uri) || !(await isGGUF(asset.uri))) {
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

  const prompt = async (
    messages: Array<MessageNode>, 
    onUpdate: (message: string) => void
  ) => {
    if (!llama) {
      console.warn("LLM not initialized");
      return;
    }

    if (busy) {
      console.warn("Prompt already in progress");
      return;
    }

    setBusy(true);

    try {
      const result = await llama.completion({
        messages: messages
      }, (data) => onUpdate(data.token));
    
      console.log('Timings:', result.timings);
    } 
    catch (error) {
      console.error("Error prompting model:", error);
    }

    setBusy(false);
  };

  const value = {
    ready: !!llama,
    busy,
    modelFileKey,
    pickModelFile,
    setModelFileKey,
    modelFiles,
    setModelFiles,
    parameters,
    setParameters,
    prompt,
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