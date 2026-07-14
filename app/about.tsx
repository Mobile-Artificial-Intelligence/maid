import LogEntryView from "@/components/views/log-entry-view";
import { useSystem } from "@/context";
import { getLogs } from "@/utilities/logger";
import * as Application from "expo-application";
import * as Device from "expo-device";
import { ScrollView, StyleSheet, Text, View } from "react-native";

function About() {
  const { colorScheme } = useSystem();
  const logs = getLogs();
  
  const styles = StyleSheet.create({
    view: {
      flex: 1,
      flexDirection: "column",
      backgroundColor: colorScheme.surface,
      paddingHorizontal: 16,
      paddingVertical: 12,
      gap: 14
    },
    brandBox: {
      backgroundColor: colorScheme.surfaceVariant,
      padding: 16,
      borderRadius: 16,
      alignItems: "center",
      borderWidth: 1,
      borderColor: colorScheme.outlineVariant,
    },
    brandTitle: {
      color: colorScheme.onSurface,
      fontSize: 22,
      fontWeight: "900",
    },
    brandSubtitle: {
      color: colorScheme.primary,
      fontSize: 13,
      fontWeight: "700",
      marginTop: 4,
      textAlign: "center",
    },
    brandDesc: {
      color: colorScheme.secondary,
      fontSize: 12,
      textAlign: "center",
      marginTop: 8,
      lineHeight: 18,
    },
    row: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
    },
    label: {
      color: colorScheme.onSurface,
      fontSize: 14,
      fontWeight: "600",
    },
    value: {
      color: colorScheme.secondary,
      fontSize: 14,
    },
    title: {
      marginTop: 8,
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold",
    },
    logView: { 
      flex: 1, 
      backgroundColor: colorScheme.surfaceVariant, 
      padding: 10, 
      borderRadius: 12,
      borderWidth: 1,
      borderColor: colorScheme.outlineVariant,
    },
    scrollView: { 
      flexGrow: 1 
    }
  });

  return (
    <View testID="about-page" style={styles.view}>
      <View style={styles.brandBox}>
        <Text style={styles.brandTitle}>Prime AI Uncensored ☠️💀</Text>
        <Text style={styles.brandSubtitle}>Local & Remote Unrestricted Intelligence</Text>
        <Text style={styles.brandDesc}>
          Prime AI is equipped with an Uncensored Model Vault, Jailbreak Persona Presets, Cyber OLED Themes, and local GGUF execution via llama.rn.
        </Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>App Version</Text>
        <Text style={styles.value}>{Application.nativeApplicationVersion || "3.0.0-UNC"}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>App Build</Text>
        <Text style={styles.value}>{Application.nativeBuildVersion || "2776"}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>Device Name</Text>
        <Text style={styles.value}>{Device.modelName || "Simulator / Device"}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>RAM</Text>
        <Text style={styles.value}>{((Device.totalMemory ?? 0) / (1024 * 1024 * 1024)).toFixed(2)} GB</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>CPU Architectures</Text>
        <Text style={styles.value}>{Device.supportedCpuArchitectures?.join(", ") || "x86_64/arm64"}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>OS Version & Build</Text>
        <Text style={styles.value}>{Device.osVersion || "OS"} ({Device.osBuildId || "Build"})</Text>
      </View>

      <Text style={styles.title}>System Logs</Text>
      <View style={styles.logView}>
        <ScrollView contentContainerStyle={styles.scrollView}>
          <ScrollView
            horizontal
            contentContainerStyle={styles.scrollView}
            showsHorizontalScrollIndicator
          >
            <View>
              {logs.length > 0 ? (
                logs.map((log, index) => <LogEntryView key={index} entry={log} />)
              ) : (
                <Text style={{ color: colorScheme.secondary, fontSize: 13 }}>No logs captured yet.</Text>
              )}
            </View>
          </ScrollView>
        </ScrollView>
      </View>
    </View>
  );
}

export default About;
