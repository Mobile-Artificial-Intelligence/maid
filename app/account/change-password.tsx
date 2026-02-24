import { useSystem } from "@/context";
import getSupabase from "@/utilities/supabase";
import { useRouter } from "expo-router";
import { useMemo, useState } from "react";
import {
  ActivityIndicator,
  Alert,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";

export default function ChangePassword() {
  const router = useRouter();
  const { colorScheme } = useSystem();

  const [currentPassword, setCurrentPassword] = useState<string>("");
  const [newPassword, setNewPassword] = useState<string>("");
  const [confirmPassword, setConfirmPassword] = useState<string>("");
  const [submitting, setSubmitting] = useState<boolean>(false);

  const newPasswordValid = useMemo(() => newPassword.length >= 8, [newPassword]);
  const passwordsMatch = useMemo(
    () => newPassword === confirmPassword,
    [newPassword, confirmPassword]
  );

  const handleChangePassword = async () => {
    if (submitting) return;

    if (!currentPassword) {
      Alert.alert("Missing Field", "Please enter your current password.");
      return;
    }
    if (!newPasswordValid) {
      Alert.alert("Invalid Password", "New password must be at least 8 characters long.");
      return;
    }
    if (!passwordsMatch) {
      Alert.alert("Password Mismatch", "New passwords do not match.");
      return;
    }

    setSubmitting(true);

    try {
      const { data: sessionData } = await getSupabase().auth.getSession();
      const email = sessionData.session?.user?.email;

      if (!email) {
        Alert.alert("Error", "Could not retrieve account information.");
        return;
      }

      const { error: signInError } = await getSupabase().auth.signInWithPassword({
        email,
        password: currentPassword,
      });

      if (signInError) {
        Alert.alert("Incorrect Password", "Your current password is incorrect.");
        return;
      }

      const { error: updateError } = await getSupabase().auth.updateUser({
        password: newPassword,
      });

      if (updateError) {
        Alert.alert("Update Failed", updateError.message);
        return;
      }

      Alert.alert("Success", "Your password has been updated.", [
        { text: "OK", onPress: () => router.back() },
      ]);
    } catch (error: any) {
      Alert.alert("Error", error.message);
    } finally {
      setSubmitting(false);
    }
  };

  const styles = StyleSheet.create({
    view: {
      justifyContent: "center",
      alignItems: "center",
      flex: 1,
      flexDirection: "column",
      gap: 16,
      backgroundColor: colorScheme.surface,
      paddingHorizontal: 48,
      paddingBottom: 64,
    },
    title: {
      color: colorScheme.primary,
      fontSize: 24,
      fontWeight: "bold",
      marginBottom: 16,
    },
    input: {
      color: colorScheme.onSurface,
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 30,
      fontSize: 16,
      paddingVertical: 12,
      paddingHorizontal: 16,
      width: "100%",
    },
    button: {
      backgroundColor: colorScheme.primary,
      borderRadius: 20,
      paddingVertical: 12,
      paddingHorizontal: 48,
      marginTop: 8,
    },
    buttonText: {
      color: colorScheme.onPrimary,
      fontSize: 16,
      textAlign: "center",
      fontWeight: "bold",
    },
    linkText: {
      color: colorScheme.primary,
      fontSize: 14,
      marginTop: 12,
    },
  });

  return (
    <View testID="change-password-page" style={styles.view}>
      <Text style={styles.title}>Change Password</Text>

      <TextInput
        style={styles.input}
        placeholder="Current Password"
        placeholderTextColor={colorScheme.onSurfaceVariant}
        value={currentPassword}
        onChangeText={setCurrentPassword}
        secureTextEntry
        autoCapitalize="none"
        autoCorrect={false}
        textContentType="password"
        autoComplete="password"
      />

      <TextInput
        style={styles.input}
        placeholder="New Password"
        placeholderTextColor={colorScheme.onSurfaceVariant}
        value={newPassword}
        onChangeText={setNewPassword}
        secureTextEntry
        autoCapitalize="none"
        autoCorrect={false}
        textContentType="newPassword"
        autoComplete="new-password"
      />

      <TextInput
        style={styles.input}
        placeholder="Confirm New Password"
        placeholderTextColor={colorScheme.onSurfaceVariant}
        value={confirmPassword}
        onChangeText={setConfirmPassword}
        secureTextEntry
        autoCapitalize="none"
        autoCorrect={false}
        textContentType="newPassword"
        autoComplete="new-password"
      />

      <TouchableOpacity
        style={styles.button}
        onPress={handleChangePassword}
        disabled={submitting}
      >
        {submitting ? (
          <ActivityIndicator color={colorScheme.onPrimary} />
        ) : (
          <Text style={styles.buttonText}>Update Password</Text>
        )}
      </TouchableOpacity>

      <TouchableOpacity onPress={() => router.back()}>
        <Text style={styles.linkText}>Cancel</Text>
      </TouchableOpacity>
    </View>
  );
}
