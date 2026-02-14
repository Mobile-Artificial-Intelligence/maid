import { useSystem } from "@/context";
import Icon from '@expo/vector-icons/MaterialCommunityIcons';
import { Image } from "expo-image";
import { StyleSheet } from "react-native";

interface UserImageViewProps {
  size: number;
}

function UserImageView({ size }: UserImageViewProps) {
  const { colorScheme, userImage } = useSystem();

  const styles = StyleSheet.create({
    image: {
      width: size,
      height: size,
      borderRadius: size / 2,
    },
  });

  if (!userImage) {
    return (
      <Icon
        name="account"
        size={size}
        color={colorScheme.onSurface}
      />
    );
  }

  return (
    <Image
      source={userImage}
      style={styles.image}
    />
  );
}

export default UserImageView;