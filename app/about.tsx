import { useSystem } from "@/context";
import { StyleSheet, Text, View } from "react-native";

function About() {
  const { colorScheme } = useSystem();
  
  const styles = StyleSheet.create({
    view: {
      flex: 1,
      flexDirection: "column",
      backgroundColor: colorScheme.surface,
      paddingHorizontal: 16,
      paddingVertical: 8,
    }
  });

  return (
    <View
      style={styles.view}
    >
      <Text>
        About
      </Text>
    </View>
  );
}

export default About;