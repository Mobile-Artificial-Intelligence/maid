import { MaterialIconButton } from "@/components/buttons/icon-button";
import Dropdown from "@/components/dropdowns/dropdown";
import { useLLM, useSystem } from "@/context";
import HuggingfaceModelsRaw from "@/models.json";
import AsyncStorage from "@react-native-async-storage/async-storage";
import * as FileSystem from 'expo-file-system';
import { useEffect, useMemo, useRef, useState } from "react";
import { ScrollView, StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

interface HuggingfaceModel {
  id: string;
  name: string;
  repo: string;
  branch: string;
  parameters?: number;
  category?: string;
  tags: Record<string, string | Array<string> | undefined>;
}

const HuggingfaceModels = HuggingfaceModelsRaw as Array<HuggingfaceModel>;

const CATEGORIES = [
  "All 🌐",
  "☠️ Uncensored",
  "⚡ Instruct",
  "💻 Coding",
  "🧠 Thinking",
  "👁️ Vision",
  "📥 Downloaded"
];

function ModelDownload({ source }: { source: HuggingfaceModel }) {
  const { modelFiles, setModelFiles, modelKey, setModelKey, projectorFiles, setProjectorFiles, projectorKey, setProjectorKey } = useLLM();
  const { colorScheme } = useSystem();
  const { id, name, repo, branch, tags, parameters, category } = source;

  const [progress, setProgress] = useState<FileSystem.DownloadProgressData | undefined>(undefined);
  const [projectorProgress, setProjectorProgress] = useState<FileSystem.DownloadProgressData | undefined>(undefined);
  const [tag, setTag] = useState<string>(Object.keys(tags)[0] || "");

  // Holds the active download even across re-renders
  const downloadRef = useRef<FileSystem.DownloadResumable | null>(null);
  const projectorDownloadRef = useRef<FileSystem.DownloadResumable | null>(null);

  // Prevent setState after navigate-away / unmount
  const mountedRef = useRef(true);

  // Track which model/tag the ref is currently downloading
  const activeKeyRef = useRef<string | null>(null);

  useEffect(() => {
    mountedRef.current = true;
    return () => {
      mountedRef.current = false;
    };
  }, []);

  const currentKey = useMemo(() => `${id}:${tag}`, [id, tag]);

  const modelFileName = useMemo(() => Array.isArray(tags[tag]) ? tags[tag][0] : tags[tag], [tags, tag]);
  const modelUrl = useMemo(() => `https://huggingface.co/${repo}/resolve/${branch}/${modelFileName}`, [repo, branch, modelFileName]);
  const modelFilePath = useMemo(() => `${FileSystem.documentDirectory}${modelFileName}`, [modelFileName]);

  const projectorFileName = useMemo(() => Array.isArray(tags[tag]) ? tags[tag][1] : undefined, [tags, tag]);
  const projectorUrl = useMemo(() => projectorFileName ? `https://huggingface.co/${repo}/resolve/${branch}/${projectorFileName}` : undefined, [repo, branch, projectorFileName]);
  const projectorFilePath = useMemo(() => projectorFileName ? `${FileSystem.documentDirectory}${projectorFileName}` : undefined, [projectorFileName]);

  const downloaded = !!modelFiles?.[currentKey] && (!projectorFileName || !!projectorFiles?.[currentKey]);

  const downloadModel = async () => {
    if (downloaded) return;

    if (downloadRef.current && activeKeyRef.current === currentKey) {
      try {
        await downloadRef.current.resumeAsync();
      } catch {
      }
      if (projectorDownloadRef.current) {
        try { await projectorDownloadRef.current.resumeAsync(); } catch {}
      }
      return;
    }

    if (downloadRef.current && activeKeyRef.current !== currentKey) {
      console.warn("Another download is already running; not starting a second one.");
      return;
    }

    activeKeyRef.current = currentKey;

    const modelResumable = FileSystem.createDownloadResumable(
      modelUrl, modelFilePath, {},
      (p) => { if (mountedRef.current) setProgress(p); }
    );
    downloadRef.current = modelResumable;

    const downloads: Promise<FileSystem.FileSystemDownloadResult | undefined>[] = [modelResumable.downloadAsync()];

    if (projectorUrl && projectorFilePath) {
      const projectorResumable = FileSystem.createDownloadResumable(
        projectorUrl, projectorFilePath, {},
        (p) => { if (mountedRef.current) setProjectorProgress(p); }
      );
      projectorDownloadRef.current = projectorResumable;
      downloads.push(projectorResumable.downloadAsync());
    }

    try {
      const [modelResult, projectorResult] = await Promise.all(downloads);

      setModelFiles?.((prev) => ({ ...prev, [currentKey]: modelResult?.uri ?? modelFilePath }));
      setModelKey?.(currentKey);

      if (projectorResult && projectorFilePath) {
        setProjectorFiles?.((prev) => ({ ...prev, [currentKey]: projectorResult.uri ?? projectorFilePath }));
        setProjectorKey?.(currentKey);
      }

      if (mountedRef.current) {
        setProgress(undefined);
        setProjectorProgress(undefined);
      }
    } catch (error) {
      console.error("Download failed:", error);
      if (mountedRef.current) {
        setProgress(undefined);
        setProjectorProgress(undefined);
      }
    } finally {
      downloadRef.current = null;
      projectorDownloadRef.current = null;
      activeKeyRef.current = null;
    }
  };

  const deleteModel = async () => {
    const existing = modelFiles?.[currentKey];
    if (!existing) return;

    if (downloadRef.current && activeKeyRef.current === currentKey) {
      try { await downloadRef.current.cancelAsync(); } catch {}
      if (projectorDownloadRef.current) {
        try { await projectorDownloadRef.current.cancelAsync(); } catch {}
        projectorDownloadRef.current = null;
      }
      downloadRef.current = null;
      activeKeyRef.current = null;
      if (mountedRef.current) {
        setProgress(undefined);
        setProjectorProgress(undefined);
      }
    }

    try {
      await FileSystem.deleteAsync(existing, { idempotent: true });
      setModelFiles?.((prev) => {
        const updated = { ...prev };
        delete updated[currentKey];
        return updated;
      });
      setModelKey?.(undefined);

      const existingProjector = projectorFiles?.[currentKey];
      if (existingProjector) {
        await FileSystem.deleteAsync(existingProjector, { idempotent: true });
        setProjectorFiles?.((prev) => {
          const updated = { ...prev };
          delete updated[currentKey];
          return updated;
        });
        setProjectorKey?.(undefined);
      }
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
    setModelKey?.(currentKey);
    if (projectorFiles?.[currentKey]) {
      setProjectorKey?.(currentKey);
    } else {
      setProjectorKey?.(undefined);
    }
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
        if (tag) await AsyncStorage.setItem(`model-${id}-selected-tag`, tag);
      } catch (error) {
        console.error("Error saving selected tag:", error);
      }
    };
    saveTag();
  }, [id, tag]);

  const styles = StyleSheet.create({
    card: {
      flexDirection: "column",
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 12,
      padding: 14,
      marginBottom: 10,
      gap: 10,
    },
    topRow: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
    },
    titleView: {
      flexDirection: "column",
      flex: 1,
      marginRight: 8,
    },
    name: {
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold",
    },
    metaRow: {
      flexDirection: "row",
      alignItems: "center",
      gap: 8,
      marginTop: 4,
    },
    badge: {
      backgroundColor: colorScheme.surface,
      paddingHorizontal: 8,
      paddingVertical: 2,
      borderRadius: 6,
      borderWidth: 1,
      borderColor: colorScheme.outline,
    },
    badgeText: {
      color: colorScheme.primary,
      fontSize: 11,
      fontWeight: "600",
    },
    bottomRow: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
    },
    downloadedOptions: {
      flexDirection: "row",
      alignItems: "center",
      gap: 8,
    },
    button: {
      backgroundColor: colorScheme.primary,
      borderRadius: 20,
      padding: 6,
    },
    deleteButton: {
      backgroundColor: colorScheme.errorContainer,
      borderRadius: 20,
      padding: 6,
    },
    textButton: {
      color: modelKey === currentKey ? colorScheme.onPrimary : colorScheme.onPrimaryContainer,
      backgroundColor: modelKey === currentKey ? colorScheme.primary : colorScheme.primaryContainer,
      paddingVertical: 6,
      paddingHorizontal: 16,
      borderRadius: 20,
      fontWeight: "600",
    },
    statusText: {
      color: colorScheme.secondary,
      fontSize: 13,
      fontWeight: "500",
    },
  });

  const percent =
    progress?.totalBytesExpectedToWrite
      ? Math.round((progress.totalBytesWritten / progress.totalBytesExpectedToWrite) * 100)
      : undefined;

  const projectorPercent =
    projectorProgress?.totalBytesExpectedToWrite
      ? Math.round((projectorProgress.totalBytesWritten / projectorProgress.totalBytesExpectedToWrite) * 100)
      : undefined;

  const getCategoryBadgeColor = (cat?: string) => {
    if (cat?.includes("Uncensored")) return { borderColor: "#FF0033", color: "#FF4D6D" };
    if (cat?.includes("Thinking")) return { borderColor: "#9900FF", color: "#C77DFF" };
    if (cat?.includes("Coding")) return { borderColor: "#00FF66", color: "#00FF66" };
    return { borderColor: colorScheme.outline, color: colorScheme.primary };
  };

  const badgeStyle = getCategoryBadgeColor(category);

  return (
    <View style={styles.card}>
      <View style={styles.topRow}>
        <View style={styles.titleView}>
          <Text style={styles.name}>{name}</Text>
          <View style={styles.metaRow}>
            {category && (
              <View style={[styles.badge, { borderColor: badgeStyle.borderColor }]}>
                <Text style={[styles.badgeText, { color: badgeStyle.color }]}>{category}</Text>
              </View>
            )}
            {parameters && (
              <View style={styles.badge}>
                <Text style={styles.badgeText}>{parameters}B</Text>
              </View>
            )}
          </View>
        </View>
        <Dropdown
          items={Object.keys(tags).map((key) => ({ label: key, value: key }))}
          selectedValue={tag}
          onValueChange={setTag}
        />
      </View>

      <View style={styles.bottomRow}>
        {percent !== undefined ? (
          <Text style={styles.statusText}>
            {projectorFileName ? `Downloading Model: ${percent}% | Proj: ${projectorPercent ?? 0}%` : `Downloading: ${percent}%`}
          </Text>
        ) : (
          <Text style={styles.statusText}>
            {downloaded ? "✅ Downloaded & Ready" : `Quant: ${tag}`}
          </Text>
        )}

        {!progress && !downloaded && (
          <MaterialIconButton
            icon="download"
            size={20}
            style={styles.button}
            color={colorScheme.onPrimary}
            onPress={downloadModel}
          />
        )}

        {downloaded && (
          <View style={styles.downloadedOptions}>
            <MaterialIconButton
              icon="delete"
              size={20}
              style={styles.deleteButton}
              color={colorScheme.onErrorContainer}
              onPress={deleteModel}
            />
            <TouchableOpacity onPress={selectModel}>
              <Text style={styles.textButton}>
                {modelKey === currentKey ? "Selected ★" : "Select"}
              </Text>
            </TouchableOpacity>
          </View>
        )}
      </View>
    </View>
  );
}

