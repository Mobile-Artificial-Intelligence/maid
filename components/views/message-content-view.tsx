import { MaterialCommunityIconButton } from "@/components/buttons/icon-button";
import { useLLM, useSystem } from "@/context";
import splitReasoning from "@/utilities/reasoning";
import supabase from "@/utilities/supabase";
import * as Application from "expo-application";
import { randomUUID } from "expo-crypto";
import * as Device from "expo-device";
import { addNode, branchNode, getConversation, MessageNode, updateContent } from "message-nodes";
import { useState } from "react";
import { Alert, StyleSheet, Text, TextInput, TouchableHighlight, View } from "react-native";
import Markdown from 'react-native-markdown-display';

export async function insertReport(
  content: string,
  provider: string,
  model: string,
  upvoted: boolean = false
): Promise<void> {
  try {
    // 1) Ensure we have a signed-in user (anonymous if needed)
    const { data: sessionRes, error: sessionErr } = await supabase.auth.getSession();
    if (sessionErr) console.warn("getSession error:", sessionErr);

    let userId = sessionRes?.session?.user?.id;

    if (!userId) {
      const authAny = supabase.auth as any;

      if (typeof authAny.signInAnonymously !== "function") {
        console.error("signInAnonymously() not available. Update supabase-js and enable anonymous sign-ins in Supabase.");
        Alert.alert("Couldn’t submit report", "Sign-in isn’t available right now.");
        return;
      }

      const { data: anonRes, error: anonErr } = await authAny.signInAnonymously();
      if (anonErr || !anonRes?.user?.id) {
        console.error("Anonymous sign-in failed:", anonErr);
        Alert.alert("Couldn’t submit report", "Sign-in failed. Please try again.");
        return;
      }
    }

    // 2) Insert report
    const { error } = await supabase.from("reports").insert({
      content,
      provider,
      model,
      upvoted
    });

    if (error) {
      console.error("Error inserting report:", error);
      Alert.alert("Couldn’t submit report", error.message);
      return;
    }

    Alert.alert("Report Submitted", "Thank you for your feedback!", [{ text: "OK" }], {
      cancelable: true,
    });
  } catch (e) {
    console.error("insertReport unexpected error:", e);
    Alert.alert("Couldn’t submit report", "Unexpected error. Please try again.");
  }
}

function MessageContentView({ message }: { message: MessageNode }) {
  const [ showReasoning, setShowReasoning ] = useState<boolean>(false);
  const [ editText, setEditText ] = useState<string>(message.content);
  const { colorScheme, mappings, setMappings, editing, setEditing } = useSystem();
  const { parameters, type, model, modelFileKey, promptModel } = useLLM();

  const styles = StyleSheet.create({
    view: {
      flexDirection: "column",
      alignItems: "flex-start",
      width: "100%",
      gap: 8,
    },
    controls: {
      marginTop: 10,
      width: "100%",
      gap: 16,
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "flex-end",
    },
    showReasoningButton: {
      alignSelf: "center",
    },
    showReasoningButtonText: {
      color: colorScheme.primary,
      fontSize: 14,
    },
    reasoning: {
      color: colorScheme.outline,
      fontSize: 14,
      fontStyle: "italic",
    },
    content: {
      color: colorScheme.onSurface,
      fontSize: 14,
    },
  });

  const markdownStyle = StyleSheet.create({
    body: {
      color: colorScheme.onSurface,
      fontSize: 14,
    },
    link: {
      color: colorScheme.primary,
    },
    code_inline: {
      backgroundColor: colorScheme.surfaceVariant,
      color: colorScheme.onSurface,
      borderRadius: 4,
    },
    code_block: {
      backgroundColor: colorScheme.surfaceVariant,
      color: colorScheme.onSurface,
      borderWidth: 0,
      borderRadius: 4,
      padding: 8,
    },
    fence: {
      backgroundColor: colorScheme.surfaceVariant,
      color: colorScheme.onSurface,
      borderWidth: 0,
      borderRadius: 4,
      padding: 8,
    },
    hr: {
      backgroundColor: colorScheme.outline,
      marginVertical: 16,
    }
  });

  const onEdit = () => {
    const id = randomUUID();
    let next = branchNode<string>(
      mappings, 
      message.id,
      id,
      editText,
      {
        appVersion: Application.nativeApplicationVersion || undefined,
        appBuild: Application.nativeBuildVersion || undefined,
        device: Device.modelName || undefined,
        osBuildId: Device.osBuildId || undefined,
        osVersion: Device.osVersion || undefined,
        cpu: Device.supportedCpuArchitectures || undefined,
        ram: Device.totalMemory || undefined,
        createTime: new Date().toISOString(),
      }
    );

    const responseId = randomUUID();
    next = addNode<string>(
      next,
      responseId,
      "assistant",
      "",
      message.root,
      id,
      undefined,
      {
        ...parameters,
        appVersion: Application.nativeApplicationVersion || undefined,
        appBuild: Application.nativeBuildVersion || undefined,
        device: Device.modelName || undefined,
        osBuildId: Device.osBuildId || undefined,
        osVersion: Device.osVersion || undefined,
        cpu: Device.supportedCpuArchitectures || undefined,
        ram: Device.totalMemory || undefined,
        provider: type.toLowerCase().replace(" ", "-"),
        model: model || modelFileKey,
        createTime: new Date().toISOString()
      }
    );

    setMappings(next);

    let buffer = "";
    promptModel(
      getConversation(next, message.root!),
      (chunk: string) => {
        buffer += chunk;
        setMappings(updateContent(next, responseId, buffer, (meta) => ({ ...meta, updateTime: new Date().toISOString() })));
      }
    );

    onEditDone();
  };

  const onEditDone = () => {
    setEditing(undefined);
    setEditText(message.content);
  };

  const [content, reasoning] = splitReasoning(message);

  return (
    <View style={styles.view}>
      {reasoning && (
        <TouchableHighlight style={styles.showReasoningButton} onPress={() => setShowReasoning(!showReasoning)}>
          <Text style={styles.showReasoningButtonText}>{showReasoning ? "Hide Reasoning" : "Show Reasoning"}</Text>
        </TouchableHighlight>
      )}
      {reasoning && showReasoning && <Text style={styles.reasoning}>{reasoning}</Text>}
      {editing !== message.id && <Markdown style={markdownStyle}>{content}</Markdown>}
      {editing === message.id && (
        <View style={styles.view}>
          <TextInput
            style={styles.content}
            value={editText}
            onChangeText={(text) => setEditText(text)}
            multiline
          />
          <View
            style={styles.controls}
          >
            <MaterialCommunityIconButton
              icon="check"
              onPress={onEdit}
            />
            <MaterialCommunityIconButton
              icon="close"
              onPress={onEditDone}
            />
          </View>
        </View>
      )}
      {message.role === "assistant" && message.content.length > 0 && (
        <View
          style={styles.controls}
        >
          <MaterialCommunityIconButton
            icon="thumb-up"
            size={22}
            onPress={() => insertReport(message.content, type, model || modelFileKey || "", true)}
          />
          <MaterialCommunityIconButton
            icon="thumb-down"
            size={22}
            onPress={() => insertReport(message.content, type, model || modelFileKey || "", false)}
          />
        </View>
      )}
    </View>
  );
};

export default MessageContentView;