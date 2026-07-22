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
  View
} from "react-native";
import { KeyboardAwareScrollView } from "react-native-keyboard-controller";
import { useSafeAreaInsets } from "react-native-safe-area-context";

function Login() {
  const router = useRouter();
  const { colorScheme } = useSystem();
  const insets = useSafeAreaInsets();

  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [submitting, setSubmitting] = useState<boolean>(false);

  const emailValid = useMemo(
    () => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim()),
    [email]
  );

  const passwordValid = useMemo(
    () => password.length >= 8,
    [password]
  );

  const handleLogin = async () => {
    if (submitting) return;

    if (!emailValid) {
      Alert.alert("Invalid Email", "Please enter a valid email address.");
      return;
    }
    if (!passwordValid) {
      Alert.alert("Invalid Password", "Password must be at least 8 characters long.");
      return;
    }

    setSubmitting(true);

    try {
      const { data, error } = await getSupabase().auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        Alert.alert("Login Failed", error.message);
        return;
      }

      if (!data?.user) {
        Alert.alert("Login Failed", "Unexpected response from server.");
        return;
      }

      Alert.alert("Login Successful", "You have been logged in successfully.");
      router.replace("/chat");
    } catch (error: any) {
      Alert.alert("Login Failed", error.message);
    } finally {
      setSubmitting(false);
    }
  };

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: colorScheme.surface,
    },
    content: {
      flexGrow: 1,
      justifyContent: "center",
      // Edge-to-edge: keep the form clear of the navigation bar.
      paddingBottom: insets.bottom,
    },
    view: {
      alignItems: "center",
      flexDirection: "column",
      gap: 16,
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
    <KeyboardAwareScrollView
      style={styles.container}
      contentContainerStyle={styles.content}
      bottomOffset={16}
    >
      <View testID="login-page" style={styles.view}>
        <Text style={styles.title}>Welcome Back</Text>

        <TextInput
          style={styles.input}
          placeholder="Email"
          placeholderTextColor={colorScheme.onSurfaceVariant}
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />

        <TextInput
          style={styles.input}
          placeholder="Password"
          placeholderTextColor={colorScheme.onSurfaceVariant}
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          autoCapitalize="none"
          autoCorrect={false}
          textContentType="password"
          autoComplete="password"
        />

        <TouchableOpacity
          style={styles.button}
          onPress={handleLogin}
          disabled={submitting}
        >
          {submitting ? (
            <ActivityIndicator color={colorScheme.onPrimary} />
          ) : (
            <Text style={styles.buttonText}>Login</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity testID="register-link" onPress={() => router.replace("/account/register")}>
          <Text style={styles.linkText}>Don’t have an account? Register</Text>
        </TouchableOpacity>

        <TouchableOpacity testID="forgot-password-link" onPress={() => router.push("/account/reset-password" as any)}>
          <Text style={styles.linkText}>Forgot password?</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAwareScrollView>
  );
}

export default Login;