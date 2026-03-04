import { useSystem } from "@/context";
import * as ImagePicker from 'expo-image-picker';
import { ImagePickerAsset } from "expo-image-picker";
import { Dispatch, SetStateAction } from "react";
import { MaterialIconButton } from "./icon-button";

interface PromptImageButtonProps {
  setImages: Dispatch<SetStateAction<Array<ImagePickerAsset>>>;
};

function PromptImageButton({ setImages }: PromptImageButtonProps) {
  const { colorScheme } = useSystem();

  const onImagePress = async () => {
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (permissionResult.granted === false) {
      alert("Permission to access camera roll is required!");
      return;
    }

    const pickerResult = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ["images"],
      quality: 1,
    });

    if (!pickerResult.canceled) {
      setImages(images => [ ...images || [], ...pickerResult.assets ]);
    }
  };

  return (
    <MaterialIconButton
      icon="image"
      size={28}
      color={colorScheme.primary}
      onPress={onImagePress}
      disabled={true}
    />
  );
};

export default PromptImageButton;