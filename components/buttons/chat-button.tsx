import Popover from "@/components/views/popover-view";
import { useChat, useSystem } from "@/context";
import * as FileSystem from "expo-file-system";
import { deleteNode, getRootMapping, MessageNode, updateContent } from "message-nodes";
import { useEffect, useRef, useState } from "react";
import { LayoutRectangle, StyleSheet, Text, TextInput, TouchableOpacity } from "react-native";

function ChatButton({ node }: { node: MessageNode<string> }) {
  const { root, setRoot, mappings, setMappings } = useChat();
  const { colorScheme } = useSystem();
  const [visible, setVisible] = useState<boolean>(false);
  const [rename, setRename] = useState<boolean>(false);
  const [renameEvent, setRenameEvent] = useState<string>("");
  const [anchor, setAnchor] = useState<LayoutRectangle | null>(null);
  const anchorRef = useRef<Text>(null);

  useEffect(() => {
    if (!rename) return;

    const timeout = setTimeout(() => setRename(false), 5000);

    return () => clearTimeout(timeout);
  }, [rename, renameEvent]);

  const open = () => {
    anchorRef.current?.measureInWindow((x, y, width, height) => {
      setAnchor({ x, y, width, height });
      setVisible(true);
    });
  };

  const renameChat = (title: string) => {
    setMappings((prev) => updateContent<string, Record<string, any>>(prev, node.id, c => c, m => ({ ...m, title })));
    setRename(false);
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
      {!rename && <TouchableOpacity
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
      </TouchableOpacity>}
      {rename && <TextInput
        key={`${node.id}-textfield`}
        style={[
          styles.button, 
          styles.buttonText, 
          root === node.id ? styles.buttonTextActive : null
        ]}
        defaultValue={node.metadata?.title || "New Chat"}
        onChange={(e) => setRenameEvent(e.nativeEvent.text)}
        onEndEditing={(e) => renameChat(e.nativeEvent.text)}
        autoFocus
      />}
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
            setVisible(false);
            setRename(true);
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

export default ChatButton;