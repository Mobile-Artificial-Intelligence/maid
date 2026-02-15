import { MaterialIconButton } from "@/components/buttons/icon-button";
import Dropdown from "@/components/dropdowns/dropdown";
import { useLLM, useSystem } from "@/context";
import HuggingfaceModelsRaw from "@/models.json";
import AsyncStorage from "@react-native-async-storage/async-storage";
import * as FileSystem from 'expo-file-system';
import { useEffect, useMemo, useRef, useState } from "react";
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from "react-native";

interface HuggingfaceModel {
  id: string;
  name: string;
  repo: string;
  branch: string;
  parameters: number;
  tags: Record<string, string | undefined>;
}

const HuggingfaceModels = HuggingfaceModelsRaw as Array<HuggingfaceModel>;

function ModelDownload({ source }: { source: HuggingfaceModel }) {
  const { modelFiles, setModelFiles, modelFileKey, setModelFileKey } = useLLM();
  const { colorScheme } = useSystem();
  const { id, name, repo, branch, tags } = source;

  const [progress, setProgress] = useState<FileSystem.DownloadProgressData | undefined>(undefined);
  const [tag, setTag] = useState<string>(Object.keys(tags)[0]);

  const downloaded = !!modelFiles?.[`${id}:${tag}`];

  // Holds the active download even across re-renders
  const downloadRef = useRef<FileSystem.DownloadResumable | null>(null);

  // Prevent setState after navigate-away / unmount
  const mountedRef = useRef(true);

  // Track which model/tag the ref is currently downloading
  const activeKeyRef = useRef<string | null>(null);

  useEffect(() => {
    mountedRef.current = true;
    return () => {
      mountedRef.current = false;
      // IMPORTANT: we do NOT cancel here, because you want it to keep going.
      // Just stop UI updates.
    };
  }, []);

  const currentKey = useMemo(() => `${id}:${tag}`, [id, tag]);
  const fileName = tags[tag];
  const url = useMemo(() => `https://huggingface.co/${repo}/resolve/${branch}/${fileName}`, [repo, branch, fileName]);
  const fileUri = useMemo(() => `${FileSystem.documentDirectory}${fileName}`, [fileName]);

  const downloadModel = async () => {
    // already downloaded
    if (downloaded) return;

    // if something is already downloading, don't start another
    if (downloadRef.current && activeKeyRef.current === currentKey) {
      // optionally try resuming if paused
      try {
        await downloadRef.current.resumeAsync();
      } catch {
        // ignore; might already be running
      }
      return;
    }

    // If a different tag/model is downloading, you can either block or cancel it.
    // Here we block to avoid losing the other download.
    if (downloadRef.current && activeKeyRef.current !== currentKey) {
      console.warn("Another download is already running; not starting a second one.");
      return;
    }

    activeKeyRef.current = currentKey;

    const onProgress = (downloadProgress: FileSystem.DownloadProgressData) => {
      if (!mountedRef.current) return;
      setProgress(downloadProgress);
    };

    const downloadResumable = FileSystem.createDownloadResumable(url, fileUri, {}, onProgress);
    downloadRef.current = downloadResumable;

    try {
      const result = await downloadResumable.downloadAsync();

      // Component might be gone now; still save if setters exist, but guard state writes
      if (mountedRef.current) {
        setModelFiles?.((prev) => ({ ...prev, [currentKey]: result?.uri ?? fileUri }));
        setModelFileKey?.(currentKey);
        setProgress(undefined);
      } else {
        // Even if unmounted, it can be useful to persist completion elsewhere (context/store)
        // If you want that, move model file persistence into your LLM context instead of local state.
        setModelFiles?.((prev) => ({ ...prev, [currentKey]: result?.uri ?? fileUri }));
        setModelFileKey?.(currentKey);
      }
    } catch (error) {
      console.error("Download failed:", error);
      if (mountedRef.current) setProgress(undefined);
    } finally {
      downloadRef.current = null;
      activeKeyRef.current = null;
    }
  };

  const deleteModel = async () => {
    const existing = modelFiles?.[currentKey];
    if (!existing) return;

    // If THIS file is downloading, cancel first so you don't delete mid-stream
    if (downloadRef.current && activeKeyRef.current === currentKey) {
      try {
        await downloadRef.current.cancelAsync();
      } catch {}
      downloadRef.current = null;
      activeKeyRef.current = null;
      if (mountedRef.current) setProgress(undefined);
    }

    try {
      await FileSystem.deleteAsync(existing, { idempotent: true });
      setModelFiles?.((prev) => {
        const updated = { ...prev };
        delete updated[currentKey];
        return updated;
      });
      setModelFileKey?.(undefined);
    } catch (error) {
      console.error("Delete failed:", error);
    }
  };

  const selectModel = () => {
    const existing = modelFiles?.[currentKey];
    if (!existing) {
      console.warn("Model file not found, cannot select");
      return;
    }
    setModelFileKey?.(currentKey);
  };

  useEffect(() => {
    const loadTag = async () => {
      try {
        const storedTag = await AsyncStorage.getItem(`model-${id}-selected-tag`);
        if (storedTag && tags[storedTag]) setTag(storedTag);
      } catch (error) {
        console.error("Error loading selected tag:", error);
      }
    };
    loadTag();
  }, [id, tags]);

  useEffect(() => {
    const saveTag = async () => {
      try {
        await AsyncStorage.setItem(`model-${id}-selected-tag`, tag);
      } catch (error) {
        console.error("Error saving selected tag:", error);
      }
    };
    saveTag();
  }, [id, tag]);

  const styles = StyleSheet.create({
    view: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
      borderBottomColor: colorScheme.outlineVariant,
      borderBottomWidth: 1,
      padding: 16,
    },
    downloadedOptions: {
      flexDirection: "row",
      alignItems: "center",
      gap: 8,
    },
    button: {
      backgroundColor: colorScheme.primaryContainer,
      borderRadius: 16,
      padding: 4,
    },
    deleteButton: {
      backgroundColor: colorScheme.errorContainer,
      borderRadius: 16,
      padding: 4,
    },
    titleView: {
      flexDirection: "row",
      alignItems: "center",
      gap: 8,
    },
    name: {
      color: colorScheme.secondary,
    },
    textButton: {
      color: modelFileKey === currentKey ? colorScheme.onPrimary : colorScheme.onPrimaryContainer,
      backgroundColor: modelFileKey === currentKey ? colorScheme.primary : colorScheme.primaryContainer,
      paddingVertical: 4,
      paddingHorizontal: 12,
      borderRadius: 20,
    },
  });

  const percent =
    progress?.totalBytesExpectedToWrite
      ? Math.round((progress.totalBytesWritten / progress.totalBytesExpectedToWrite) * 100)
      : undefined;

  return (
    <View style={styles.view}>
      <View style={styles.titleView}>
        <Text style={styles.name}>{name}</Text>
        <Dropdown
          items={Object.keys(tags).map((key) => ({ label: key, value: key }))}
          selectedValue={tag}
          onValueChange={setTag}
        />
      </View>

      {percent !== undefined && <Text style={styles.name}>{percent}%</Text>}

      {!progress && !downloaded && (
        <MaterialIconButton
          icon="download"
          size={18}
          style={styles.button}
          color={colorScheme.onPrimaryContainer}
          onPress={downloadModel}
        />
      )}

      {downloaded && (
        <View style={styles.downloadedOptions}>
          <MaterialIconButton
            icon="delete"
            size={18}
            style={styles.deleteButton}
            color={colorScheme.onErrorContainer}
            onPress={deleteModel}
          />
          <TouchableOpacity onPress={selectModel}>
            <Text style={styles.textButton}>Select</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
}

function Download() {
  const { colorScheme } = useSystem();
  
  const styles = StyleSheet.create({
    view: {
      flex: 1,
      flexDirection: "column",
      backgroundColor: colorScheme.surface,
      paddingHorizontal: 16,
      paddingVertical: 8,
      gap: 8
    }
  });

  return (
    <ScrollView
      style={styles.view}
    >
      {HuggingfaceModels.map((model, index) => (
        <ModelDownload 
          key={index}
          source={model}
        />
      ))}
    </ScrollView>
  );
}

export default Download;