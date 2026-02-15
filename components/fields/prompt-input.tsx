import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useLLM, useSystem } from "@/context";
import * as Application from "expo-application";
import { randomUUID } from "expo-crypto";
import * as Device from "expo-device";
import { useRouter } from "expo-router";
import { addNode, getConversation, updateContent } from "message-nodes";
import { useState } from "react";
import { StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

interface PromptInputProps {
  root?: string;
}

function PromptInput({ root }: PromptInputProps) {
  const router = useRouter();
  const { colorScheme, mappings, systemPrompt, setMappings } = useSystem();
  const { type, model, modelFileKey, parameters, ready, promptModel } = useLLM();

  const [prompt, setPrompt] = useState<string>("");

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
    if (!ready) return;

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
        "New Chat",
        parent,
        undefined,
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
    }

    const id = randomUUID();
    next = addNode<string>(
      next,
      id,
      "user",
      prompt,
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
    
    setPrompt("");

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

    const conversationMappings = updateContent<string, Record<string, any>>(next, root || parent, systemPrompt || "", (meta) => ({ ...meta, updateTime: new Date().toISOString() }));
    const conversation = getConversation(conversationMappings, root || parent);
    
    let buffer = "";
    promptModel(
      conversation,
      (chunk: string) => {
        buffer += chunk;
        setMappings(updateContent(next, responseId, buffer, (meta) => ({ ...meta, updateTime: new Date().toISOString() })));
      }
    );

    if (!root) {
      router.replace(`/chat/${parent}`);
    }
  };

  return (
    <View
      style={styles.root}
    >
      {prompt.length > 0 && (
        <TouchableOpacity
          onPress={() => setPrompt("")}
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
          value={prompt}
          onChangeText={setPrompt}
        />
        <MaterialIconButton
          icon="send"
          size={28}
          color={colorScheme.primary}
          onPress={onPrompt}
          disabled={prompt.length == 0 || !ready}
        />
      </View>
    </View>
  );
}

export default PromptInput;
