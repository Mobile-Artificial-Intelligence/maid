import { MaterialIconButton } from "@/components/buttons/icon-button";
import Dropdown from "@/components/dropdowns/dropdown";
import { useLLM, useSystem } from "@/context";
import HuggingfaceModelsRaw from "@/models.json";
import AsyncStorage from "@react-native-async-storage/async-storage";
import * as FileSystem from 'expo-file-system';
import { useEffect, useState } from "react";
import { ActivityIndicator, ScrollView, StyleSheet, Text, TouchableOpacity, View } from "react-native";

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
  const { modelFiles, setModelFiles, setModelFileKey } = useLLM();
  const { colorScheme } = useSystem();
  const { id, name, repo, branch, tags } = source;
  const [progress, setProgress] = useState<FileSystem.DownloadProgressData | undefined>(undefined);
  const [tag, setTag] = useState<string>(Object.keys(tags)[0]);
  const downloaded = !!modelFiles?.[`${id}:${tag}`];

  const downloadModel = async () => {
    const url = `https://huggingface.co/${repo}/resolve/${branch}/${tags[tag]}`;
    const fileUri = `${FileSystem.documentDirectory}${tags[tag]}`;

    const downloadResumable = FileSystem.createDownloadResumable(
      url,
      fileUri,
      {},
      (downloadProgress) => setProgress(downloadProgress)
    );

    try {
      const result = await downloadResumable.downloadAsync();
      setModelFiles!((prev) => ({ ...prev, [`${id}:${tag}`]: result?.uri ?? fileUri }));
      setModelFileKey!(`${id}:${tag}`);
    } catch (error) {
      console.error('Download failed:', error);
    }

    setProgress(undefined);
  };

  const deleteModel = async () => {
    const fileUri = modelFiles?.[`${id}:${tag}`];
    if (!fileUri) return;

    try {
      await FileSystem.deleteAsync(fileUri);
      setModelFiles!((prev) => {
        const updated = { ...prev };
        delete updated[`${id}:${tag}`];
        return updated;
      });
      setModelFileKey!(undefined);
    } catch (error) {
      console.error('Delete failed:', error);
    }
  };

  const selectModel = () => {
    const fileUri = modelFiles?.[`${id}:${tag}`];
    if (!fileUri) {
      console.warn("Model file not found, cannot select");
      return;
    }

    setModelFileKey!(`${id}:${tag}`);
  };

  useEffect(() => {
    const loadTag = async () => {
      try {
        const storedTag = await AsyncStorage.getItem(`model-${id}-selected-tag`);
        if (storedTag && tags[storedTag]) {
          setTag(storedTag);
        }
      } catch (error) {
        console.error("Error loading selected tag:", error);
      }
    };

    loadTag();
  }, []);

  useEffect(() => {
    const saveTag = async () => {
      try {
        await AsyncStorage.setItem(`model-${id}-selected-tag`, tag);
      } catch (error) {
        console.error("Error saving selected tag:", error);
      }
    };

    saveTag();
  }, [tag]);

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
      gap: 8
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
      gap: 8
    },
    name: {
      color: colorScheme.secondary,
    },
    textButton: {
      color: colorScheme.onPrimaryContainer,
      backgroundColor: colorScheme.primaryContainer,
      paddingVertical: 4,
      paddingHorizontal: 12,
      borderRadius: 20,
    }
  });

  return (
    <View style={styles.view}>
      <View style={styles.titleView} >
        <Text style={styles.name} >{name}</Text>
        <Dropdown
          items={Object.keys(tags).map((key) => {
            return {
              label: key,
              value: key
            }
          })}
          selectedValue={tag}
          onValueChange={setTag}
        />
      </View>
      {progress && <ActivityIndicator size="large" color={colorScheme.onPrimaryContainer} />}
      {!progress && !downloaded && <MaterialIconButton
        icon="download"
        size={18}
        style={styles.button}
        color={colorScheme.onPrimaryContainer}
        onPress={downloadModel}
      />}
      {downloaded && (
        <View style={styles.downloadedOptions}>
          <MaterialIconButton
            icon="delete"
            size={18}
            style={styles.deleteButton}
            color={colorScheme.onErrorContainer}
            onPress={deleteModel}
          />
          <TouchableOpacity
            onPress={selectModel}
          >
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