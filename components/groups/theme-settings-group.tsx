import { useSystem } from "@/context";
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from "react-native";
import ColorPicker, { HueSlider } from "reanimated-color-picker";

interface AccentPreset {
  name: string;
  color: string;
  icon: string;
}

const ACCENT_PRESETS: AccentPreset[] = [
  { name: "Cyber Green", color: "#00FF66", icon: "🟢" },
  { name: "Blood Red", color: "#FF0033", icon: "🔴" },
  { name: "Cyber Purple", color: "#B829FF", icon: "🟣" },
  { name: "Electric Cyan", color: "#00E5FF", icon: "🔵" },
  { name: "Terminal Amber", color: "#FFB703", icon: "🟡" },
  { name: "Classic Blue", color: "#2196F3", icon: "💎" },
];

function ThemeSettingsGroup() {
  const { colorScheme, accentColor, setAccentColor } = useSystem();

  const styles = StyleSheet.create({
    view: {
      alignItems: "center",
      justifyContent: "flex-start",
      gap: 16,
      paddingHorizontal: 16,
      width: "100%",
    },
    title: {
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold"
    },
    subtitle: {
      color: colorScheme.secondary,
      fontSize: 13,
      textAlign: "center",
    },
    presetsRow: {
      flexDirection: "row",
      alignItems: "center",
      marginVertical: 4,
    },
    presetButton: {
      flexDirection: "row",
      alignItems: "center",
      paddingVertical: 6,
      paddingHorizontal: 12,
      borderRadius: 16,
      borderWidth: 1,
      borderColor: colorScheme.outlineVariant,
      backgroundColor: colorScheme.surfaceVariant,
      marginRight: 8,
      gap: 6,
    },
    presetButtonActive: {
      borderColor: colorScheme.primary,
      borderWidth: 2,
    },
    colorDot: {
      width: 14,
      height: 14,
      borderRadius: 7,
    },
    presetName: {
      color: colorScheme.onSurface,
      fontSize: 13,
      fontWeight: "600",
    },
    colorPicker: {
      width: "100%",
    }
  });

  return (
    <View style={styles.view}>
      <Text style={styles.title}>Theme & Cyber Accent Color 🎨</Text>
      <Text style={styles.subtitle}>
        Select a Cyber/OLED color preset or slide to customize:
      </Text>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.presetsRow}
      >
        {ACCENT_PRESETS.map((preset) => {
          const isActive = accentColor.toUpperCase() === preset.color.toUpperCase();
          return (
            <TouchableOpacity
              key={preset.color}
              style={[styles.presetButton, isActive && styles.presetButtonActive]}
              onPress={() => setAccentColor(preset.color)}
            >
              <View style={[styles.colorDot, { backgroundColor: preset.color }]} />
              <Text style={styles.presetName}>{preset.icon} {preset.name}</Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>

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

export default ThemeSettingsGroup;
