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

  const roleNames: Record<string, string | undefined> = {
    user: userName,
    assistant: assistantName,
  };

  const avatars: Record<string, React.ReactNode> = {
    user: <UserImageView size={26} />,
    assistant: <AssistantImageView size={26} />,
  };

  const role = roleNames[message.role] ?? (message.role.charAt(0).toUpperCase() + message.role.slice(1));
  const profile =
    avatars[message.role] ?? (
      <Icon name="account-cog" size={26} color={colorScheme.onSurface} />
    );

  return (
    <View style={styles.row}>
      {profile}
      <Text style={[styles.role, { color: colorScheme.onSurface }]}>
        {role}
      </Text>
    </View>
  );
}

export default MessageRoleView;