import PromptInputGroup from "@/components/groups/prompt-input-group";
import MessageView from "@/components/views/message/message-view";
import { useChat, useSystem } from "@/context";
import { randomUUID } from "expo-crypto";
import { getConversation, hasNode, MessageNode } from "message-nodes";
import { FlatList, StyleSheet, View } from "react-native";
import Animated, { useAnimatedKeyboard, useAnimatedStyle } from "react-native-reanimated";

function Chat() {
  const { colorScheme } = useSystem();
  const { mappings, root } = useChat();
  const keyboard = useAnimatedKeyboard();

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
    },
    list: {
      flex: 1,
      width: "100%",
    },
  });

  const animatedStyle = useAnimatedStyle(() => ({
    paddingBottom: keyboard.height.value,
  }));

  if (root && !hasNode(mappings, root)) {
    console.warn(`No conversation found for id ${root}`);
  }

  return (
    <Animated.View
      testID="chat-page"
      style={[styles.view, animatedStyle]}
    >
      {root ? <FlatList
        data={getConversation(mappings, root).slice(1)}
        style={styles.list}
        keyExtractor={(item) => item.id?.toString() ?? randomUUID()}
        renderItem={renderItem}
      /> : <View style={styles.list} />}
      <PromptInputGroup />
    </Animated.View>
  );
}

export default Chat;
