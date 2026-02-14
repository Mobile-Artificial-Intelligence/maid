import { MaterialIconButton } from "@/components/buttons/icon-button";
import MenuButton from "@/components/buttons/menu-button";
import ModelButton from "@/components/buttons/model-button";
import ModelDropdown from "@/components/dropdowns/model-dropdown";
import { useLLM, useSystem } from "@/context";
import { StyleSheet, View } from "react-native";

interface HeaderProps { 
  openDrawer: () => void 
}

function Header(props: HeaderProps) {
  const { type } = useLLM();
  const { colorScheme } = useSystem();

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
  });

  return (
    <View style={styles.root}>
      <MaterialIconButton
        icon="menu"
        size={28}
        onPress={props.openDrawer}
      />
      {type === "Llama" ? <ModelButton /> : <ModelDropdown small />}
      <MenuButton />
    </View>
  );
}

export default Header;