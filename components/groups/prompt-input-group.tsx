import { useSystem } from "@/context";
import { useState } from "react";
import { StyleSheet, Text, TouchableOpacity, View } from "react-native";
import PromptButton from "../buttons/prompt-button";
import PromptInputField from "../fields/prompt-input-field";

function PromptInputGroup() {
  const { colorScheme } = useSystem();

  const [promptText, setPromptText] = useState<string>("");

  const styles = StyleSheet.create({
    root: {
      flexDirection: "column",
      alignItems: "center",
    },
    inputView: {
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 30,
      flexDirection: "row",
      alignItems: "center",
      paddingVertical: 4,
      paddingHorizontal: 12,
      marginTop: 8,
      alignSelf: "stretch",
    },
    clearButtonText: { 
      color: colorScheme.primary, 
      paddingVertical: 8,
      fontSize: 14
    },
  });

  return (
    <View
      style={styles.root}
    >
      {promptText.length > 0 && (
        <TouchableOpacity
          testID="clear-prompt-button"
          onPress={() => setPromptText("")}
        >
          <Text style={styles.clearButtonText}>Clear Prompt</Text>
        </TouchableOpacity>
      )}
      <View style={styles.inputView}>
        <PromptInputField promptText={promptText} setPromptText={setPromptText} />
        <PromptButton promptText={promptText} setPromptText={setPromptText} />
      </View>
    </View>
  );
}

export default PromptInputGroup;
