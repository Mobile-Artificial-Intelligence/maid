import { MaterialIconButton } from "@/components/buttons/icon-button";
import Popover from "@/components/views/popover-view";
import { useSystem } from "@/context";
import { useRouter } from "expo-router";
import React, { useRef, useState } from "react";
import {
  LayoutRectangle,
  StyleSheet,
  Text,
  TouchableOpacity,
  View
} from "react-native";

function MenuButton() {
  const router = useRouter();
  const { colorScheme } = useSystem();
  const [visible, setVisible] = useState(false);
  const [anchor, setAnchor] = useState<LayoutRectangle | null>(null);

  const anchorRef = useRef<View>(null);

  const open = () => {
    anchorRef.current?.measureInWindow((x, y, width, height) => {
      setAnchor({ x, y, width, height });
      setVisible(true);
    });
  };

  const styles = StyleSheet.create({
    link: {
      paddingVertical: 8,
      paddingHorizontal: 12,
      color: colorScheme.onSurface,
      fontSize: 16,
    },
  });

  return (
    <View style={{ margin: 4 }}>
      {/* THIS is what we measure */}
      <View ref={anchorRef} collapsable={false}>
        <MaterialIconButton icon="more-vert" size={28} onPress={open} />
      </View>

      <Popover
        position="bottom"
        anchor={anchor}
        offset={{ y: (anchor?.height ?? 0) * 2 }}
        width={120}
        visible={visible}
        onClose={() => setVisible(false)}
      >
        <TouchableOpacity
          onPress={() => {
            setVisible(false);
            router.push("/settings");
          }}
        >
          <Text style={styles.link}>Settings</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => {
            setVisible(false);
            router.push("/about");
          }}
        >
          <Text style={styles.link}>About</Text>
        </TouchableOpacity>
      </Popover>
    </View>
  );
}

export default MenuButton;
