import { useSystem } from "@/context";
import { useState } from "react";
import { StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";
import PromptButton from "../buttons/prompt-button";

function PromptInput() {
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
    input: {
      color: colorScheme.onSurface,
      fontSize: 16,
      flex: 1,
      borderWidth: 0,
      marginHorizontal: 8,
    },
    clearButtonText: { 
      color: colorScheme.onPrimary, 
      backgroundColor: colorScheme.primary,
      paddingVertical: 8,
      paddingHorizontal: 16,
      borderRadius: 20,
      fontSize: 14
    },
    imageScrollView: { 
      paddingVertical: 8,
      marginTop: 4, 
    },
    imageContainer: { 
      marginHorizontal: 4, 
      position: "relative" 
    },
    imageButton: {
      position: "absolute",
      top: -10,
      right: -10,
      zIndex: 1,
      backgroundColor: colorScheme.surfaceVariant, 
      borderRadius: 12 
    },
    image: { 
      width: 100, 
      height: 100, 
      borderRadius: 8 
    }
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
        <PromptButton promptText={promptText} setPromptText={setPromptText} />
      </View>
    </View>
  );
}

export default PromptInput;
