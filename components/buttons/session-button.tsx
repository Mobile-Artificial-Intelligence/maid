import { useSystem } from "@/context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { MessageNode } from "message-nodes";
import { StyleSheet, Text, TouchableOpacity } from "react-native";

function SessionButton({ node }: { node: MessageNode<string> }) {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id?: string }>();
  const { colorScheme } = useSystem();

  const styles = StyleSheet.create({
    view: {
      flexDirection: "column"
    },
    button: {
      paddingVertical: 12,
      paddingHorizontal: 18,
      width: "100%",
    },
    buttonText: {
      color: colorScheme.onSurface,
      fontSize: 16,
    },
    buttonTextActive: {
      color: colorScheme.primary
    }
  });

  const onSwitch = () => {
    router.replace(`/chat/${node.id}`);
  }
    
  return (
    <TouchableOpacity
      key={`${node.id}-button`}
      style={styles.button}
      onPress={onSwitch}
    >
      <Text
        style={[
          styles.buttonText,
          id === node.id ? styles.buttonTextActive : null
        ]}
        numberOfLines={1}
      >
        {node.content}
      </Text>
    </TouchableOpacity>
  );
}

export default SessionButton;