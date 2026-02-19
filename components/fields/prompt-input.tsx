import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useChat, useLLM, useSystem } from "@/context";
import * as Application from "expo-application";
import { randomUUID } from "expo-crypto";
import * as Device from "expo-device";
import { addNode, getConversation, updateContent } from "message-nodes";
import { useState } from "react";
import { StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

function PromptInput() {
  const { mappings, setMappings, root, setRoot } = useChat();
  const { colorScheme, systemPrompt } = useSystem();
  const LLM = useLLM();

  const [promptText, setPromptText] = useState<string>("");

  const styles = StyleSheet.create({
    root: {
      flexDirection: "column",
      alignItems: "center",
    },
    inputView: {
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 30,
      flexDirection: "row",
      alignItems: "center",
      paddingVertical: 4,
      paddingHorizontal: 12,
      marginTop: 8,
      alignSelf: "stretch",
    },
    input: {
      color: colorScheme.onSurface,
      fontSize: 16,
      flex: 1,
      borderWidth: 0,
      marginHorizontal: 8,
    },
    clearButtonText: { 
      color: colorScheme.onPrimary, 
      backgroundColor: colorScheme.primary,
      paddingVertical: 8,
      paddingHorizontal: 16,
      borderRadius: 20,
      fontSize: 14
    },
    imageScrollView: { 
      paddingVertical: 8,
      marginTop: 4, 
    },
    imageContainer: { 
      marginHorizontal: 4, 
      position: "relative" 
    },
    imageButton: {
      position: "absolute",
      top: -10,
      right: -10,
      zIndex: 1,
      backgroundColor: colorScheme.surfaceVariant, 
      borderRadius: 12 
    },
    image: { 
      width: 100, 
      height: 100, 
      borderRadius: 8 
    }
  });

  const onPrompt = () => {
    if (!LLM.ready) return;

    let next = mappings;
    let parent: string | undefined = undefined;
    if (root) {
      const thread = getConversation(mappings, root);
      parent = thread[thread.length - 1].id;
    }
    else {
      parent = randomUUID();
      next = addNode<string>(
        next,
        parent,
        "system",
        systemPrompt || "You are a helpful assistant.",
        parent,
        undefined,
        undefined,
        {
          title: "New Chat",
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
    }

    const id = randomUUID();
    next = addNode<string>(
      next,
      id,
      "user",
      promptText,
      root || parent,
      parent,
      undefined,
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
    
    setPromptText("");

    const responseId = randomUUID();
    next = addNode<string>(
      next,
      responseId,
      "assistant",
      "",
      root || parent,
      id,
      undefined,
      {
        ...LLM.parameters,
        appVersion: Application.nativeApplicationVersion || undefined,
        appBuild: Application.nativeBuildVersion || undefined,
        device: Device.modelName || undefined,
        osBuildId: Device.osBuildId || undefined,
        osVersion: Device.osVersion || undefined,
        cpu: Device.supportedCpuArchitectures || undefined,
        ram: Device.totalMemory || undefined,
        provider: LLM.type.toLowerCase().replace(" ", "-"),
        model: LLM.model || LLM.modelFileKey,
        createTime: new Date().toISOString()
      }
    );
    
    setMappings(next);
    setRoot(root || parent);

    const conversation = getConversation(next, root || parent);
    
    let buffer = "";
    LLM.prompt(
      conversation,
      (chunk: string) => {
        buffer += chunk;
        setMappings(updateContent(next, responseId, buffer, (meta) => ({ ...meta, updateTime: new Date().toISOString() })));
      }
    );
  };

  return (
    <View
      style={styles.root}
    >
      {promptText.length > 0 && (
        <TouchableOpacity
          onPress={() => setPromptText("")}
        >
          <Text style={styles.clearButtonText}>Clear Prompt</Text>
        </TouchableOpacity>
      )}
      <View style={styles.inputView}>
        <TextInput
          style={styles.input}
          placeholder="Type a message..."
          placeholderTextColor={colorScheme.onSurface}
          underlineColorAndroid="transparent"
          multiline
          value={promptText}
          onChangeText={setPromptText}
        />
        <MaterialIconButton
          icon="send"
          size={32}
          color={colorScheme.primary}
          onPress={onPrompt}
          disabled={promptText.length == 0 || !LLM.ready}
        />
      </View>
    </View>
  );
}

export default PromptInput;
