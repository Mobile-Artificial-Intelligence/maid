import { useSystem } from '@/context';
import getSupabase from '@/utilities/supabase';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';

export default function Index() {
  const router = useRouter();
  const { colorScheme } = useSystem();
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<boolean>(false);

  const styles = StyleSheet.create({
    view: {
      flex: 1,
      justifyContent: "center",
      alignItems: "center",
      flexDirection: "column",
      gap: 8,
      backgroundColor: colorScheme.surface,
    },
    row: {
      flexDirection: "row",
      gap: 16,
      justifyContent: "space-between",
    },
    buttonTextBase: {
      borderRadius: 20,
      paddingVertical: 8,
      paddingHorizontal: 32,
      fontSize: 16,
      textAlign: "center",
      fontWeight: "bold",
    },
    buttonTextPrimary: {
      color: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
    },
    buttonTextDanger: {
      color: colorScheme.onError,
      backgroundColor: colorScheme.error,
    },
  });

  const deleteAccount = async () => {
    try {
      const session = await getSupabase().auth.getSession();
      const token = session.data.session?.access_token;

      const res = await fetch(
        `${process.env.EXPO_PUBLIC_SUPABASE_URL}/functions/v1/delete-account`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      const data = await res.json();

      if (!res.ok || !data.success) {
        throw new Error(data.error ?? "Failed to delete account");
      }
      else {
        await getSupabase().auth.signOut();
        router.replace("/account/login");
      }
    } catch (error) {
      console.error("Error deleting account:", error);
    }
  }


  const logout = async () => {
    try {
      await getSupabase().auth.signOut();
      router.replace("/account/login");
    } catch (error) {
      console.error("Error during logout:", error);
    }
  };

  return (
    <View 
      testID="account-page" 
      style={styles.view}
    >
      <TouchableOpacity
        testID="logout-button"
        onPress={logout}
      >
        <Text
          style={[styles.buttonTextBase, styles.buttonTextPrimary]}
        >
          Logout
        </Text>
      </TouchableOpacity>
      <View style={styles.row}>
        <TouchableOpacity
          testID="change-password-button"
          onPress={() => router.push("/account/change-password" as any)}
        >
          <Text style={[styles.buttonTextBase, styles.buttonTextPrimary]}>
            Change Password
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          testID="delete-account-button"
          onPress={() => setShowDeleteConfirm(true)}
        >
          <Text
            style={[styles.buttonTextBase, styles.buttonTextDanger]}
          >
            Delete Account
          </Text>
        </TouchableOpacity>
      </View>
      <Modal
        visible={showDeleteConfirm}
        transparent
        animationType="fade"
        onRequestClose={() => setShowDeleteConfirm(false)}
      >
        <View style={{
          flex: 1,
          justifyContent: "center",
          alignItems: "center",
          backgroundColor: "rgba(0,0,0,0.5)"
        }}>
          <View style={{
            backgroundColor: colorScheme.surfaceVariant,
            padding: 32,
            borderRadius: 32,
            width: "80%",
            alignItems: "center",
            gap: 48
          }}>
            <Text style={{ color: colorScheme.onSurface, fontSize: 18, fontWeight: "bold", textAlign: "center" }}>
              Are you sure you want to delete your account?
            </Text>
            <View style={{ flexDirection: "row", gap: 16 }}>
              <TouchableOpacity 
                onPress={() => {
                  setShowDeleteConfirm(false);
                  deleteAccount();
                }} 
              >
                <Text style={[styles.buttonTextBase, styles.buttonTextPrimary]}>
                  Yes
                </Text>
              </TouchableOpacity>
              <TouchableOpacity 
                onPress={() => setShowDeleteConfirm(false)} 
              >
                <Text style={[styles.buttonTextBase, styles.buttonTextPrimary]}>
                  No
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}