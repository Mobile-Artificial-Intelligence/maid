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

export default function ResetPassword() {
  const router = useRouter();
  const { colorScheme } = useSystem();

  const [step, setStep] = useState<"email" | "otp">("email");
  const [email, setEmail] = useState<string>("");
  const [otp, setOtp] = useState<string>("");
  const [newPassword, setNewPassword] = useState<string>("");
  const [confirmPassword, setConfirmPassword] = useState<string>("");
  const [submitting, setSubmitting] = useState<boolean>(false);

  const emailValid = useMemo(
    () => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim()),
    [email]
  );
  const newPasswordValid = useMemo(() => newPassword.length >= 8, [newPassword]);
  const passwordsMatch = useMemo(
    () => newPassword === confirmPassword,
    [newPassword, confirmPassword]
  );

  const handleSendOtp = async () => {
    if (submitting) return;

    if (!emailValid) {
      Alert.alert("Invalid Email", "Please enter a valid email address.");
      return;
    }

    setSubmitting(true);

    try {
      const { error } = await getSupabase().auth.resetPasswordForEmail(email.trim());

      if (error) {
        Alert.alert("Error", error.message);
        return;
      }

      setStep("otp");
    } catch (error: any) {
      Alert.alert("Error", error.message);
    } finally {
      setSubmitting(false);
    }
  };

  const handleResetPassword = async () => {
    if (submitting) return;

    if (!otp) {
      Alert.alert("Missing Code", "Please enter the code sent to your email.");
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
      const { error: verifyError } = await getSupabase().auth.verifyOtp({
        email: email.trim(),
        token: otp.trim(),
        type: "recovery",
      });

      if (verifyError) {
        Alert.alert("Invalid Code", verifyError.message);
        return;
      }

      const { error: updateError } = await getSupabase().auth.updateUser({
        password: newPassword,
      });

      if (updateError) {
        Alert.alert("Update Failed", updateError.message);
        return;
      }

      Alert.alert("Success", "Your password has been reset.", [
        { text: "OK", onPress: () => router.replace("/account/login") },
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
      marginBottom: 8,
    },
    subtitle: {
      color: colorScheme.onSurfaceVariant,
      fontSize: 14,
      textAlign: "center",
      marginBottom: 8,
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

  if (step === "email") {
    return (
      <View testID="reset-password-page" style={styles.view}>
        <Text style={styles.title}>Reset Password</Text>
        <Text style={styles.subtitle}>
          Enter your email and we'll send you a code to reset your password.
        </Text>

        <TextInput
          style={styles.input}
          placeholder="Email"
          placeholderTextColor={colorScheme.onSurfaceVariant}
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
          autoComplete="email"
        />

        <TouchableOpacity
          style={styles.button}
          onPress={handleSendOtp}
          disabled={submitting}
        >
          {submitting ? (
            <ActivityIndicator color={colorScheme.onPrimary} />
          ) : (
            <Text style={styles.buttonText}>Send Code</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.linkText}>Back to Login</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View testID="reset-password-otp-page" style={styles.view}>
      <Text style={styles.title}>Enter Code</Text>
      <Text style={styles.subtitle}>
        We sent a code to {email}. Enter it below along with your new password.
      </Text>

      <TextInput
        style={styles.input}
        placeholder="6-digit code"
        placeholderTextColor={colorScheme.onSurfaceVariant}
        value={otp}
        onChangeText={setOtp}
        keyboardType="number-pad"
        autoCapitalize="none"
        autoCorrect={false}
        textContentType="oneTimeCode"
        autoComplete="one-time-code"
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
        onPress={handleResetPassword}
        disabled={submitting}
      >
        {submitting ? (
          <ActivityIndicator color={colorScheme.onPrimary} />
        ) : (
          <Text style={styles.buttonText}>Reset Password</Text>
        )}
      </TouchableOpacity>

      <TouchableOpacity onPress={() => setStep("email")}>
        <Text style={styles.linkText}>Resend code</Text>
      </TouchableOpacity>
    </View>
  );
}
