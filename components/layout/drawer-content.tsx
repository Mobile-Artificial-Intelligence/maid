import ChatButton from "@/components/buttons/chat-button";
import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useChat, useSystem } from "@/context";
import useAuthentication from "@/hooks/use-authentication";
import validateMappings from "@/utilities/mappings";
import getSupabase from "@/utilities/supabase";
import { randomUUID } from "expo-crypto";
import * as DocumentPicker from "expo-document-picker";
import * as FileSystem from "expo-file-system";
import { useRouter } from "expo-router";
import { addNode, getRoots } from "message-nodes";
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from "react-native";

function DrawerContent() {
  const router = useRouter();
  const [authenticated, anonymous] = useAuthentication();
  const { mappings, setMappings, setRoot } = useChat();
  const { colorScheme } = useSystem();
  
  const loadMappings = async () => {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: "application/json",
        multiple: true,
      });

      if (result.canceled) return;

      for (const file of result.assets ?? []) {
        try {
          const content = await FileSystem.readAsStringAsync(file.uri);
          const parsed = JSON.parse(content);
          const validMap = validateMappings(parsed);
          setMappings(prev => ({ ...prev, ...validMap }));
        } catch (fileError) {
          console.warn(`Failed to load file: ${file.name}`, fileError);
        }
      }
    } catch (error) {
      console.warn("Failed to load mappings:", error);
    }
  };

  const clearChats = () => {
    setRoot(undefined);
    setMappings({});
  };

  const createChat = () => {
    const id = randomUUID();
    const time = new Date();
    setMappings((prev) => addNode<string>(
      prev,
      id,
      "system",
      "New Chat",
      id,
      undefined,
      undefined,
      {
        createTime: time.toISOString(),
      }
    ));
    setRoot(id);
  };

  const logout = async () => {
    try {
      await getSupabase().auth.signOut();
    } catch (error) {
      console.error("Error during logout:", error);
    }
  };
    
  const styles = StyleSheet.create({
    view: {
      flex: 1,
      flexDirection: "column",
    },
    divider: {
      height: 2,
      backgroundColor: colorScheme.outline,
      marginHorizontal: 18,
      marginVertical: 12,
      borderRadius: 1,
    },
    header: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
      paddingHorizontal: 18,
      paddingTop: 16,
    },
    controlsText: {
      color: colorScheme.onSurface,
      fontSize: 16,
    },
    controls: {
      flexDirection: "row",
      alignItems: "center",
    },
    button: {
      marginHorizontal: 8,
    },
    sessions: {
      flex: 1,
      flexDirection: "column"
    },
    account: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-around",
      paddingTop: 12,
      paddingBottom: 24,
    },
    accountText: {
      color: colorScheme.primary,
    }
  });
    
  return (
    <View testID="drawer-content" style={styles.view}>
      <View style={styles.header}>
        <Text style={styles.controlsText}>Chats</Text>
        <View style={styles.controls}>
          <MaterialIconButton
            testID="load-mappings-button"
            icon="folder-open"
            style={styles.button}
            size={24}
            onPress={loadMappings}
          />
          <MaterialIconButton
            testID="clear-chats-button"
            icon="delete"
            style={styles.button}
            size={24}
            onPress={clearChats}
          />
          <MaterialIconButton
            testID="new-chat-button"
            icon="add"
            style={styles.button}
            size={24}
            onPress={createChat}
          />
        </View>
      </View>
      <View style={styles.divider} />
      <ScrollView style={styles.sessions}>
        {getRoots<string>(mappings).map((root, index) => <ChatButton testID={`chat-button-${index}`} key={root.id} node={root} />)}
      </ScrollView>
      <View style={styles.divider} />
      <View style={styles.account}>
        {authenticated && !anonymous ? (
          <TouchableOpacity testID="logout-button" onPress={logout}>
            <Text style={styles.accountText}>Logout</Text>
          </TouchableOpacity>
        ) : (
          <>
            <TouchableOpacity
              testID="login-button"
              onPress={() => router.push("/account/login")}
            >
                <Text style={styles.accountText}>Login</Text>
            </TouchableOpacity>
            <TouchableOpacity
              testID="register-button"
              onPress={() => router.push("/account/register")}
            >
              <Text style={styles.accountText}>Register</Text>
            </TouchableOpacity>
          </>
        )}
      </View>
    </View>
  );
}

export default DrawerContent;
