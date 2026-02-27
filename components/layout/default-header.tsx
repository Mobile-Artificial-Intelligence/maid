import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useSystem } from "@/context";
import { NativeStackHeaderProps } from "@react-navigation/native-stack";
import { StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

function DefaultHeader(props: NativeStackHeaderProps) {
  const { colorScheme } = useSystem();
  const insets = useSafeAreaInsets();

  const styles = StyleSheet.create({
    root: {
      flexDirection: "row",
      justifyContent: "flex-start",
      paddingHorizontal: 8,
      paddingTop: insets.top + 12,
      paddingBottom: 4,
      backgroundColor: colorScheme.surface,
      alignItems: "center",
    },
    backButton: {
      marginVertical: 4,
      marginLeft: 4,
      marginRight: 12,
    },
    title: {
      flex: 1,
      fontSize: 20,
      fontWeight: "bold",
      color: colorScheme.onSurface,
    }
  });

  const getTitle = () => {
    let name = props.route.name;

    if (name.indexOf("/") !== -1) {
      name = name.substring(0, name.indexOf("/"));
    }

    name = name.charAt(0).toUpperCase() + name.slice(1);

    return name;
  }

  return (
    <View 
      style={styles.root}
    >
      <MaterialIconButton
        testID="back-button"
        icon="arrow-back"
        size={28}
        style={styles.backButton}
        onPress={() => props.navigation.goBack()}
      />
      <Text
        style={styles.title}
      >
        {getTitle()}
      </Text>
    </View>
  );
}

export default DefaultHeader;