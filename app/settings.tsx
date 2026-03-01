import ClearButtons from "@/components/buttons/clear-buttons";
import AssistantSettingsGroup from "@/components/groups/assistant-settings-group";
import ModelSettingsGroup from "@/components/groups/model-settings-group";
import SystemSettingsGroup from "@/components/groups/system-settings-group";
import ThemeSettingsGroup from "@/components/groups/theme-settings-group";
import UserSettingsGroup from "@/components/groups/user-settings-group";
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
      <ModelSettingsGroup />
      <View style={styles.divider} />
      <UserSettingsGroup />
      <View style={styles.divider} />
      <AssistantSettingsGroup />
      <View style={styles.divider} />
      <SystemSettingsGroup />
      <View style={styles.divider} />
      <ThemeSettingsGroup />
      <View style={styles.divider} />
      <ClearButtons />
    </ScrollView>
  );
}

export default Settings;