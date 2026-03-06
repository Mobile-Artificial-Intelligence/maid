import useStateRef from '@/hooks/use-state-ref';
import useStoredRecord from '@/hooks/use-stored-record';
import useStoredString from '@/hooks/use-stored-string';
import { getDocumentAsync } from "expo-document-picker";
import * as FileSystem from 'expo-file-system';
import { initLlama, LlamaContext as LlamaRnContext, loadLlamaModelInfo, RNLlamaOAICompatibleMessage } from 'llama.rn';
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
};

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
};

function parseMessages(messages: Array<MessageNode>): Array<RNLlamaOAICompatibleMessage> {
  return messages.map((message) => {
    const images: Array<string> | undefined = (message.metadata as any)?.images;

    if (images && images.length > 0) {
      return {
        role: message.role,
        content: [
          { type: "text", text: message.content as string },
          ...images.map((uri) => ({
            type: "image_url" as const,
            image_url: { url: uri },
          })),
        ],
      } as RNLlamaOAICompatibleMessage;
    }

    return message as unknown as RNLlamaOAICompatibleMessage;
  });
}

const LlamaContext = createContext<LlamaContextProps | undefined>(undefined);

export function LlamaProvider({ children }: { children: ReactNode }) {
  const loadIdRef = useRef<number>(0);
  const [busy, setBusy] = useState<boolean>(false);
  const [imagesSupported, setImagesSupported] = useState<boolean>(false);

  const [modelKey, setModelKey] = useStoredString("llama-model-file-key");
  const [modelFiles, setModelFiles] = useStoredRecord<string, string>("llama-model-files");

  const [projectorKey, setProjectorKey] = useStoredString("llama-projector-file-key");
  const [projectorFiles, setProjectorFiles] = useStoredRecord<string, string>("llama-projector-files");

  const [parameters, setParameters] = useStoredRecord("llama-parameters");

  const [llama, llamaRef, setLlama] = useStateRef<LlamaRnContext | undefined>(undefined);

  useEffect(() => {
    let cancelled = false;
    let timeout: ReturnType<typeof setTimeout> | null = null;

    const loadModel = async () => {
      if (!modelKey || !modelFiles[modelKey]) {
        return;
      }

      const modelFile = modelFiles[modelKey];

      // Ensure the selected file is a GGUF model before proceeding
      const isGguf = await isGGUF(modelFile);
      if (!isGguf) {
        return;
      }

      const currentLoadId = ++loadIdRef.current;

      timeout = setTimeout(async () => {
        while (busy) {
          await new Promise((resolve) => setTimeout(resolve, 1000));
          if (cancelled || currentLoadId !== loadIdRef.current) {
            return;
          }
        }

        setBusy(true);

        try {
          // Release the previous context before loading a new one
          const oldContext = llamaRef.current;
          setLlama(undefined);
          await oldContext?.release();

          const info = await loadLlamaModelInfo(modelFile) as Record<string, any>;
          const ctx_key = Object.keys(info).find(key => key.toLowerCase().endsWith("context_length"));
          const n_ctx = ctx_key ? Number(info[ctx_key]) : 2048;

          const useProjector =
            projectorKey &&
            projectorFiles[projectorKey] &&
            (
              projectorKey === modelKey ||
              modelKey.endsWith("(local)")
            );

          const llamaContext = await initLlama({
            model: modelFile,
            use_mlock: true,
            n_ctx,
            n_gpu_layers: 99,
            ...parameters,
            ctx_shift: !useProjector
          });

          if (useProjector) {
            await llamaContext.initMultimodal({
              path: projectorFiles[projectorKey],
              use_gpu: true
            });
          }

          // if a newer load started, ignore this one
          if (cancelled || currentLoadId !== loadIdRef.current) {
            await llamaContext.release();
            return;
          }

          setLlama(llamaContext);

          if (useProjector) {
            const support = await llamaContext.getMultimodalSupport();
            //console.log("Audio support: ", support.audio);
            setImagesSupported(support.vision);
          }
          else {
            setImagesSupported(false);
          }
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
  }, [modelKey, modelFiles, projectorKey, projectorFiles, parameters]);

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
    setModelKey(name);
  };

  const pickProjectorFile = async () => {
    const file = await getDocumentAsync({
      multiple: false,
    });
    if (file.assets === null) return;
    const asset = file.assets[0];

    if (!/\.mmproj$/i.test(asset.uri) && !/\.gguf$/i.test(asset.uri)) {
      alert("Please select a multimodel projector file");
      return;
    }

    const name = `${asset.name.replace(/\.[^/.]+$/, "")} (local)`;
    const newPath = FileSystem.documentDirectory + asset.name;

    await FileSystem.moveAsync({
      from: asset.uri,
      to: newPath,
    });

    const updatedProjectorFiles = await cleanupLocalModelFiles(projectorFiles);

    setProjectorFiles({ ...updatedProjectorFiles, [name]: newPath });
    setProjectorKey(name);
  }

  const prompt = async (
    messages: Array<MessageNode>, 
    onUpdate: (message: string) => void
  ) => {
    if (!llama) {
      console.warn("LLM not initialized");
      return;
    }

    if (busy) {
      console.warn("LLM is busy");
      return;
    }

    setBusy(true);

    try {
      const result = await llama.completion({
        messages: parseMessages(messages)
      }, (data) => onUpdate(data.token));
    
      console.log('Timings:', result.timings);
    } 
    catch (error) {
      console.error("Error prompting model:", error);
    }

    setBusy(false);
  };

  const stop = async () => {
    if (!llama) {
      console.warn("LLM not initialized");
      return;
    }

    try {
      await llama.stopCompletion();
    } catch (error) {
      console.error("Error stopping model:", error);
    }
  };

  const value = {
    ready: !!llama,
    busy,
    imagesSupported,
    modelKey,
    pickModelFile,
    setModelKey,
    modelFiles,
    setModelFiles,
    pickProjectorFile,
    projectorKey,
    setProjectorKey,
    projectorFiles,
    setProjectorFiles,
    parameters,
    setParameters,
    prompt,
    stop,
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