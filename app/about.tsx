import LogEntryView from "@/components/views/log-entry-view";
import { useSystem } from "@/context";
import { getLogs } from "@/utilities/logger";
import * as Application from "expo-application";
import * as Device from "expo-device";
import { StyleSheet, Text, View } from "react-native";
import { ScrollView } from "react-native-gesture-handler";

function About() {
  const { colorScheme } = useSystem();

  const logs = getLogs();
  
  const styles = StyleSheet.create({
    view: {
      flex: 1,
      flexDirection: "column",
      backgroundColor: colorScheme.surface,
      paddingHorizontal: 16,
      paddingVertical: 8,
      gap: 16
    },
    row: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
    },
    label: {
      color: colorScheme.onSurface,
      fontSize: 14,
    },
    value: {
      color: colorScheme.outline,
      fontSize: 14,
    },
    title: {
      marginTop: 16,
      textAlign: "center",
      color: colorScheme.onSurface,
      fontSize: 18,
      fontWeight: "bold",
    },
    logView: { 
      flex: 1, 
      backgroundColor: colorScheme.surfaceVariant, 
      padding: 10, 
      borderRadius: 8 
    },
    scrollView: { 
      flexGrow: 1 
    }
  });

  return (
    <View
      testID="about-page"
      style={styles.view}
    >
      <View style={styles.row}>
        <Text style={styles.label}>App Version</Text>
        <Text style={styles.value}>{Application.nativeApplicationVersion}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>App Build</Text>
        <Text style={styles.value}>{Application.nativeBuildVersion}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>Device Name</Text>
        <Text style={styles.value}>{Device.modelName}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>RAM</Text>
        <Text style={styles.value}>{((Device.totalMemory ?? 0) / (1024 * 1024 * 1024)).toFixed(2)} GB</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>CPU</Text>
        <Text style={styles.value}>{Device.supportedCpuArchitectures?.join(", ")}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>OS Version</Text>
        <Text style={styles.value}>{Device.osVersion}</Text>
      </View>
      <View style={styles.row}>
        <Text style={styles.label}>OS Build</Text>
        <Text style={styles.value}>{Device.osBuildId}</Text>
      </View>
      <Text style={styles.title}>Logs</Text>
      <View style={styles.logView}>
        <ScrollView contentContainerStyle={styles.scrollView}>
          <ScrollView
            horizontal
            contentContainerStyle={styles.scrollView}
            showsHorizontalScrollIndicator
          >
            <View>
              {logs.map((log, index) => (
                <LogEntryView key={index} entry={log} />
              ))}
            </View>
          </ScrollView>
        </ScrollView>
      </View>
    </View>
  );
}

export default About;