function Download() {
  const { colorScheme } = useSystem();
  const { modelFiles } = useLLM();
  const [searchQuery, setSearchQuery] = useState("");
  const [activeTab, setActiveTab] = useState("All 🌐");
  
  const styles = StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: colorScheme.surface,
      paddingHorizontal: 16,
      paddingTop: 12,
    },
    searchBox: {
      color: colorScheme.onSurface,
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 24,
      paddingVertical: 10,
      paddingHorizontal: 18,
      fontSize: 15,
      marginBottom: 12,
    },
    tabsScrollView: {
      flexGrow: 0,
      marginBottom: 12,
    },
    tabButton: {
      paddingVertical: 6,
      paddingHorizontal: 14,
      borderRadius: 20,
      marginRight: 8,
      borderWidth: 1,
      borderColor: colorScheme.outline,
      backgroundColor: colorScheme.surface,
    },
    activeTabButton: {
      backgroundColor: colorScheme.primary,
      borderColor: colorScheme.primary,
    },
    tabText: {
      color: colorScheme.onSurface,
      fontSize: 13,
      fontWeight: "600",
    },
    activeTabText: {
      color: colorScheme.onPrimary,
    },
    listContent: {
      paddingBottom: 24,
    },
    emptyText: {
      color: colorScheme.secondary,
      textAlign: "center",
      marginTop: 32,
      fontSize: 15,
    }
  });

  const filteredModels = useMemo(() => {
    return HuggingfaceModels.filter((model) => {
      const matchesSearch =
        searchQuery.trim() === "" ||
        model.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (model.category?.toLowerCase() || "").includes(searchQuery.toLowerCase()) ||
        model.id.toLowerCase().includes(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (activeTab === "All 🌐") return true;
      if (activeTab === "📥 Downloaded") {
        return Object.keys(model.tags).some((tagKey) => {
          const key = `${model.id}:${tagKey}`;
          return !!modelFiles?.[key];
        });
      }
      return model.category === activeTab;
    });
  }, [searchQuery, activeTab, modelFiles]);

  return (
    <View style={styles.container} testID="download-page">
      <TextInput
        style={styles.searchBox}
        placeholder="Search 27 models by name, category (☠️ Uncensored)..."
        placeholderTextColor={colorScheme.outline}
        value={searchQuery}
        onChangeText={setSearchQuery}
      />

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={styles.tabsScrollView}
      >
        {CATEGORIES.map((cat) => {
          const isActive = activeTab === cat;
          return (
            <TouchableOpacity
              key={cat}
              style={[styles.tabButton, isActive && styles.activeTabButton]}
              onPress={() => setActiveTab(cat)}
            >
              <Text style={[styles.tabText, isActive && styles.activeTabText]}>
                {cat}
              </Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>

      <ScrollView contentContainerStyle={styles.listContent}>
        {filteredModels.length > 0 ? (
          filteredModels.map((model, index) => (
            <ModelDownload key={`${model.id}-${index}`} source={model} />
          ))
        ) : (
          <Text style={styles.emptyText}>No models match your filter / search.</Text>
        )}
      </ScrollView>
    </View>
  );
}

export default Download;
