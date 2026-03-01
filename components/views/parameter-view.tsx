import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useLLM, useSystem } from "@/context";
import { randomUUID } from "expo-crypto";
import { useEffect, useState } from "react";
import { StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

function ParameterView() {
  const { colorScheme } = useSystem();
  const { parameters, setParameters } = useLLM();
  const [keys, setKeys] = useState<string[]>(Object.keys(parameters));

  const styles = StyleSheet.create({
    container: {
      flexDirection: "column",
      justifyContent: "flex-start",
      alignItems: "center"
    },
    title: {
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold"
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
    },
  });

  const addParameter = () => {
    const newKey = randomUUID();
    setKeys((prev) => [...prev, newKey]);
  }

  const clearParameters = () => {
    setKeys([]);
    setParameters({});
  }

  const onDelete = (parameterKey: string) => {
    setKeys((prev) => prev.filter((key) => key !== parameterKey));
    setParameters((prev) => {
      const updated = { ...prev };
      delete updated[parameterKey];
      return updated;
    });
  }

  return (
    <View style={styles.container}>
      <Text
        style={styles.title}
      >
        Model Parameters
      </Text>
      <View style={styles.buttonRow}>
        <TouchableOpacity
          onPress={addParameter}
        >
          <Text style={styles.button}>
            Add Parameter
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={clearParameters}
        >
          <Text style={styles.button}>
            Clear Parameters
          </Text>
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
  let parsedValue: string | number | boolean = value;

  if (value.toLowerCase() === "true") {
    parsedValue = true;
  } else if (value.toLowerCase() === "false") {
    parsedValue = false;
  } else if (!isNaN(Number(value))) {
    parsedValue = Number(value);
  }

  return parsedValue;
}

function ParameterViewItem(props: ParameterViewItemProps) {
  const { colorScheme } = useSystem();
  const { parameters, setParameters } = useLLM();

  const regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const initialKey = regex.test(props.parameterKey) ? "" : props.parameterKey;
  const [oldKey, setOldKey] = useState<string>("");
  const [key, setKey] = useState<string>(initialKey);
  const [value, setValue] = useState<string>(String(props.value || parameters[key] || ""));

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
      borderRadius: 30,
      fontSize: 16,
      paddingVertical: 12,
      paddingHorizontal: 16,
      width: "40%",
    }
  });

  const updateKey = () => {
    if (key.trim() === "" || key === oldKey) return;

    const parsedValue = parseValue(value);

    setParameters((prev: Record<string, string | number | boolean>) => { 
      const updated = { ...prev };
      delete updated[oldKey];
      return { ...updated, [key]: parsedValue };
    });

    setOldKey(key);
  }

  useEffect(() => {
    const handler = setTimeout(updateKey, 500);

    return () => clearTimeout(handler);
  }, [key]);

  const updateParameter = (newValue: string) => {
    if (key.trim() === "") return;

    const parsedValue = parseValue(newValue);

    setParameters((prev: Record<string, string | number | boolean>) => ({ ...prev, [key]: parsedValue }));

    setValue(newValue);
  }

  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        placeholder="Key"
        placeholderTextColor={colorScheme.onSurface}
        value={key}
        onChangeText={setKey}
      />
      <TextInput
        style={styles.input}
        placeholder="Value"
        placeholderTextColor={colorScheme.onSurface}
        value={value}
        onChangeText={updateParameter}
      />
      <MaterialIconButton
        icon="delete"
        size={24}
        onPress={props.onDelete}
      />
    </View>
  );
}

export default ParameterView;