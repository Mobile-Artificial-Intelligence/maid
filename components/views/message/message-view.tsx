import MessageContentView from "@/components/views/message/content-view";
import MessageControlsView from "@/components/views/message/controls-view";
import MessageRoleView from "@/components/views/message/role-view";
import { MessageNode } from "message-nodes";
import { StyleSheet, View } from "react-native";


function MessageView({ message }: { message: MessageNode }) {
  const styles = StyleSheet.create({
    view: {
      flexDirection: "column",
      alignItems: "flex-start",
      marginVertical: 12,
      marginHorizontal: 4,
    },
    mainRow: {
      flexDirection: "row",
      marginBottom: 8,
      justifyContent: "space-between",
      width: "100%",
    }
  });

  return (
    <View style={styles.view}>
      <View style={styles.mainRow}>
        <MessageRoleView message={message} />
        <MessageControlsView message={message} />
      </View>
      <MessageContentView message={message} />
    </View>
  );
}

export default MessageView;
