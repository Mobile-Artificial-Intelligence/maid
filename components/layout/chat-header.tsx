import { MaterialIconButton } from "@/components/buttons/icon-button";
import MenuButton from "@/components/buttons/menu-button";
import ModelButton from "@/components/buttons/model-button";
import ModelDropdown from "@/components/dropdowns/model-dropdown";
import { useLLM, useSystem } from "@/context";
import { DrawerHeaderProps } from "@react-navigation/drawer";
import { StyleSheet, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

function Header(props: DrawerHeaderProps) {
  const { type } = useLLM();
  const { colorScheme } = useSystem();
  const insets = useSafeAreaInsets();

  const styles = StyleSheet.create({
    root: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      paddingHorizontal: 8,
      paddingTop: insets.top + 12,
      paddingBottom: 4,
      backgroundColor: colorScheme.surface,
    },
  });

  return (
    <View style={styles.root}>
      <MaterialIconButton
        testID="open-drawer-button"
        icon="menu"
        size={28}
        onPress={props.navigation.openDrawer}
      />
      {type === "Llama" ? <ModelButton /> : <ModelDropdown small />}
      <MenuButton />
    </View>
  );
}

export default Header;