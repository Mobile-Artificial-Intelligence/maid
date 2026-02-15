import { useSystem } from "@/context";
import { ReactNode, useMemo, useState } from "react";
import {
  Dimensions,
  LayoutChangeEvent,
  LayoutRectangle,
  Modal,
  StyleSheet,
  TouchableWithoutFeedback,
  View,
} from "react-native";

const EDGE_PADDING = 8;
const GAP = 6;

type PopoverPosition = "top" | "bottom" | "left" | "right";
type PopoverAlign = "start" | "center" | "end";

interface PopoverViewProps {
  position: PopoverPosition;
  /**
   * For bottom/top: controls horizontal alignment relative to the anchor
   * For left/right: controls vertical alignment relative to the anchor
   */
  align?: PopoverAlign;
  /** Pixel offset applied after alignment (useful for nudging below, etc.) */
  offset?: { x?: number; y?: number };

  anchor: LayoutRectangle | null;
  width: number;
  visible: boolean;
  onClose: () => void;
  children: ReactNode;
}

const clamp = (v: number, min: number, max: number) => Math.max(min, Math.min(v, max));

function Popover({
  position,
  align = "center",
  offset,
  anchor,
  width,
  visible,
  onClose,
  children,
}: PopoverViewProps) {
  const { colorScheme } = useSystem();
  const { width: screenW, height: screenH } = Dimensions.get("window");
  const [popoverH, setPopoverH] = useState(0);

  const onPopoverLayout = (e: LayoutChangeEvent) => {
    const h = e.nativeEvent.layout.height;
    if (h !== popoverH) setPopoverH(h);
  };

  const popoverPositionStyle = useMemo(() => {
    const offX = offset?.x ?? 0;
    const offY = offset?.y ?? 0;

    if (!anchor) {
      return { top: EDGE_PADDING + offY, left: EDGE_PADDING + offX };
    }

    // Horizontal align helpers (for top/bottom)
    const leftStart = anchor.x;
    const leftCenter = anchor.x + anchor.width / 2 - width / 2;
    const leftEnd = anchor.x + anchor.width - width;

    const alignedLeftRaw =
      align === "start" ? leftStart : align === "end" ? leftEnd : leftCenter;

    // Vertical align helpers (for left/right)
    const topStart = anchor.y;
    const topCenter = anchor.y + anchor.height / 2 - popoverH / 2;
    const topEnd = anchor.y + anchor.height - popoverH;

    const alignedTopRaw =
      align === "start" ? topStart : align === "end" ? topEnd : topCenter;

    // Compute top/left per position, then apply offsets + clamp.
    let left = 0;
    let top = 0;

    switch (position) {
      case "bottom":
        left = alignedLeftRaw;
        top = anchor.y + anchor.height + GAP;
        break;

      case "top":
        left = alignedLeftRaw;
        top = anchor.y - popoverH - GAP; // uses popoverH; first render may adjust after layout
        break;

      case "right":
        left = anchor.x + anchor.width + GAP;
        top = alignedTopRaw;
        break;

      case "left":
        left = anchor.x - width - GAP;
        top = alignedTopRaw;
        break;
    }

    left = clamp(left + offX, EDGE_PADDING, screenW - width - EDGE_PADDING);
    top = clamp(top + offY, EDGE_PADDING, screenH - popoverH - EDGE_PADDING);

    return { left, top };
  }, [anchor, position, align, offset?.x, offset?.y, popoverH, screenW, screenH]);

  const styles = useMemo(
    () =>
      StyleSheet.create({
        overlay: { flex: 1, backgroundColor: "transparent" },
        container: { flex: 1 },
        popoverBase: {
          position: "absolute",
          width: width,
          backgroundColor: colorScheme.surfaceVariant,
          borderRadius: 8,
          paddingVertical: 6,
        },
      }),
    [colorScheme.surfaceVariant, width]
  );

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
              <View onLayout={onPopoverLayout} style={[styles.popoverBase, popoverPositionStyle]}>
                {children}
              </View>
            </TouchableWithoutFeedback>
          </View>
        </View>
      </TouchableWithoutFeedback>
    </Modal>
  );
}

export default Popover;
