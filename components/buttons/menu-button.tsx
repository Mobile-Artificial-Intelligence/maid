import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useSystem } from "@/context";
import { useRouter } from "expo-router";
import React, { useState } from "react";
import {
  Modal,
  StyleSheet,
  Text,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
} from "react-native";

function MenuButtonPopoverModal({
  visible,
  onClose,
}: {
  visible: boolean;
  onClose: () => void;
}) {
  const router = useRouter();
  const { colorScheme } = useSystem();

  const styles = StyleSheet.create({
    overlay: {
      flex: 1,
      backgroundColor: "transparent",
    },
    anchor: {
      flex: 1,
      alignItems: "flex-end",
    },
    popover: {
      position: "absolute",
      top: 120,
      right: 8,
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 8,
      width: 100,
      paddingVertical: 6,
      alignItems: "center",
    },
    link: {
      paddingVertical: 8,
      paddingHorizontal: 12,
      color: colorScheme.onSurface,
      fontSize: 16    
    }
  });

  return (
    <Modal
      transparent
      visible={visible}
      animationType="fade"
      onRequestClose={onClose}
      statusBarTranslucent
    >
      <TouchableWithoutFeedback onPress={onClose}>
        <View style={styles.overlay}>
          <View style={styles.anchor}>
            <TouchableWithoutFeedback>
              <View style={styles.popover}>
                <TouchableOpacity onPress={() => {
                  onClose();
                  router.push("/settings");
                }}>
                  <Text style={styles.link}>Settings</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={() => {
                  onClose();
                  router.push("/about");
                }}>
                  <Text style={styles.link}>About</Text>
                </TouchableOpacity>
              </View>
            </TouchableWithoutFeedback>
          </View>
        </View>
      </TouchableWithoutFeedback>
    </Modal>
  );
}

export default function MenuButton() {
  const { colorScheme } = useSystem();
  const [visible, setVisible] = useState(false);

  return (
    <View style={{ margin: 4 }}>
      <MaterialIconButton
        icon="more-vert"
        size={28}
        onPress={() => setVisible(true)}
      />
      <MenuButtonPopoverModal
        visible={visible}
        onClose={() => setVisible(false)}
      />
    </View>
  );
}
