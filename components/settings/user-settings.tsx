import UserImageView from "@/components/views/user-image-view";
import { useSystem } from "@/context";
import * as ImagePicker from 'expo-image-picker';
import { StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

function UserSettings() {
  const { colorScheme, userName, setUserName, setUserImage } = useSystem();

  const styles = StyleSheet.create({
    view: {
      alignItems: "center",
      justifyContent: "space-between",
      gap: 16,
    },
    title: {
      color: colorScheme.onSurface,
      fontSize: 16,
      fontWeight: "bold"
    },
    button: { 
      color: colorScheme.primary,
      backgroundColor: colorScheme.surfaceVariant,
      paddingVertical: 8,
      paddingHorizontal: 16,
      borderRadius: 20,
    },
    input: {
      color: colorScheme.onSurface,
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 30,
      fontSize: 16,
      paddingVertical: 12,
      paddingHorizontal: 16,
      width: 300,
    }
  });

  const onPress = async () => {
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();

    if (permissionResult.granted === false) {
      alert("Permission to access camera roll is required!");
      return;
    }

    const pickerResult = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ["images"],
      allowsEditing: true,
      aspect: [1, 1],
      quality: 1,
    });

    if (!pickerResult.canceled) {
      setUserImage(pickerResult.assets[0].uri);
    }
  };

  return (
    <View
      style={styles.view}
    >
      <Text style={styles.title}>
        User Settings
      </Text>
      <UserImageView size={80} />
      <TouchableOpacity
        onPress={onPress}
      >
        <Text style={styles.button}>
          Load User Image
        </Text>
      </TouchableOpacity>
      <TextInput
        style={styles.input}
        placeholder="User Name"
        placeholderTextColor={colorScheme.onSurface}
        underlineColorAndroid="transparent"
        value={userName}
        onChangeText={setUserName}
      />
    </View>
  );
}

export default UserSettings;