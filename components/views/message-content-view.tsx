import { MaterialCommunityIconButton } from "@/components/buttons/icon-button";
import { useLLM, useSystem } from "@/context";
import splitReasoning from "@/utilities/reasoning";
import * as Application from "expo-application";
import { randomUUID } from "expo-crypto";
import * as Device from "expo-device";
import { addNode, branchNode, getConversation, MessageNode, updateContent } from "message-nodes";
import { useState } from "react";
import { StyleSheet, Text, TextInput, View } from "react-native";

function MessageContentView({ message }: { message: MessageNode }) {
  const [ editText, setEditText ] = useState<string>(message.content);
  const { colorScheme, mappings, setMappings, editing, setEditing } = useSystem();
  const { parameters, type, model, modelFileKey, promptModel } = useLLM();

  const styles = StyleSheet.create({
    view: {
      flexDirection: "column",
      alignItems: "flex-start",
    },
    editingControls: {
      width: "100%",
      marginTop: 10,
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "flex-end",
    },
    reasoning: {
      color: colorScheme.outline,
      fontSize: 14,
      fontStyle: "italic",
      marginBottom: 8,
    },
    content: {
      color: colorScheme.onSurface,
      fontSize: 14,
    },
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

  const editingInput = (
    <View style={styles.view}>
      <TextInput
        style={styles.content}
        value={editText}
        onChangeText={(text) => setEditText(text)}
        multiline
      />
      <View
        style={styles.editingControls}
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
  );

  let content: string | undefined = message.content.trim();
  let reasoning: string | undefined = undefined;
  if (message.content.includes("<think>")) {
    [content, reasoning] = splitReasoning(message, "<think>", "</think>");
  }
  else if (message.content.includes("<reasoning>")) {
    [content, reasoning] = splitReasoning(message, "<reasoning>", "</reasoning>");
  }

  return (
    <View style={styles.view}>
      {reasoning && <Text style={styles.reasoning}>{reasoning}</Text>}
      {editing === message.id ? editingInput : (
        <Text style={styles.content}>{content}</Text>
      )}
    </View>
  )
};

export default MessageContentView;