import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useChat, useLLM, useSystem } from "@/context";
import getMetadata from "@/utilities/metadata";
import { randomUUID } from "expo-crypto";
import { ExpoSpeechRecognitionModule } from "expo-speech-recognition";
import { addNode, getConversation, updateContent } from "message-nodes";
import { Dispatch, SetStateAction, useEffect, useState } from "react";

interface PromptButtonProps {
  promptText: string; 
  setPromptText: Dispatch<SetStateAction<string>>;
};

function PromptButton({ promptText, setPromptText }: PromptButtonProps) {
  const { mappings, setMappings, root, setRoot } = useChat();
  const { colorScheme, systemPrompt } = useSystem();
  const LLM = useLLM();

  const [dictating, setDictating] = useState(false);

  const prompt = () => {
    if (!LLM.ready) return;

    let next = mappings;
    let parent: string | undefined;

    if (root) {
      const thread = getConversation(mappings, root);
      parent = thread[thread.length - 1].id;
    } else {
      parent = randomUUID();
      next = addNode<string>(
        next,
        parent,
        "system",
        systemPrompt || "You are a helpful assistant.",
        parent,
        undefined,
        undefined,
        { title: "New Chat", ...getMetadata() }
      );
    }

    const id = randomUUID();
    next = addNode<string>(next, id, "user", promptText, root || parent, parent, undefined, getMetadata());
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
        ...getMetadata(),
        ...LLM.parameters,
        provider: LLM.type.toLowerCase().replace(" ", "-"),
        model: LLM.model || LLM.modelFileKey,
      }
    );

    setMappings(next);
    setRoot(root || parent);

    const conversation = getConversation(next, root || parent);

    let buffer = "";
    LLM.prompt(conversation, (chunk: string) => {
      buffer += chunk;
      setMappings(prev =>
        updateContent(prev, responseId, buffer, meta => ({
          ...meta,
          updateTime: new Date().toISOString(),
        }))
      );
    });
  };

  const dictate = async () => {
    try {
      let granted = false;
      const perms = await ExpoSpeechRecognitionModule.getPermissionsAsync();
      if (perms.granted) {
        granted = true;
      }
      else if (perms.canAskAgain) {
        const request = await ExpoSpeechRecognitionModule.requestPermissionsAsync();
        granted = request.granted;
      }
      else {
        console.warn("Microphone permission denied and cannot ask again.");
        return;
      }

      if (!granted) {
        console.warn("Microphone permission denied.");
        return;
      }

      ExpoSpeechRecognitionModule.start({ 
        lang: "en-US",
        addsPunctuation: true,
        androidIntentOptions: {
          EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS: 10000,
          EXTRA_MASK_OFFENSIVE_WORDS: false,
        } 
      });
    } catch (error) {
      console.error("Error requesting microphone permission:", error);
    }
  };

  useEffect(() => {
    const startListener = ExpoSpeechRecognitionModule.addListener("start", () => {
      setDictating(true);
    });

    const endListener = ExpoSpeechRecognitionModule.addListener("end", () => {
      setDictating(false);
    });

    const resultListener = ExpoSpeechRecognitionModule.addListener("result", (event) => {
      setPromptText(prev => {
        const transcript = event.results?.[0]?.transcript ?? "";
        const glue = prev.trim().length > 0 ? " " : "";
        return prev + glue + transcript;
      });
      ExpoSpeechRecognitionModule.stop();
    });

    // If the lib supports it, this is worth having:
    const errorListener = ExpoSpeechRecognitionModule.addListener?.("error" as any, (event: any) => {
      console.error("Speech recognition error:", event);
      setDictating(false);
    });

    return () => {
      startListener.remove();
      endListener.remove();
      resultListener.remove();
      errorListener?.remove?.();
    };
  }, [setPromptText]);

  if (dictating) {
    return (
      <MaterialIconButton
        testID="stop-dictate-button"
        icon="mic-off"
        size={28}
        color={colorScheme.primary}
        onPress={() => ExpoSpeechRecognitionModule.stop()}
      />
    );
  }
  else if (promptText.trim().length > 0) {
    return (
      <MaterialIconButton
        testID="send-button"
        icon="send"
        size={28}
        color={colorScheme.primary}
        onPress={prompt}
        disabled={!LLM.ready}
      />
    );
  }

  return (
    <MaterialIconButton
      testID="dictate-button"
      icon="mic"
      size={28}
      color={colorScheme.primary}
      onPress={dictate} 
    />
  );
}

export default PromptButton;