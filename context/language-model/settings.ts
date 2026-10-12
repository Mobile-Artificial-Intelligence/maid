import AsyncStorage from "@react-native-async-storage/async-storage";
import { Dispatch, SetStateAction, useEffect, useMemo, useRef, useState } from "react";
import { LanguageModelDefinition, LanguageModelSetting, LanguageModelSettings } from "./types";

// Each setting keeps the storage key it has always been saved under, so
// settings saved by earlier versions carry over.
const STORAGE_SUFFIXES: Record<LanguageModelSetting, string> = {
  baseURL: "base-url",
  apiKey: "api-key",
  model: "model",
  headers: "headers",
  parameters: "parameters",
  modelKey: "model-file-key",
  modelFiles: "model-files",
  projectorKey: "projector-file-key",
  projectorFiles: "projector-files",
};

// Stored as JSON; the rest are stored as plain strings.
const RECORD_SETTINGS: ReadonlyArray<LanguageModelSetting> = ["headers", "parameters", "modelFiles", "projectorFiles"];

function storageKey(definition: LanguageModelDefinition, setting: LanguageModelSetting): string {
  return `${definition.storagePrefix}-${STORAGE_SUFFIXES[setting]}`;
}

function defaultSettings(definition: LanguageModelDefinition): LanguageModelSettings {
  return {
    baseURL: definition.defaultBaseURL,
    headers: {},
    parameters: {},
    modelFiles: {},
    projectorFiles: {},
  };
}

async function loadSettings(definition: LanguageModelDefinition): Promise<LanguageModelSettings> {
  const settings: Record<string, unknown> = { ...defaultSettings(definition) };

  try {
    const keys = definition.settings.map((setting) => storageKey(definition, setting));
    const stored = new Map(await AsyncStorage.multiGet(keys));

    for (const setting of definition.settings) {
      const key = storageKey(definition, setting);
      const value = stored.get(key);
      if (!value) continue;

      try {
        settings[setting] = RECORD_SETTINGS.includes(setting) ? JSON.parse(value) : value;
      } catch (error) {
        console.error(`Error parsing ${key}:`, error);
      }
    }
  } catch (error) {
    console.error(`Error loading ${definition.storagePrefix} settings:`, error);
  }

  return settings as unknown as LanguageModelSettings;
}

async function saveSetting(definition: LanguageModelDefinition, setting: LanguageModelSetting, value: unknown) {
  const key = storageKey(definition, setting);

  try {
    if (RECORD_SETTINGS.includes(setting)) {
      await AsyncStorage.setItem(key, JSON.stringify(value));
    } else if (value) {
      await AsyncStorage.setItem(key, value as string);
    } else {
      await AsyncStorage.removeItem(key);
    }
  } catch (error) {
    console.error(`Error saving ${key}:`, error);
  }
}

interface SettingsState {
  definition: LanguageModelDefinition;
  values: LanguageModelSettings;
  loaded: boolean;
}

/**
 * Holds the settings of the selected provider only. Selecting another provider
 * swaps them for that provider's, read back from storage; edits are written
 * through to storage as they happen.
 */
export function useLanguageModelSettings(definition: LanguageModelDefinition) {
  const [state, setState] = useState<SettingsState>(() => ({
    definition,
    values: defaultSettings(definition),
    loaded: false,
  }));

  // The last settings known to be in storage, to save only what changed.
  const savedRef = useRef<SettingsState | undefined>(undefined);

  // Drop the previous provider's settings during render, so they are never
  // shown, used or saved as the new provider's.
  if (state.definition !== definition) {
    setState({ definition, values: defaultSettings(definition), loaded: false });
  }

  useEffect(() => {
    let cancelled = false;

    loadSettings(definition).then((values) => {
      if (cancelled) return;
      const loaded = { definition, values, loaded: true };
      savedRef.current = loaded;
      setState(loaded);
    });

    return () => {
      cancelled = true;
    };
  }, [definition]);

  useEffect(() => {
    const saved = savedRef.current;
    if (!state.loaded || saved?.definition !== state.definition || saved.values === state.values) return;

    for (const setting of state.definition.settings) {
      if (state.values[setting] !== saved.values[setting]) {
        saveSetting(state.definition, setting, state.values[setting]);
      }
    }

    savedRef.current = state;
  }, [state]);

  const setters = useMemo(() => {
    function setter<K extends LanguageModelSetting>(setting: K): Dispatch<SetStateAction<LanguageModelSettings[K]>> {
      return (action) => setState((prev) => ({
        ...prev,
        values: {
          ...prev.values,
          [setting]: typeof action === "function"
            ? (action as (previous: LanguageModelSettings[K]) => LanguageModelSettings[K])(prev.values[setting])
            : action,
        },
      }));
    }

    return {
      setBaseURL: setter("baseURL"),
      setApiKey: setter("apiKey"),
      setModel: setter("model"),
      setHeaders: setter("headers"),
      setParameters: setter("parameters"),
      setModelKey: setter("modelKey"),
      setModelFiles: setter("modelFiles"),
      setProjectorKey: setter("projectorKey"),
      setProjectorFiles: setter("projectorFiles"),
    };
  }, []);

  return {
    values: state.values,
    loaded: state.loaded,
    ...setters,
  };
}
