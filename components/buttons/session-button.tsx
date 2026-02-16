import { useSystem } from "@/context";
import { MessageNode } from "message-nodes";
import { StyleSheet, Text, TouchableOpacity } from "react-native";

function SessionButton({ node }: { node: MessageNode<string> }) {
  const { colorScheme, root, setRoot } = useSystem();

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
    
  return (
    <TouchableOpacity
      key={`${node.id}-button`}
      style={styles.button}
      onPress={() => setRoot(node.id)}
    >
      <Text
        style={[
          styles.buttonText,
          root === node.id ? styles.buttonTextActive : null
        ]}
        numberOfLines={1}
      >
        {node.content}
      </Text>
    </TouchableOpacity>
  );
}

export default SessionButton;