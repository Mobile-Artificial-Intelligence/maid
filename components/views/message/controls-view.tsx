import { MaterialCommunityIconButton } from "@/components/buttons/icon-button";
import { useChat, useLLM, useSystem } from "@/context";
import getMetadata from "@/utilities/metadata";
import splitReasoning from "@/utilities/reasoning";
import { randomUUID } from "expo-crypto";
import * as Speech from "expo-speech";
import { branchNode, getChildren, getConversation, lastChild, MessageNode, nextChild, updateContent } from "message-nodes";
import { useEffect, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

function MessageControlsView({ message }: { message: MessageNode }) {
  const [ speaking, setSpeaking ] = useState<boolean>(false);
  const { mappings, setMappings, editing, setEditing, deleteMessage } = useChat();
  const { colorScheme, voice } = useSystem();
  const LLM = useLLM();

  const styles = StyleSheet.create({
    row: {
      flexDirection: "row",
      alignItems: "center",
    },
    counter: {
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
        ...getMetadata(),
        ...LLM.parameters,
        provider: LLM.type.toLowerCase().replace(" ", "-"),
        model: LLM.model || LLM.modelFileKey,
      }
    );

    setMappings(next);

    let buffer = "";
    LLM.prompt(
      getConversation(next, message.root!),
      (chunk: string) => {
        buffer += chunk;
        setMappings(updateContent(next, responseId, buffer, (meta) => ({ ...meta, updateTime: new Date().toISOString() })));
      }
    );
  };

  const onSpeak = async () => {
    if (speaking) {
      console.warn("Already speaking");
      return;
    }

    if (!voice) {
      console.warn("No voice selected");
      return;
    }

    try {
      Speech.speak(splitReasoning(message)[0] ?? message.content, { voice: voice!.identifier });
      await new Promise((resolve) => setTimeout(resolve, 100));

      const isSpeaking = await Speech.isSpeakingAsync();
      setSpeaking(isSpeaking);
    }
    catch (error) {
      console.error("Error speaking message:", error);
    }
  };

  const onSpeakCancel = async () => {
    if (!speaking) return;

    try {
      await Speech.stop();

      const isSpeaking = await Speech.isSpeakingAsync();
      setSpeaking(isSpeaking);
    }
    catch (error) {
      console.error("Error stopping speech:", error);
    }
  };

  useEffect(() => {
    if (!speaking) return;

    const interval = setInterval(async () => {
      const isSpeaking = await Speech.isSpeakingAsync();
      setSpeaking(isSpeaking);
    }, 1000);

    return () => clearInterval(interval);
  }, [speaking]);

  const speakEnabled = voice && !editing && !LLM.busy;
  const siblings = getChildren(mappings, message.parent!);
  const index = siblings.findIndex((child) => child.id === message.id);

  return (
    <View style={styles.row}>
      {message.role === "assistant" && voice && !speaking &&
        <MaterialCommunityIconButton
          icon="volume-high"
          onPress={onSpeak}
          disabled={!speakEnabled}
        />
      }
      {message.role === "assistant" && voice && speaking &&
        <MaterialCommunityIconButton
          icon="volume-off"
          onPress={onSpeakCancel}
          disabled={!speakEnabled}
        />
      }
      {message.role === "assistant" &&
        <MaterialCommunityIconButton
          icon="reload"
          onPress={onRegenerate}
          disabled={!!editing || LLM.busy}
        />
      }
      {message.role === "user" &&
        <MaterialCommunityIconButton
          icon="pencil"
          onPress={() => setEditing(message.id)}
          disabled={!!editing || LLM.busy}
        />
      }
      <MaterialCommunityIconButton
        icon="menu-left"
        onPress={() => setMappings((prev) => lastChild(prev, message.parent!))}
        disabled={index <= 0 || !!editing || LLM.busy}
      />
      <Text
        style={styles.counter}
      >
        {index + 1} / {siblings.length}
      </Text>
      <MaterialCommunityIconButton
        icon="menu-right"
        onPress={() => setMappings((prev) => nextChild(prev, message.parent!))}
        disabled={index === siblings.length - 1 || !!editing || LLM.busy}
      />
      <MaterialCommunityIconButton
        icon="delete"
        onPress={() => deleteMessage(message.id)}
        disabled={!!editing || LLM.busy}
      />
    </View>
  );
}

export default MessageControlsView;