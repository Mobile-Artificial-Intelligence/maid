import { useCallback, useRef, useState } from "react";
import type { LayoutRectangle, View } from "react-native";

function usePopover() {
  const anchorRef = useRef<View>(null);
  const [visible, setVisible] = useState(false);
  const [anchor, setAnchor] = useState<LayoutRectangle | null>(null);

  const open = useCallback(() => {
    const node: any = anchorRef.current;
    if (node?.measureInWindow) {
      node.measureInWindow((x: number, y: number, width: number, height: number) => {
        setAnchor({ x, y, width, height });
        setVisible(true);
      });
    } else {
      setAnchor(null);
      setVisible(true);
    }
  }, []);

  const close = useCallback(() => setVisible(false), []);

  return { anchorRef, anchor, visible, open, close, setVisible, setAnchor };
}

export default usePopover;
