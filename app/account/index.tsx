import { useSystem } from '@/context';
import useAuthentication from '@/hooks/use-authentication';
import getSupabase from '@/utilities/supabase';
import { Redirect } from 'expo-router';
import { useState } from 'react';
import { Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';

export default function Index() {
  const [authenticated, anonymous] = useAuthentication();
  const { colorScheme } = useSystem();
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<boolean>(false);

  const styles = StyleSheet.create({
    view: {
      flex: 1,
      justifyContent: "center",
      alignItems: "center",
      flexDirection: "column",
      gap: 16,
      backgroundColor: colorScheme.surface,
    },
    button: {
      marginTop: 8,
    },
    buttonTextBase: {
      borderRadius: 20,
      paddingVertical: 12,
      paddingHorizontal: 48,
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
    } catch (error) {
      console.error("Error deleting account:", error);
    }
  }


  const logout = async () => {
    try {
      await getSupabase().auth.signOut();
    } catch (error) {
      console.error("Error during logout:", error);
    }
  };
  
  if (!authenticated || anonymous) {
    return <Redirect href="/account/login" />;
  }

  return (
    <View 
      testID="account-page" 
      style={styles.view}
    >
      <TouchableOpacity 
        testID="logout-button" 
        onPress={logout} 
        style={styles.button}
      >
        <Text 
          style={[styles.buttonTextBase, styles.buttonTextPrimary]}
        >
          Logout
        </Text>
      </TouchableOpacity>
      <TouchableOpacity 
        testID="delete-account-button"
        onPress={() => setShowDeleteConfirm(true)}
        style={styles.button}
      >
        <Text 
          style={[styles.buttonTextBase, styles.buttonTextDanger]}
        >
          Delete Account
        </Text>
      </TouchableOpacity>
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
            backgroundColor: colorScheme.surface,
            padding: 24,
            borderRadius: 8,
            width: "80%",
            alignItems: "center",
            gap: 16
          }}>
            <Text style={{ color: colorScheme.onSurface, fontSize: 18, fontWeight: "bold" }}>
              Are you sure you want to delete your account?
            </Text>
            <View style={{ flexDirection: "row", gap: 16 }}>
              <TouchableOpacity 
                onPress={() => setShowDeleteConfirm(false)} 
                style={[styles.button, { backgroundColor: colorScheme.outline }]}
              >
                <Text style={[styles.buttonTextBase, { color: colorScheme.onSurface }]}>
                  Cancel
                </Text>
              </TouchableOpacity>
              <TouchableOpacity 
                onPress={() => {
                  setShowDeleteConfirm(false);
                  deleteAccount();
                }} 
                style={[styles.button, styles.buttonTextDanger]}
              >
                <Text style={[styles.buttonTextBase, styles.buttonTextDanger]}>
                  Delete
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}