import { MaterialCommunityIconButton } from "@/components/buttons/icon-button";
import AssistantImageView from "@/components/views/assistant-image-view";
import UserImageView from "@/components/views/user-image-view";
import { useLLM, useSystem, useTTS } from "@/context";
import Icon from '@expo/vector-icons/MaterialCommunityIcons';
import * as Application from "expo-application";
import { randomUUID } from "expo-crypto";
import * as Device from "expo-device";
import { addNode, branchNode, getChildren, getConversation, lastChild, MessageNode, nextChild, updateContent } from "message-nodes";
import { useState } from "react";
import { StyleSheet, Text, TextInput, View } from "react-native";

function MessageView({ message }: { message: MessageNode }) {
  const [ editText, setEditText ] = useState<string>(message.content);
  const { userName, assistantName, colorScheme, mappings, setMappings, editing, setEditing, deleteMessage } = useSystem();
  const { parameters, type, model, modelFileKey, busy, promptModel } = useLLM();
  const { textToSpeech, canSpeak } = useTTS();

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
    },
    innerRow: {
      flexDirection: "row",
      alignItems: "center",
    },
    editingRow: {
      width: "100%",
      marginTop: 10,
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "flex-end",
    },
    role: {
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold",
      marginLeft: 8,
    },
    content: {
      color: colorScheme.onSurface,
      fontSize: 14,
    },
    childCounter: {
      color: colorScheme.onSurface,
      fontSize: 14,
      marginHorizontal: 4
    }
  });

  const onRegenerate = () => {
    const responseId = randomUUID();
    const next = branchNode<string>(
      mappings,
      message.id,
      responseId,
      "",
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
  };

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
  }

  let roleDisplay = message.role.charAt(0).toUpperCase() + message.role.slice(1);
  if (message.role === "user" && userName) {
    roleDisplay = userName;
  } 
  else if (message.role === "assistant" && assistantName) {
    roleDisplay = assistantName;
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

  const speakEnabled = canSpeak && !editing && !busy;
  const siblings = getChildren(mappings, message.parent!);
  const index = siblings.findIndex((child) => child.id === message.id);

  const controls = (
    <View style={styles.innerRow}>
      {message.role === "assistant" &&
        <>
          <MaterialCommunityIconButton
            icon="volume-high"
            onPress={() => textToSpeech(message.content)}
            disabled={!speakEnabled}
          />
          <MaterialCommunityIconButton
            icon="reload"
            onPress={onRegenerate}
            disabled={!!editing || busy}
          />
        </>
      }
      {message.role === "user" &&
        <MaterialCommunityIconButton
          icon="pencil"
          onPress={() => setEditing(message.id)}
          disabled={!!editing || busy}
        />
      }
      <MaterialCommunityIconButton
        icon="menu-left"
        onPress={() => setMappings((prev) => lastChild(prev, message.parent!))}
        disabled={index <= 0 || !!editing || busy}
      />
      <Text
        style={styles.childCounter}
      >
        {index + 1} / {siblings.length}
      </Text>
      <MaterialCommunityIconButton
        icon="menu-right"
        onPress={() => setMappings((prev) => nextChild(prev, message.parent!))}
        disabled={index === siblings.length - 1 || !!editing || busy}
      />
      <MaterialCommunityIconButton
        icon="delete"
        onPress={() => deleteMessage(message.id)}
        disabled={!!editing || busy}
      />
    </View>
  );

  const editingInput = (
    <View>
      <TextInput
        style={styles.content}
        value={editText}
        onChangeText={(text) => setEditText(text)}
        multiline
      />
      <View
        style={styles.editingRow}
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

  return (
    <View style={styles.view}>
        <View style={styles.mainRow}>
          <View style={styles.innerRow}>
            {profile}
            <Text style={styles.role}>{roleDisplay}</Text>
          </View>
          {message.id && controls}
        </View>
        {editing === message.id ? editingInput : (
          <Text style={styles.content}>{message.content}</Text>
        )}
    </View>
  );
}

export default MessageView;
