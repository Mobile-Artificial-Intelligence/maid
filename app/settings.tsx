import ClearButtons from "@/components/buttons/clear-buttons";
import AssistantSettingsView from "@/components/views/settings/assistant-settings-view";
import ModelSettingsView from "@/components/views/settings/model-settings-view";
import SystemSettingsView from "@/components/views/settings/system-settings-view";
import ThemeSettingsView from "@/components/views/settings/theme-settings-view";
import UserSettingsView from "@/components/views/settings/user-settings-view";
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
      testID="settings-page"
      style={styles.container} 
      contentContainerStyle={styles.content}
    >
      <ModelSettingsView />
      <View style={styles.divider} />
      <UserSettingsView />
      <View style={styles.divider} />
      <AssistantSettingsView />
      <View style={styles.divider} />
      <SystemSettingsView />
      <View style={styles.divider} />
      <ThemeSettingsView />
      <View style={styles.divider} />
      <ClearButtons />
    </ScrollView>
  );
}

export default Settings;