import FindOllamaButton from "@/components/buttons/find-ollama-button";
import ModelFileButtons from "@/components/buttons/model-file-buttons";
import ApiDropdown from "@/components/dropdowns/api-dropdown";
import ModelDropdown from "@/components/dropdowns/model-dropdown";
import VoiceDropdown from "@/components/dropdowns/voice-dropdown";
import ApiKeyField from "@/components/fields/api-key-field";
import BaseUrlField from "@/components/fields/base-url-field";
import HeaderView from "@/components/views/header-view";
import ParameterView from "@/components/views/parameter-view";
import { useSystem } from "@/context";
import { StyleSheet, Text, View } from "react-native";

function ModelSettings() {
  const { colorScheme } = useSystem();

  const styles = StyleSheet.create({
    view: {
      alignItems: "center",
      justifyContent: "flex-start",
      gap: 16,
      paddingHorizontal: 16
    },
    title: {
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold"
    }
  });

  return (
    <View style={styles.view}>
      <Text style={styles.title}>Model Settings</Text>
      <VoiceDropdown />
      <ApiDropdown />
      <ModelDropdown />
      <ModelFileButtons />
      <FindOllamaButton />
      <BaseUrlField />
      <ApiKeyField />
      <HeaderView />
      <ParameterView />
    </View>
  );
}

export default ModelSettings;