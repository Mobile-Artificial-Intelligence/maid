import AsyncStorage from "@react-native-async-storage/async-storage";
import { MessageNode } from "message-nodes";
import { createContext, Dispatch, SetStateAction, useContext, useEffect, useRef, useState } from "react";
import { pickModelFile, pickProjectorFile } from "./llama";
import { LanguageModelDefinitions } from "./providers";
import { useLanguageModelSettings } from "./settings";
import { LanguageModelClient, LanguageModelContextProps, LanguageModelDefinition, LanguageModelSetting, LanguageModelType, LanguageModelTypes } from "./types";

const TYPE_STORAGE_KEY = "language-model-type";

// Waits for settings to settle (typing a URL or key, picking model files)
// before building a client from them.
const CONNECT_DELAY = 300;

// The connected client of the selected provider and what it has reported.
interface Session {
  definition: LanguageModelDefinition;
  client: LanguageModelClient;
  models: Array<string>;
  vision: Record<string, boolean>;
}

const LanguageModelContext = createContext<LanguageModelContextProps | undefined>(undefined);

function useStoredType(): [LanguageModelType, Dispatch<SetStateAction<LanguageModelType>>, boolean] {
  const [type, setType] = useState<LanguageModelType>("Llama");
  const [loaded, setLoaded] = useState<boolean>(false);

  useEffect(() => {
    AsyncStorage.getItem(TYPE_STORAGE_KEY)
      .then((storedType) => {
        if (storedType && (LanguageModelTypes as ReadonlyArray<string>).includes(storedType)) {
          setType(storedType as LanguageModelType);
        }
      })
      .catch((error) => console.error("Error loading language model type:", error))
      .finally(() => setLoaded(true));
  }, []);

  useEffect(() => {
    if (!loaded) return;

    AsyncStorage.setItem(TYPE_STORAGE_KEY, type)
      .catch((error) => console.error("Error saving language model type:", error));
  }, [type, loaded]);

  return [type, setType, loaded];
}

/**
 * The one provider behind every language model API. Only the selected API has
 * its settings in memory and a client connected; switching API releases the
 * previous client (unloading a local model) before connecting the next.
 */
