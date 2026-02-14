import { useLLM, useSystem } from "@/context";
import Icon from "@expo/vector-icons/MaterialCommunityIcons";
import { useRouter } from "expo-router";
import React, { useRef, useState } from "react";
import {
  Dimensions,
  findNodeHandle,
  LayoutRectangle,
  Modal,
  StyleSheet,
  Text,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
} from "react-native";

const POPOVER_WIDTH = 150;

function ModelButtonPopover({
  visible,
  onClose,
  anchor, // { x, y, width, height } in screen coords
  onLoadModel,
  onDownloadModel,
}: {
  visible: boolean;
  onClose: () => void;
  anchor: LayoutRectangle | null;
  onLoadModel: () => void | Promise<void>;
  onDownloadModel: () => void | Promise<void>;
}) {
  const { colorScheme } = useSystem();
  const screenW = Dimensions.get("window").width;

  let left = 0;
  if (anchor) {
    left = anchor.x + anchor.width / 2 - POPOVER_WIDTH / 2;
    left = Math.max(8, Math.min(left, screenW - POPOVER_WIDTH - 8));
  }

  const styles = StyleSheet.create({
    overlay: { 
      flex: 1, 
      backgroundColor: "transparent" 
    },
    container: { 
      flex: 1 
    },
    popover: {
      position: "absolute",
      top: 120,
      left,
      width: POPOVER_WIDTH,
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 8,
      paddingVertical: 6,
    },
    item: { 
      paddingVertical: 10, 
      paddingHorizontal: 12,
      alignItems: "center",
    },
    text: { 
      color: colorScheme.onSurface, 
      fontSize: 16 
    }
  });

  const click = async (fn: () => void | Promise<void>) => {
    onClose();
    await Promise.resolve(fn());
  };

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
          <View style={styles.container}>
            <TouchableWithoutFeedback>
              <View style={styles.popover}>
                <TouchableOpacity style={styles.item} onPress={() => click(onLoadModel)}>
                  <Text style={styles.text} numberOfLines={1}>Load Model</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.item} onPress={() => click(onDownloadModel)}>
                  <Text style={styles.text} numberOfLines={1}>Download Model</Text>
                </TouchableOpacity>
              </View>
            </TouchableWithoutFeedback>
          </View>
        </View>
      </TouchableWithoutFeedback>
    </Modal>
  );
}

function ModelButton() {
  const router = useRouter();
  const { colorScheme } = useSystem();
  const { modelFileKey, pickModelFile } = useLLM();

  const [visible, setVisible] = useState(false);
  const [anchor, setAnchor] = useState<LayoutRectangle | null>(null);
  const buttonRef = useRef<View>(null);

  if (!pickModelFile) return null;

  const open = () => {
    // Measure button position in window coords so we can anchor the popover
    const node = findNodeHandle(buttonRef.current);
    if (buttonRef.current && node) {
      buttonRef.current.measureInWindow((x, y, width, height) => {
        setAnchor({ x, y, width, height });
        setVisible(true);
      });
    } else {
      setAnchor(null);
      setVisible(true);
    }
  };

  const styles = StyleSheet.create({
    wrapper: { 
      marginHorizontal: 24, 
      marginVertical: 6, 
      maxWidth: 500, 
      flex: 1 
    },
    button: {
      backgroundColor: colorScheme.primary,
      flexDirection: "row",
      borderRadius: 8,
      paddingVertical: 2,
      paddingHorizontal: 8,
      alignItems: "center",
    },
    text: {
      color: colorScheme.onPrimary,
      fontSize: 14,
      flex: 1,
      textAlign: "center",
    },
  });

  return (
    <View ref={buttonRef} style={styles.wrapper} collapsable={false}>
      <TouchableOpacity style={styles.button} onPress={open} activeOpacity={0.8}>
        <Icon name="chevron-triple-left" size={20} color={colorScheme.onPrimary} />
        <Text style={styles.text} numberOfLines={1}>
          {modelFileKey ? modelFileKey : "Load Model"}
        </Text>
        <Icon name="chevron-triple-right" size={20} color={colorScheme.onPrimary} />
      </TouchableOpacity>

      <ModelButtonPopover
        visible={visible}
        onClose={() => setVisible(false)}
        anchor={anchor}
        onLoadModel={() => pickModelFile()}
        onDownloadModel={() => {
          router.push("/download");
        }}
      />
    </View>
  );
}

export default ModelButton;