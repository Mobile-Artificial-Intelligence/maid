import { useSystem } from "@/context";
import { Dispatch, SetStateAction } from "react";
import { StyleSheet, TextInput } from "react-native";

interface PromptInputFieldProps {
  promptText: string; 
  setPromptText: Dispatch<SetStateAction<string>>;
};

function PromptInputField({ promptText, setPromptText }: PromptInputFieldProps) {
  const { colorScheme } = useSystem();

  const styles = StyleSheet.create({
    input: {
      color: colorScheme.onSurface,
      fontSize: 16,
      flex: 1,
      borderWidth: 0,
      marginHorizontal: 8,
    }
  });

  return (
    <TextInput
      testID="prompt-input"
      style={styles.input}
      placeholder="Type a message..."
      placeholderTextColor={colorScheme.onSurface}
      underlineColorAndroid="transparent"
      multiline
      value={promptText}
      onChangeText={setPromptText}
    />
  );
}

export default PromptInputField;
