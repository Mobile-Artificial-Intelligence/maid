import Dropdown from "@/components/dropdowns/dropdown";
import { useLLM, useSystem } from "@/context";
import { LanguageModelTypes } from "@/context/language-model";
import { StyleSheet, Text, View } from "react-native";

function ApiDropdown() {
  const { type, setType } = useLLM();
  const { colorScheme } = useSystem();

  const styles = StyleSheet.create({
    view: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
      width: "100%",
    },
    title: {
      color: colorScheme.onSurface,
      fontSize: 16
    }
  });

  const items = LanguageModelTypes.map((type) => {
    return {
      label: type,
      value: type
    }
  });

  return (
    <View style={styles.view}>
      <Text style={styles.title}>
        Language Model API
      </Text>
      <Dropdown
        items={items}
        selectedValue={type}
        onValueChange={setType}
      />
    </View>
  );
}

export default ApiDropdown;