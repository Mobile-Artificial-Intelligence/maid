import { useLLM, useSystem } from "@/context";
import { StyleSheet, TextInput } from "react-native";

function BaseUrlField() {
  const { baseURL, setBaseURL } = useLLM();
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

  if (!setBaseURL) {
    return null;
  }

  return (
    <TextInput
      style={styles.input}
      placeholder="Base URL"
      placeholderTextColor={colorScheme.onSurface}
      underlineColorAndroid="transparent"
      value={baseURL}
      onChangeText={setBaseURL}
    />
  );
}

export default BaseUrlField;