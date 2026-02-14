import ClearButtons from "@/components/buttons/clear-buttons";
import AssistantSettings from "@/components/settings/assistant-settings";
import ModelSettings from "@/components/settings/model-settings";
import SystemSettings from "@/components/settings/system-settings";
import UserSettings from "@/components/settings/user-settings";
import { useSystem } from "@/context";
import { ScrollView, StyleSheet, View } from "react-native";

function Settings() {
  const { colorScheme } = useSystem();
  
  const styles = StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: colorScheme.surface,
      paddingVertical: 8,
    },
    content: {
      flexDirection: "column",
      paddingBottom: 16,
    },
    divider: {
      height: 2,
      backgroundColor: colorScheme.outline,
      marginHorizontal: 18,
      marginVertical: 12,
      borderRadius: 1,
    }
  });

  return (
    <ScrollView
      style={styles.container} 
      contentContainerStyle={styles.content}
    >
      <ModelSettings />
      <View style={styles.divider} />
      <UserSettings />
      <View style={styles.divider} />
      <AssistantSettings />
      <View style={styles.divider} />
      <SystemSettings />
      <View style={styles.divider} />
      <ClearButtons />
    </ScrollView>
  );
}

export default Settings;