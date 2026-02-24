import { MaterialIconButton } from "@/components/buttons/icon-button";
import { useSystem } from "@/context";
import React, { Fragment, useRef, useState } from "react";
import {
  Dimensions,
  LayoutRectangle,
  Modal,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
} from "react-native";

interface DropdownItem<T> {
  label: string | React.ReactNode;
  selectedLabel?: string | React.ReactNode;
  value: T;
}

interface DropdownProps<T> {
  items: DropdownItem<T>[];
  selectedValue: T;
  onValueChange: (value: T) => void;
}

const POPOVER_MIN_WIDTH = 180;
const POPOVER_VERT_GAP = 8;

function Dropdown<T>({
  items,
  selectedValue,
  onValueChange,
}: DropdownProps<T>) {
  const { colorScheme } = useSystem();
  const [open, setOpen] = useState(false);
  const [anchor, setAnchor] = useState<LayoutRectangle | null>(null);
  const rootRef = useRef<View>(null);

  const selectedItem =
    items.find((item) => item.value == selectedValue) ?? items[0];

  const openMenu = () => {
    if (rootRef.current) {
      rootRef.current.measureInWindow((x, y, width, height) => {
        setAnchor({ x, y, width, height });
        setOpen(true);
      });
    } else {
      setAnchor(null);
      setOpen(true);
    }
  };

  const closeMenu = () => setOpen(false);

  const styles = StyleSheet.create({
    rootWrapper: {
      alignSelf: "stretch",
    },
    root: {
      flexDirection: "row",
      alignItems: "center",
    },
    label: {
      color: colorScheme.onSurface,
      fontSize: 14,
      flexShrink: 1,
      textOverflow: "ellipsis",
      maxWidth: 200,
    },
    caret: { 
      paddingHorizontal: 6, 
      paddingVertical: 2 
    },
    overlay: { 
      flex: 1, 
      backgroundColor: "transparent" 
    },
    popover: {
      position: "absolute",
      backgroundColor: colorScheme.surfaceVariant,
      borderRadius: 12,
      paddingVertical: 6,
      maxHeight: 400,
    },
    itemBtn: { 
      paddingVertical: 10, 
      paddingHorizontal: 12 
    },
    itemText: { 
      color: colorScheme.onSurface, 
      fontSize: 14 
    },
  });

  // Compute popover position based on anchor, with clamping
  const popoverStyle = (() => {
    const screen = Dimensions.get("window");
    if (!anchor) {
      return { bottom: 0, left: 0, width: POPOVER_MIN_WIDTH };
    }
    const width = Math.max(POPOVER_MIN_WIDTH, anchor.width);
    let left = anchor.x + anchor.width / 2 - width / 2;
    left = Math.max(8, Math.min(left, screen.width - width - 8));

    // prefer below; if not enough space, put above
    let top = anchor.y + anchor.height + 80;
    if (top + 200 > screen.height) {
      top = anchor.y - 200 - POPOVER_VERT_GAP;
    }
    top = Math.max(8, Math.min(top, screen.height - 200 - 8));

    return { top, left, width };
  })();

  const Popover = (
    <Modal
      transparent
      visible={open}
      animationType="fade"
      onRequestClose={closeMenu}
      statusBarTranslucent
    >
      <TouchableWithoutFeedback onPress={closeMenu}>
        <View style={styles.overlay}>
          <TouchableWithoutFeedback>
            <ScrollView style={[styles.popover, popoverStyle]}>
              {items.map((item, idx) => (
                <Fragment key={`${item.label}-${idx}`}>
                  <TouchableOpacity
                    style={styles.itemBtn}
                    onPress={() => {
                      onValueChange(item.value);
                      closeMenu();
                    }}
                  >
                    {typeof item.label === "string" ? (
                      <Text style={styles.itemText}>{item.label}</Text>
                    ) : (
                      item.label
                    )}
                  </TouchableOpacity>
                </Fragment>
              ))}
            </ScrollView>
          </TouchableWithoutFeedback>
        </View>
      </TouchableWithoutFeedback>
    </Modal>
  );

  if (selectedItem && !selectedItem.selectedLabel) {
    selectedItem.selectedLabel = selectedItem.label;
  }

  return (
    <View ref={rootRef} style={styles.rootWrapper} collapsable={false}>
      <View style={styles.root}>
        {typeof selectedItem?.selectedLabel === "string" ? (
          <Text style={styles.label} numberOfLines={1}>
            {selectedItem.selectedLabel}
          </Text>
        ) : (
          selectedItem?.selectedLabel
        )}
        <MaterialIconButton
          icon={open ? "arrow-drop-up" : "arrow-drop-down"}
          size={30}
          style={styles.caret}
          onPress={openMenu}
        />
      </View>
      {open && Popover}
    </View>
  );
}

export default Dropdown;