export function LanguageModelProvider({ children }: { children: React.ReactNode }) {
  const [type, setType, typeLoaded] = useStoredType();
  const definition = LanguageModelDefinitions[type];
  const settings = useLanguageModelSettings(definition);
  const { values } = settings;

  const [session, setSession] = useState<Session | undefined>(undefined);
  const [connecting, setConnecting] = useState<boolean>(false);
  const [prompting, setPrompting] = useState<boolean>(false);
  const stopRef = useRef<boolean>(false);
  // Settles once the previous client has been released.
  const releasedRef = useRef<Promise<void>>(Promise.resolve());

  const current = session?.definition === definition ? session : undefined;
  const client = current?.client;

  const has = (setting: LanguageModelSetting) => definition.settings.includes(setting);

  // Waits for the stored type so the default type doesn't load a model first.
  const connection = typeLoaded && settings.loaded
    ? JSON.stringify(definition.connectWith.map((setting) => values[setting]))
    : undefined;

  useEffect(() => {
    if (connection === undefined) return;

    let cancelled = false;
    let connected: LanguageModelClient | undefined;

    const timeout = setTimeout(() => {
      const released = releasedRef.current;
      setConnecting(true);

      releasedRef.current = (async () => {
        await released;
        if (cancelled) return;

        const result = await definition.connect(values, type);
        if (cancelled) {
          await result?.release?.();
          return;
        }

        connected = result;
        if (result) {
          setSession({ definition, client: result, models: [], vision: {} });
        }
      })()
        .catch((error) => console.error(`Error connecting to ${type}:`, error))
        .finally(() => {
          if (!cancelled) setConnecting(false);
        });
    }, CONNECT_DELAY);

    return () => {
      cancelled = true;
      clearTimeout(timeout);
      setSession(undefined);
      setConnecting(false);
      releasedRef.current = releasedRef.current
        .then(() => connected?.release?.())
        .catch((error) => console.error(`Error releasing ${type}:`, error));
    };
  }, [definition, connection]);

  useEffect(() => {
    if (!client?.listModels) return;

    client.listModels()
      .then(({ models, vision }) => setSession((prev) =>
        prev?.client === client ? { ...prev, models, vision: { ...prev.vision, ...vision } } : prev
      ))
      .catch((error) => console.error(`Error fetching ${type} models:`, error));
  }, [client]);

  const model = values.model;

  useEffect(() => {
    if (!client?.supportsImages || !model) return;

    client.supportsImages(model)
      .then((supported) => setSession((prev) =>
        prev?.client === client ? { ...prev, vision: { ...prev.vision, [model]: supported } } : prev
      ))
      .catch((error) => console.error("Error checking image support:", error));
  }, [client, model]);

  const imagesSupported = client?.imagesSupported ?? (!!model && current?.vision[model] === true);

  const prompt = async (
    messages: Array<MessageNode>,
    onUpdate: (message: string) => void
  ) => {
    if (!client) {
      console.warn(`${type} not initialized`);
      return;
    }

    if (has("model") && !model) {
      console.warn(`${type} model not set`);
      return;
    }

    if (prompting) {
      console.warn("Prompt already in progress");
      return;
    }

    stopRef.current = false;
    setPrompting(true);

    try {
      await client.prompt({
        model: model ?? "",
        messages,
        parameters: values.parameters,
        imagesSupported,
        onUpdate,
        shouldStop: () => stopRef.current,
      });
    } catch (error) {
      console.error(`Error prompting ${type}:`, error);
    } finally {
      setPrompting(false);
    }
  };

  const stop = async () => {
    stopRef.current = true;

    try {
      await client?.stop?.();
    } catch (error) {
      console.error(`Error stopping ${type}:`, error);
    }
  };

  const value: LanguageModelContextProps = {
    type,
    setType,
    ready: !!client && (!has("model") || !!model),
    busy: connecting || prompting,
    imagesSupported,
    parameters: values.parameters,
    setParameters: settings.setParameters,
    prompt,
    stop,
    ...(has("model") ? {
      models: current?.models ?? [],
      model,
      setModel: settings.setModel,
    } : {}),
    ...(has("baseURL") ? {
      baseURL: values.baseURL,
      setBaseURL: settings.setBaseURL,
      resetBaseURL: definition.defaultBaseURL
        ? () => settings.setBaseURL(definition.defaultBaseURL)
        : undefined,
    } : {}),
    ...(has("apiKey") ? {
      apiKey: values.apiKey,
      setApiKey: settings.setApiKey,
    } : {}),
    ...(has("headers") ? {
      headers: values.headers,
      setHeaders: settings.setHeaders,
    } : {}),
    ...(has("modelKey") ? {
      modelKey: values.modelKey,
      setModelKey: settings.setModelKey,
      modelFiles: values.modelFiles,
      setModelFiles: settings.setModelFiles,
      pickModelFile: async () => {
        const picked = await pickModelFile(values.modelFiles);
        if (!picked) return;
        settings.setModelFiles(picked.files);
        settings.setModelKey(picked.key);
      },
      projectorKey: values.projectorKey,
      setProjectorKey: settings.setProjectorKey,
      projectorFiles: values.projectorFiles,
      setProjectorFiles: settings.setProjectorFiles,
      pickProjectorFile: async () => {
        const picked = await pickProjectorFile(values.projectorFiles);
        if (!picked) return;
        settings.setProjectorFiles(picked.files);
        settings.setProjectorKey(picked.key);
      },
    } : {}),
  };

  return (
    <LanguageModelContext.Provider value={value}>
      {children}
    </LanguageModelContext.Provider>
  );
}

export function useLLM() {
  const context = useContext(LanguageModelContext);

  if (!context) {
    throw new Error("useLLM must be used within a LanguageModelProvider");
  }

  return context;
}

export { LanguageModelTypes } from "./types";
