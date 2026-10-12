import { DocumentPickerAsset, getDocumentAsync } from "expo-document-picker";
import * as FileSystem from 'expo-file-system/legacy';
import { initLlama, loadLlamaModelInfo, RNLlamaOAICompatibleMessage } from 'llama.rn';
import { MessageNode } from 'message-nodes';
import { LanguageModelClient, LanguageModelSettings } from "./types";

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

export interface PickedFile {
  key: string;
  files: Record<string, string>;
}

async function pickFile(): Promise<DocumentPickerAsset | undefined> {
  const file = await getDocumentAsync({
    multiple: false,
  });
  return file.assets?.[0];
}

// Moves a picked file into the app's documents, replacing any previously picked one.
async function importLocalFile(asset: DocumentPickerAsset, files: Record<string, string>): Promise<PickedFile> {
  const key = `${asset.name.replace(/\.[^/.]+$/, "")} (local)`;
  const path = FileSystem.documentDirectory + asset.name;

  await FileSystem.moveAsync({
    from: asset.uri,
    to: path,
  });

  const updated = await cleanupLocalModelFiles(files);
  return { key, files: { ...updated, [key]: path } };
}

export async function pickModelFile(modelFiles: Record<string, string>): Promise<PickedFile | undefined> {
  const asset = await pickFile();
  if (!asset) return;

  if (!/\.gguf$/i.test(asset.uri) || !(await isGGUF(asset.uri))) {
    alert("Please select a valid GGUF model file");
    return;
  }

  return importLocalFile(asset, modelFiles);
}

export async function pickProjectorFile(projectorFiles: Record<string, string>): Promise<PickedFile | undefined> {
  const asset = await pickFile();
  if (!asset) return;

  if (!/\.mmproj$/i.test(asset.uri) && !/\.gguf$/i.test(asset.uri)) {
    alert("Please select a multimodel projector file");
    return;
  }

  return importLocalFile(asset, projectorFiles);
}

/** Loads the selected GGUF model (and projector, if any) into memory with llama.rn. */
export async function connectLlama(
  { modelKey, modelFiles, projectorKey, projectorFiles, parameters }: LanguageModelSettings
): Promise<LanguageModelClient | undefined> {
  if (!modelKey || !modelFiles[modelKey]) return;

  const modelFile = modelFiles[modelKey];

  // Ensure the selected file is a GGUF model before proceeding
  if (!(await isGGUF(modelFile))) return;

  const info = await loadLlamaModelInfo(modelFile) as Record<string, any>;
  const ctx_key = Object.keys(info).find(key => key.toLowerCase().endsWith("context_length"));
  const n_ctx = ctx_key ? Number(info[ctx_key]) : 2048;

  const projectorFile =
    projectorKey &&
    (projectorKey === modelKey || modelKey.endsWith("(local)"))
      ? projectorFiles[projectorKey]
      : undefined;

  const llama = await initLlama({
    model: modelFile,
    use_mlock: true,
    n_ctx,
    n_gpu_layers: 99,
    ...parameters,
    ctx_shift: !projectorFile
  });

  let imagesSupported = false;

  if (projectorFile) {
    try {
      await llama.initMultimodal({
        path: projectorFile,
        use_gpu: true
      });

      const support = await llama.getMultimodalSupport();
      imagesSupported = support.vision;
    } catch (error) {
      await llama.release();
      throw error;
    }
  }

  return {
    imagesSupported,
    prompt: async ({ messages, onUpdate }) => {
      const result = await llama.completion({
        messages: parseMessages(messages)
      }, (data) => onUpdate(data.token));

      console.log('Timings:', result.timings);
    },
    stop: () => llama.stopCompletion(),
    release: () => llama.release(),
  };
}
