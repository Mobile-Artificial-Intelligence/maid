import { useSystem } from "@/context";
import { StyleSheet, Text, View } from "react-native";
import ColorPicker, { HueSlider } from "reanimated-color-picker";

function ThemeSettings() {
  const { colorScheme, accentColor, setAccentColor } = useSystem();

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
    },
    colorPicker: {
      width: "100%",
    }
  });

  return (
    <View style={styles.view}>
      <Text style={styles.title}>Accent Color</Text>
      <ColorPicker
        style={styles.colorPicker}
        value={accentColor}
        onCompleteJS={(color) => setAccentColor(color.hex)}
      >
        <HueSlider />
      </ColorPicker>  
    </View>
  );
}

export default ThemeSettings;