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

function Register() {
  const router = useRouter();
  const { colorScheme, userName, setUserName } = useSystem();

  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [passwordConfirm, setPasswordConfirm] = useState<string>("");
  const [submitting, setSubmitting] = useState<boolean>(false);

  const emailValid = useMemo(
    () => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim()),
    [email]
  );
  const passwordValid = useMemo(
    () => password.length >= 8,
    [password]
  );
  const passwordsMatch = useMemo(
    () => password === passwordConfirm,
    [password, passwordConfirm]
  );
  const userNameValid = useMemo(
    () => /^[A-Za-z0-9_]{3,24}$/.test(userName?.trim() || ""),
    [userName]
  );

  const handleRegister = async () => {
    if (submitting) return;
    if (!userNameValid) {
      Alert.alert("Invalid Username", "Username must be 3–24 letters, digits, or underscores.");
      return;
    }
    if (!emailValid) {
      Alert.alert("Invalid Email", "Please enter a valid email address.");
      return;
    }
    if (!passwordValid) {
      Alert.alert("Invalid Password", "Password must be at least 8 characters long.");
      return;
    }
    if (!passwordsMatch) {
      Alert.alert("Passwords Don’t Match", "Please make sure both passwords are identical.");
      return;
    }

    setSubmitting(true);

    try {
      const { error } = await getSupabase().auth.signUp({
        email,
        password,
        options: { data: { user_name: userName } },
      });
  
      if (error) {
        Alert.alert("Registration Failed", error.message);
        return;
      }
      
      Alert.alert("Registration Successful", "Your account has been created successfully.");
      router.replace("/account/login");
    } catch (error: any) {
      Alert.alert("Registration Failed", error.message);
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
    <View testID="register-page" style={styles.view}>
      <Text style={styles.title}>Create An Account</Text>

      <TextInput
        style={styles.input}
        placeholder="Username"
        placeholderTextColor={colorScheme.onSurfaceVariant}
        value={userName}
        onChangeText={setUserName}
        autoCapitalize="none"
      />

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

      <TextInput
        style={styles.input}
        placeholder="Confirm Password"
        placeholderTextColor={colorScheme.onSurfaceVariant}
        value={passwordConfirm}
        onChangeText={setPasswordConfirm}
        secureTextEntry
        autoCapitalize="none"
        autoCorrect={false}
        textContentType="password"
        autoComplete="password"
      />

      <TouchableOpacity
        style={styles.button}
        onPress={handleRegister}
        disabled={submitting}
      >
        {submitting ? (
          <ActivityIndicator color={colorScheme.onPrimary} />
        ) : (
          <Text style={styles.buttonText}>Register</Text>
        )}
      </TouchableOpacity>

      <TouchableOpacity onPress={() => router.replace("/account/login")}>
        <Text style={styles.linkText}>Already have an account? Log in</Text>
      </TouchableOpacity>
    </View>
  );
}

export default Register;