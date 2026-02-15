import AssistantImageView from "@/components/views/assistant-image-view";
import UserImageView from "@/components/views/user-image-view";
import { useSystem } from "@/context";
import Icon from '@expo/vector-icons/MaterialCommunityIcons';
import { MessageNode } from "message-nodes";
import { StyleSheet, Text, View } from "react-native";

function MessageRoleView({ message }: { message: MessageNode }) {
  const { userName, assistantName, colorScheme } = useSystem();

  const styles = StyleSheet.create({
    row: {
      flexDirection: "row",
      alignItems: "center",
    },
    role: {
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold",
      marginLeft: 8,
    },
  });
  
  let role = message.role.charAt(0).toUpperCase() + message.role.slice(1);
  if (message.role === "user" && userName) {
    role = userName;
  } 
  else if (message.role === "assistant" && assistantName) {
    role = assistantName;
  }

  let profile = (
    <Icon
      name="account-cog"
      size={26}
      color={colorScheme.onSurface}
    />
  );
  if (message.role === "user") {
    profile = (
      <UserImageView size={26} />
    )
  } 
  else if (message.role === "assistant") {
    profile = (
      <AssistantImageView size={26} />
    )
  }
  
  return (
    <View style={styles.row}>
      {profile}
      <Text style={styles.role}>{role}</Text>
    </View>
  );
}

export default MessageRoleView;