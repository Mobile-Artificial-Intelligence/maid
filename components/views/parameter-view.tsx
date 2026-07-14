import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useLLM, useSystem } from "@/context";
import { randomUUID } from "expo-crypto";
import { useEffect, useState } from "react";
import { ScrollView, StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

interface ParameterPreset {
  name: string;
  badge: string;
  params: Record<string, number | boolean | string>;
}

const PARAM_PRESETS: ParameterPreset[] = [
  {
    name: "Creative / Uncensored",
    badge: "🎯 Roleplay",
    params: { temperature: 0.85, top_p: 0.95, repeat_penalty: 1.1 }
  },
  {
    name: "Precision Coding",
    badge: "💻 Code",
    params: { temperature: 0.2, top_p: 0.90, repeat_penalty: 1.05 }
  },
  {
    name: "Balanced Analyst",
    badge: "🔍 General",
    params: { temperature: 0.7, top_p: 0.90, repeat_penalty: 1.1 }
  }
];

function ParameterView() {
  const { colorScheme } = useSystem();
  const { parameters, setParameters } = useLLM();
  const [keys, setKeys] = useState<string[]>(Object.keys(parameters));

  useEffect(() => {
    setKeys(Object.keys(parameters));
  }, [parameters]);

  const styles = StyleSheet.create({
    container: {
      flexDirection: "column",
      justifyContent: "flex-start",
      alignItems: "center",
      width: "100%",
    },
    title: {
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold"
    },
    subtitle: {
      color: colorScheme.secondary,
      fontSize: 13,
      marginVertical: 4,
    },
    presetsRow: {
      flexDirection: "row",
      alignItems: "center",
      marginVertical: 8,
    },
    presetCard: {
      backgroundColor: colorScheme.surfaceVariant,
      paddingVertical: 6,
      paddingHorizontal: 12,
      borderRadius: 16,
      borderWidth: 1,
      borderColor: colorScheme.outlineVariant,
      marginRight: 8,
      alignItems: "center",
    },
    presetName: {
      color: colorScheme.onSurface,
      fontSize: 13,
      fontWeight: "600",
    },
    presetBadge: {
      color: colorScheme.primary,
      fontSize: 11,
      fontWeight: "bold",
    },
    buttonRow: {
      flexDirection: "row",
      justifyContent: "space-evenly",
      alignItems: "center",
      gap: 16,
      marginVertical: 8
    },
    button: { 
      color: colorScheme.primary,
      backgroundColor: colorScheme.surfaceVariant,
      paddingVertical: 8,
      paddingHorizontal: 16,
      borderRadius: 20,
      fontWeight: "600",
    },
  });

  const addParameter = () => {
    const newKey = randomUUID();
    setKeys((prev) => [...prev, newKey]);
  };

  const clearParameters = () => {
    setKeys([]);
    setParameters({});
  };

  const applyPreset = (presetParams: Record<string, number | boolean | string>) => {
    setParameters((prev) => ({ ...prev, ...presetParams }));
  };

  const onDelete = (parameterKey: string) => {
    setKeys((prev) => prev.filter((key) => key !== parameterKey));
    setParameters((prev) => {
      const updated = { ...prev };
      delete updated[parameterKey];
      return updated;
    });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Model Parameters & Sampling ⚙️</Text>
      <Text style={styles.subtitle}>Quick Sampling Presets:</Text>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.presetsRow}>
        {PARAM_PRESETS.map((preset) => (
          <TouchableOpacity
            key={preset.name}
            style={styles.presetCard}
            onPress={() => applyPreset(preset.params)}
          >
            <Text style={styles.presetBadge}>{preset.badge}</Text>
            <Text style={styles.presetName}>{preset.name}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      <View style={styles.buttonRow}>
        <TouchableOpacity onPress={addParameter}>
          <Text style={styles.button}>Add Parameter</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={clearParameters}>
          <Text style={styles.button}>Clear Parameters</Text>
        </TouchableOpacity>
      </View>

      {keys.map((key) => (
        <ParameterViewItem
          key={key}
          parameterKey={key}
          value={parameters[key]}
          onDelete={() => onDelete(key)}
        />
      ))}
    </View>
  );
}

interface ParameterViewItemProps {
  parameterKey: string;
  value?: string | number | boolean;
  onDelete: () => void;
}

function parseValue(value: string): string | number | boolean {
  if (value.toLowerCase() === "true") {
    return true;
  } else if (value.toLowerCase() === "false") {
    return false;
  } else if (value.trim() !== '' && !isNaN(Number(value))) {
    return Number(value);
  }
  return value;
}

function ParameterViewItem(props: ParameterViewItemProps) {
  const { colorScheme } = useSystem();
  const { parameters, setParameters } = useLLM();

  const regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const initialKey = regex.test(props.parameterKey) ? "" : props.parameterKey;
  const [oldKey, setOldKey] = useState<string>(initialKey);
  const [key, setKey] = useState<string>(initialKey);
  const [value, setValue] = useState<string>(String(props.value ?? parameters[key] ?? ""));

  const styles = StyleSheet.create({
    container: {
      flexDirection: "row",
      justifyContent: "space-evenly",
      alignItems: "center",
      paddingVertical: 4,
      width: "100%"
    },
    input: {
      color: colorScheme.onSurface,
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 20,
      fontSize: 15,
      paddingVertical: 10,
      paddingHorizontal: 16,
      width: "40%",
    }
  });

  useEffect(() => {
    const handler = setTimeout(() => {
      if (key.trim() === "" || key === oldKey) {
        return;
      }

      const parsedValue = parseValue(value);

      setParameters((prev: Record<string, string | number | boolean>) => {
        const updated = { ...prev };
        delete updated[oldKey];
        return { ...updated, [key]: parsedValue };
      });

      setOldKey(key);
    }, 500);

    return () => clearTimeout(handler);
  }, [key, oldKey, value, setParameters]);

  const updateParameter = (newValue: string) => {
    if (key.trim() === "") return;

    const parsedValue = parseValue(newValue);
    setParameters((prev: Record<string, string | number | boolean>) => ({ ...prev, [key]: parsedValue }));
    setValue(newValue);
  };

  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        placeholder="Key"
        placeholderTextColor={colorScheme.outline}
        value={key}
        onChangeText={setKey}
      />
      <TextInput
        style={styles.input}
        placeholder="Value"
        placeholderTextColor={colorScheme.outline}
        value={value}
        onChangeText={updateParameter}
      />
      <MaterialIconButton
        icon="delete"
        size={24}
        color={colorScheme.onErrorContainer}
        onPress={props.onDelete}
      />
    </View>
  );
}

export default ParameterView;
