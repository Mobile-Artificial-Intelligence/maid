import { MaterialIconButton } from "@/components/buttons/icon-button";
import MenuButton from "@/components/buttons/menu-button";
import ModelButton from "@/components/buttons/model-button";
import ModelDropdown from "@/components/dropdowns/model-dropdown";
import { useLLM, useSystem } from "@/context";
import { DrawerHeaderProps } from "@react-navigation/drawer";
import { StyleSheet, Text, View } from "react-native";

function Header(props: DrawerHeaderProps) {
  const { type } = useLLM();
  const { colorScheme, systemPrompt } = useSystem();

  const isUncensored = systemPrompt && (
    systemPrompt.toLowerCase().includes("uncensored") ||
    systemPrompt.toLowerCase().includes("unrestricted") ||
    systemPrompt.toLowerCase().includes("red-team")
  );

  const styles = StyleSheet.create({
    root: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      paddingHorizontal: 8,
      paddingTop: 12,
      paddingBottom: 4,
      backgroundColor: colorScheme.surface,
    },
    titleGroup: {
      flexDirection: "row",
      alignItems: "center",
      gap: 6,
    },
    brandTitle: {
      color: colorScheme.onSurface,
      fontSize: 18,
      fontWeight: "900",
      letterSpacing: 0.5,
    },
    badge: {
      backgroundColor: isUncensored ? "#FF003320" : colorScheme.surfaceVariant,
      borderColor: isUncensored ? "#FF0033" : colorScheme.outline,
      borderWidth: 1,
      paddingHorizontal: 6,
      paddingVertical: 2,
      borderRadius: 6,
    },
    badgeText: {
      color: isUncensored ? "#FF3355" : colorScheme.primary,
      fontSize: 10,
      fontWeight: "800",
    },
    rightControls: {
      flexDirection: "row",
      alignItems: "center",
      gap: 4,
    }
  });

  return (
    <View style={styles.root}>
      <View style={styles.titleGroup}>
        <MaterialIconButton
          testID="open-drawer-button"
          icon="menu"
          size={28}
          onPress={props.navigation.openDrawer}
        />
        <Text style={styles.brandTitle}>Prime AI</Text>
        <View style={styles.badge}>
          <Text style={styles.badgeText}>
            {isUncensored ? "☠️ UNCENSORED" : "⚡ AI SUITE"}
          </Text>
        </View>
      </View>

      <View style={styles.rightControls}>
        {type === "Llama" ? <ModelButton /> : <ModelDropdown small />}
        <MenuButton />
      </View>
    </View>
  );
}

export default Header;
