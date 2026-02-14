import { useLLM, useSystem } from "@/context";
import { StyleSheet, TextInput } from "react-native";

function ApiKeyField() {
  const { apiKey, setApiKey } = useLLM();
  const { colorScheme } = useSystem();

  const styles = StyleSheet.create({
    input: {
      color: colorScheme.onSurface,
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 30,
      fontSize: 16,
      paddingVertical: 12,
      paddingHorizontal: 16,
      width: "100%",
    }
  });

  if (!setApiKey) {
    return null;
  }

  return (
    <TextInput
      style={styles.input}
      placeholder="API Key"
      placeholderTextColor={colorScheme.onSurface}
      underlineColorAndroid="transparent"
      value={apiKey}
      onChangeText={setApiKey}
    />
  );
}

export default ApiKeyField;