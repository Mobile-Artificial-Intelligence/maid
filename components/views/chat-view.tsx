import PromptInput from "@/components/fields/prompt-input";
import MessageView from "@/components/views/message-view";
import { useChat, useSystem } from "@/context";
import { randomUUID } from "expo-crypto";
import { getConversation, hasNode, MessageNode } from "message-nodes";
import { FlatList, StyleSheet, View } from "react-native";

function ChatView() {
  const { mappings, root } = useChat();
  const { colorScheme } = useSystem();

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
  });

  if (root && !hasNode(mappings, root)) {
    console.warn(`No conversation found for id ${root}`);
  }

  return (
    <View
      style={styles.view}
    >
      {root ? (
        <FlatList
          data={getConversation(mappings, root).slice(1)}
          style={styles.list}
          keyExtractor={(item) => item.id?.toString() ?? randomUUID()}
          renderItem={renderItem}
        />
      ) : <View style={styles.list} />}
      <PromptInput />
    </View>
  );
}

export default ChatView;