import { useSystem } from "@/context";
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

function Login() {
  const router = useRouter();
  const { login, colorScheme } = useSystem();

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
      await login(email, password);
      Alert.alert("Login Successful", "You have been logged in successfully.");
      router.replace("/chat");
    } catch (error: any) {
      Alert.alert("Login Failed", error.message);
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
    <View style={styles.view}>
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

      <TouchableOpacity onPress={() => router.replace("/account/register")}>
        <Text style={styles.linkText}>Don’t have an account? Register</Text>
      </TouchableOpacity>
    </View>
  );
}

export default Login;