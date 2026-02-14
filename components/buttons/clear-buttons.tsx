import { useSystem } from "@/context";
import AsyncStorage from '@react-native-async-storage/async-storage';
import { StyleSheet, Text, TouchableOpacity, View } from "react-native";

function ClearButtons() {
  const { colorScheme } = useSystem();

  async function clearAll() {
    try {
      await AsyncStorage.clear();
      console.log('AsyncStorage cleared!');
    } catch (e) {
      console.error('Failed to clear AsyncStorage:', e);
    }
  }

  const styles = StyleSheet.create({
    view: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "center",
      gap: 16
    },
    button: {
      color: colorScheme.primary,
      backgroundColor: colorScheme.surfaceVariant,
      paddingVertical: 8,
      paddingHorizontal: 16,
      borderRadius: 20,
    },
  });

  return (
    <View style={styles.view}>
      <TouchableOpacity onPress={clearAll}>
        <Text style={styles.button}>Clear Cache</Text>
      </TouchableOpacity>
    </View>
  );
}

export default ClearButtons;