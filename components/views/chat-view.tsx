import PromptInput from "@/components/fields/prompt-input";
import MessageView from "@/components/views/message-view";
import { useSystem } from "@/context";
import { randomUUID } from "expo-crypto";
import { getConversation, hasNode, MessageNode } from "message-nodes";
import { FlatList, StyleSheet, View } from "react-native";

interface ChatViewProps {
  id?: string | undefined;
}

function ChatView({ id }: ChatViewProps) {
  const { colorScheme, mappings } = useSystem();

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

  if (id && !hasNode(mappings, id)) {
    console.warn(`No conversation found for id ${id}`);
  }

  return (
    <View
      style={styles.view}
    >
      {id ? (
        <FlatList
          data={getConversation(mappings, id).slice(1)}
          style={styles.list}
          keyExtractor={(item) => item.id?.toString() ?? randomUUID()}
          renderItem={renderItem}
        />
      ) : <View style={styles.list} />}
      <PromptInput root={id} />
    </View>
  );
}

export default ChatView;