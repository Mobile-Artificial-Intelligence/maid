import { Stack } from "expo-router";

function AccountLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
      }}
    >
      <Stack.Screen name="index" options={{ animation: "none" }} />
      <Stack.Screen name="login" options={{ animation: "none" }} />
      <Stack.Screen name="register" options={{ animation: "none" }} />
      <Stack.Screen name="change-password" options={{ animation: "none" }} />
    </Stack>
  );
}

export default AccountLayout;