import Popover from "@/components/views/popover-view";
import { useLLM, useSystem } from "@/context";
import Icon from "@expo/vector-icons/MaterialCommunityIcons";
import { useRouter } from "expo-router";
import React, { useRef, useState } from "react";
import {
  findNodeHandle,
  LayoutRectangle,
  StyleSheet,
  Text,
  TouchableOpacity,
  View
} from "react-native";

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
    item: { 
      paddingVertical: 10, 
      paddingHorizontal: 12,
      alignItems: "center",
    },
    popoverText: { 
      color: colorScheme.onSurface, 
      fontSize: 16 
    }
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

      <Popover
        position="bottom"
        anchor={anchor}
        offset={{ y: (anchor?.height ?? 0) * 3 }}
        width={180}
        visible={visible}
        onClose={() => setVisible(false)}
      >
        <TouchableOpacity
          style={styles.item}
          onPress={() => {
            setVisible(false);
            pickModelFile();
          }}
        >
          <Text style={styles.popoverText}>Load Model</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.item}
          onPress={() => {
            setVisible(false);
            router.push("/download");
          }}
        >
          <Text style={styles.popoverText}>Download Model</Text>
        </TouchableOpacity>
      </Popover>
    </View>
  );
}

export default ModelButton;