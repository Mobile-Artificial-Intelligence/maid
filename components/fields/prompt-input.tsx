import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useChat, useLLM, useSystem } from "@/context";
import getMetadata from "@/utilities/metadata";
import { randomUUID } from "expo-crypto";
import { addNode, getConversation, updateContent } from "message-nodes";
import { useState } from "react";
import { StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

function PromptInput() {
  const { mappings, setMappings, root, setRoot } = useChat();
  const { colorScheme, systemPrompt } = useSystem();
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
        systemPrompt || "You are a helpful assistant.",
        parent,
        undefined,
        undefined,
        {
          title: "New Chat",
          ...getMetadata(),
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
      getMetadata()
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
        ...getMetadata(),
        ...parameters,
        provider: type.toLowerCase().replace(" ", "-"),
        model: model || modelFileKey,
      }
    );
    
    setMappings(next);
    setRoot(root || parent);

    const conversation = getConversation(next, root || parent);
    
    let buffer = "";
    promptModel(
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
