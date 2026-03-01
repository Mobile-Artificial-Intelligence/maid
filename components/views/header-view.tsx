import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useLLM, useSystem } from "@/context";
import { randomUUID } from "expo-crypto";
import { useEffect, useState } from "react";
import { StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

function HeaderView() {
  const { colorScheme } = useSystem();
  const { headers, setHeaders } = useLLM();
  const [keys, setKeys] = useState<string[]>(Object.keys(headers || {}));

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

  if (!headers || !setHeaders) return null;

  const addHeader = () => {
    const newKey = randomUUID();
    setKeys((prev) => [...prev, newKey]);
  }

  const clearHeaders = () => {
    setKeys([]);
    setHeaders({});
  }

  const onDelete = (headerKey: string) => {
    setKeys((prev) => prev.filter((key) => key !== headerKey));
    setHeaders((prev) => {
      const updated = { ...prev };
      delete updated[headerKey];
      return updated;
    });
  }

  return (
    <View style={styles.container}>
      <Text
        style={styles.title}
      >
        Request Headers
      </Text>
      <View style={styles.buttonRow}>
        <TouchableOpacity
          onPress={addHeader}
        >
          <Text style={styles.button}>
            Add Header
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={clearHeaders}
        >
          <Text style={styles.button}>
            Clear Headers
          </Text>
        </TouchableOpacity>
      </View>
      {keys.map((key) => (
        <HeaderViewItem
          key={key}
          headerKey={key}
          value={headers[key]}
          onDelete={() => onDelete(key)}
        />
      ))}
    </View>
  );
}

interface HeaderViewItemProps {
  headerKey: string;
  value?: string;
  onDelete: () => void;
}

function HeaderViewItem(props: HeaderViewItemProps) {
  const { colorScheme } = useSystem();
  const { headers, setHeaders } = useLLM();

  const regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const initialKey = regex.test(props.headerKey) ? "" : props.headerKey;
  const [oldKey, setOldKey] = useState<string>("");
  const [key, setKey] = useState<string>(initialKey);
  const [value, setValue] = useState<string>(String(props.value || headers?.[key] || ""));

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

  if (!headers || !setHeaders) return null;

  const updateKey = () => {
    if (key.trim() === "" || key === oldKey) return;

    setHeaders((prev: Record<string, string>) => { 
      const updated = { ...prev };
      delete updated[oldKey];
      return { ...updated, [key]: value };
    });

    setOldKey(key);
  }

  useEffect(() => {
    const handler = setTimeout(updateKey, 500);

    return () => clearTimeout(handler);
  }, [key]);

  const updateParameter = (newValue: string) => {
    if (key.trim() === "") return;

    setHeaders((prev: Record<string, string>) => ({ ...prev, [key]: newValue }));

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

export default HeaderView;