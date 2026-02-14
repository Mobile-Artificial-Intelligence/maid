import { useSystem } from "@/context";
import Icon from '@expo/vector-icons/MaterialCommunityIcons';
import { Image } from "expo-image";
import { StyleSheet } from "react-native";

interface AssistantImageViewProps {
  size: number;
}

function AssistantImageView({ size }: AssistantImageViewProps) {
  const { colorScheme, assistantImage } = useSystem();

  const styles = StyleSheet.create({
    image: {
      width: size,
      height: size,
      borderRadius: size / 2,
    },
  });

  if (!assistantImage) {
    return (
      <Icon
        name="assistant"
        size={size}
        color={colorScheme.onSurface}
      />
    );
  }

  return (
    <Image
      source={assistantImage}
      style={styles.image}
    />
  );
}

export default AssistantImageView;