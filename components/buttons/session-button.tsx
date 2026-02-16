import Popover from "@/components/views/popover-view";
import { useSystem } from "@/context";
import * as FileSystem from "expo-file-system";
import { deleteNode, getRootMapping, MessageNode } from "message-nodes";
import { useRef, useState } from "react";
import { LayoutRectangle, StyleSheet, Text, TouchableOpacity } from "react-native";

function SessionButton({ node }: { node: MessageNode<string> }) {
  const { colorScheme, root, setRoot, mappings, setMappings } = useSystem();
  const [visible, setVisible] = useState(false);
  const [anchor, setAnchor] = useState<LayoutRectangle | null>(null);
  const anchorRef = useRef<Text>(null);

  const open = () => {
    anchorRef.current?.measureInWindow((x, y, width, height) => {
      setAnchor({ x, y, width, height });
      setVisible(true);
    });
  };

  const exportChat = async () => {
    const rootMapping = getRootMapping<string>(mappings, node.id);

    const filename = `${node.metadata?.title || "New Chat"}.json`;

    const json = JSON.stringify(rootMapping, null, 2);

    const perms = await FileSystem.StorageAccessFramework.requestDirectoryPermissionsAsync();
    if (!perms.granted) return;

    const fileUri = await FileSystem.StorageAccessFramework.createFileAsync(
      perms.directoryUri,
      filename,
      "application/json"
    );

    await FileSystem.writeAsStringAsync(fileUri, json, {
      encoding: FileSystem.EncodingType.UTF8,
    });
  }

  const deleteChat = () => {
    if (root === node.id) {
      setRoot(undefined);
    }
    setMappings((prev) => deleteNode(prev, node.id));
  }

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
    },
    popoverButton: {
      paddingVertical: 8,
      paddingHorizontal: 12,
      color: colorScheme.onSurface,
      fontSize: 16,
    },
  });
    
  return (
    <>
      <TouchableOpacity
        key={`${node.id}-button`}
        style={styles.button}
        onPress={() => setRoot(node.id)}
        onLongPress={open}
      >
        <Text
          ref={anchorRef}
          style={[
            styles.buttonText,
            root === node.id ? styles.buttonTextActive : null
          ]}
          numberOfLines={1}
        >
          {node.metadata?.title || "New Chat"}
        </Text>
      </TouchableOpacity>
      <Popover
        position="bottom"
        anchor={anchor}
        offset={{ y: (anchor?.height ?? 0) }}
        width={120}
        visible={visible}
        onClose={() => setVisible(false)}
      >
        <TouchableOpacity
          onPress={() => {
            
          }}
        >
          <Text style={styles.popoverButton}>Rename</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={exportChat}
        >
          <Text style={styles.popoverButton}>Export</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={deleteChat}
        >
          <Text style={styles.popoverButton}>Delete</Text>
        </TouchableOpacity>
      </Popover>
    </>
  );
}

export default SessionButton;