import { useSystem } from "@/context";
import { ImagePickerAsset } from "expo-image-picker";
import { useMemo, useState } from "react";
import { StyleSheet, Text, TouchableOpacity, View } from "react-native";
import PromptButton from "../buttons/prompt-button";
import PromptImageButton from "../buttons/prompt-image-button";
import PromptInputField from "../fields/prompt-input-field";
import PromptImagesView from "../views/prompt-images-view";

function PromptInputGroup() {
  const { colorScheme } = useSystem();

  const [promptText, setPromptText] = useState<string>("");
  const [images, setImages] = useState<Array<ImagePickerAsset>>([]);

  const styles = useMemo(
    () =>
      StyleSheet.create({
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
          fontSize: 14,
        },
      }),
    [colorScheme],
  );

  return (
    <View
      style={styles.root}
    >
      {promptText.length > 0 && (
        <TouchableOpacity
          testID="clear-prompt-button"
          onPress={() => setPromptText("")}
        >
          <Text 
            style={styles.clearButtonText}
          >
            Clear Prompt
          </Text>
        </TouchableOpacity>
      )}
      {images.length > 0 && (
        <PromptImagesView 
          images={images} 
          setImages={setImages} 
        />
      )}
      <View style={styles.inputView}>
        <PromptImageButton 
          setImages={setImages} 
        />
        <PromptInputField 
          promptText={promptText} 
          setPromptText={setPromptText} 
        />
        <PromptButton 
          promptText={promptText} 
          setPromptText={setPromptText} 
        />
      </View>
    </View>
  );
}

export default PromptInputGroup;
