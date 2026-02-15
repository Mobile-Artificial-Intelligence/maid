import { MaterialIconButton } from "@/components/buttons/icon-button";
import SessionButton from "@/components/buttons/session-button";
import { useSystem } from "@/context";
import validateMappings from "@/utilities/mappings";
import { randomUUID } from "expo-crypto";
import * as DocumentPicker from "expo-document-picker";
import * as FileSystem from "expo-file-system";
import { useRouter } from "expo-router";
import { addNode, getRoots } from "message-nodes";
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from "react-native";

function DrawerContent() {
  const router = useRouter();
  const { colorScheme, mappings, setMappings, authenticated, logout } = useSystem();
  
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

  const clearSessions = () => {
    router.replace("/chat");
    setMappings({});
  };

  const createSession = () => {
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
    router.replace(`/chat/${id}`);
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
    <View style={styles.view}>
      <View style={styles.header}>
        <Text style={styles.controlsText}>Chats</Text>
        <View style={styles.controls}>
          <MaterialIconButton
            icon="folder-open"
            style={styles.button}
            size={24}
            onPress={loadMappings}
          />
          <MaterialIconButton
            icon="delete"
            style={styles.button}
            size={24}
            onPress={clearSessions}
          />
          <MaterialIconButton
            icon="add"
            style={styles.button}
            size={24}
            onPress={createSession}
          />
        </View>
      </View>
      <View style={styles.divider} />
      <ScrollView style={styles.sessions}>
        {getRoots<string>(mappings).map((session) => <SessionButton key={session.id} node={session} />)}
      </ScrollView>
      <View style={styles.divider} />
      <View style={styles.account}>
        {authenticated ? (
          <TouchableOpacity onPress={logout}>
            <Text style={styles.accountText}>Logout</Text>
          </TouchableOpacity>
        ) : (
          <>
            <TouchableOpacity
              onPress={() => router.push("/account/login")}
            >
                <Text style={styles.accountText}>Login</Text>
            </TouchableOpacity>
            <TouchableOpacity
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
