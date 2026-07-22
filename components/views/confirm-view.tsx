import { useSystem } from "@/context";
import { Modal, StyleSheet, Text, TouchableOpacity, View } from "react-native";

interface ConfirmViewProps {
  testID?: string;
  confirmTestID?: string;
  cancelTestID?: string;
  visible: boolean;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  onConfirm: () => void;
  onCancel: () => void;
}

function ConfirmView({
  testID,
  confirmTestID,
  cancelTestID,
  visible,
  message,
  confirmLabel = "Yes",
  cancelLabel = "No",
  onConfirm,
  onCancel,
}: ConfirmViewProps) {
  const { colorScheme } = useSystem();

  const styles = StyleSheet.create({
    overlay: {
      flex: 1,
      justifyContent: "center",
      alignItems: "center",
      backgroundColor: "rgba(0,0,0,0.5)",
    },
    card: {
      backgroundColor: colorScheme.surfaceVariant,
      padding: 32,
      borderRadius: 32,
      width: "80%",
      alignItems: "center",
      gap: 48,
    },
    message: {
      color: colorScheme.onSurface,
      fontSize: 18,
      fontWeight: "bold",
      textAlign: "center",
    },
    row: {
      flexDirection: "row",
      gap: 16,
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

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onCancel}
      statusBarTranslucent
      navigationBarTranslucent
    >
      <View style={styles.overlay}>
        <View testID={testID} style={styles.card}>
          <Text style={styles.message}>
            {message}
          </Text>
          <View style={styles.row}>
            <TouchableOpacity
              testID={confirmTestID}
              onPress={onConfirm}
            >
              <Text
                style={[
                  styles.buttonTextBase,
                  styles.buttonTextPrimary
                ]}
              >
                {confirmLabel}
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              testID={cancelTestID}
              onPress={onCancel}
            >
              <Text style={[styles.buttonTextBase, styles.buttonTextPrimary]}>
                {cancelLabel}
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
}

export default ConfirmView;
