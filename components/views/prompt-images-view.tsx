import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useSystem } from "@/context";
import { Image } from "expo-image";
import { ImagePickerAsset } from "expo-image-picker";
import { Dispatch, SetStateAction } from "react";
import { ScrollView, StyleSheet, View } from "react-native";

interface PromptImagesViewProps {
  images: Array<ImagePickerAsset>;
  setImages: Dispatch<SetStateAction<Array<ImagePickerAsset>>>;
}

function PromptImagesView({ images, setImages }: PromptImagesViewProps) {
  const { colorScheme } = useSystem();

  const styles = StyleSheet.create({
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

  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.imageScrollView}>
      {images?.map((img) => (
        <View key={img.uri} style={styles.imageContainer}>
          <MaterialIconButton
            icon="close"
            size={24}
            style={styles.imageButton}
            onPress={() => setImages(images.filter(i => i.uri !== img.uri))}
          />
          <Image
            source={{ uri: img.uri }}
            style={styles.image}
          />
        </View>
      ))}
    </ScrollView>
  );
};

export default PromptImagesView;