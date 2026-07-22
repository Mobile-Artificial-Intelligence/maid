import PromptInputGroup from "@/components/groups/prompt-input-group";
import MessageView from "@/components/views/message/message-view";
import { useChat, useSystem } from "@/context";
import { randomUUID } from "expo-crypto";
import { getConversation, hasNode, MessageNode } from "message-nodes";
import { FlatList, StyleSheet, View } from "react-native";
import { KeyboardAvoidingView } from "react-native-keyboard-controller";
import { useSafeAreaInsets } from "react-native-safe-area-context";

function Chat() {
  const { colorScheme } = useSystem();
  const { mappings, root } = useChat();
  const insets = useSafeAreaInsets();

  const renderItem = ({ item }: { item: MessageNode }) => (
    <MessageView
      key={item.id}
      message={item}
    />
  );

  const styles = StyleSheet.create({
    view: {
      flex: 1,
      flexDirection: "column",
      backgroundColor: colorScheme.surface,
      padding: 8,
    },
    list: {
      flex: 1,
      width: "100%",
    },
    composer: {
      paddingBottom: insets.bottom,
    },
  });

  if (root && !hasNode(mappings, root)) {
    console.warn(`No conversation found for id ${root}`);
  }

  return (
    // The composer already sits `insets.bottom` above the screen edge, so the
    // keyboard only needs to make up the difference - hence the negative offset.
    // Combined, the space below the composer is `insets.bottom` when the keyboard
    // is closed and the full keyboard height when it is open.
    <KeyboardAvoidingView
      testID="chat-page"
      behavior="padding"
      automaticOffset
      keyboardVerticalOffset={-insets.bottom}
      style={styles.view}
    >
      {root ? <FlatList
        data={getConversation(mappings, root).slice(1)}
        style={styles.list}
        keyExtractor={(item) => item.id?.toString() ?? randomUUID()}
        renderItem={renderItem}
      /> : <View style={styles.list} />}
      <View style={styles.composer}>
        <PromptInputGroup />
      </View>
    </KeyboardAvoidingView>
  );
}

export default Chat;
