"use client";

import { useEffect, useRef, useState } from "react";
import styles from "./carousel.module.css";
import Image from "next/image";

export default function Carousel() {
  const carouselRef = useRef<HTMLDivElement | null>(null);

  const isDraggingRef = useRef(false);
  const movedRef = useRef(false);
  const startXRef = useRef(0);
  const scrollLeftRef = useRef(0);

  const [expandedIndex, setExpandedIndex] = useState<number | null>(null);

  useEffect(() => {
    const carousel = carouselRef.current;
    if (!carousel) return;

    const onPointerDown = (e: PointerEvent) => {
      // only left click / primary pointer
      if (e.button !== 0) return;
      if (expandedIndex !== null) return;

      isDraggingRef.current = true;
      movedRef.current = false;

      carousel.classList.add(styles.dragging);

      startXRef.current = e.clientX;
      scrollLeftRef.current = carousel.scrollLeft;

      // capture pointer so drag continues even if cursor leaves element
      carousel.setPointerCapture?.(e.pointerId);
    };

    const onPointerMove = (e: PointerEvent) => {
      if (!isDraggingRef.current) return;

      const dx = e.clientX - startXRef.current;

      // small threshold so click doesn't count as drag
      if (Math.abs(dx) > 4) {
        movedRef.current = true;
      }

      carousel.scrollLeft = scrollLeftRef.current - dx;

      // prevent text selection / accidental image drag
      e.preventDefault();
    };

    const stopDragging = (e?: PointerEvent) => {
      if (!isDraggingRef.current) return;
      isDraggingRef.current = false;
      carousel.classList.remove(styles.dragging);

      if (e) {
        carousel.releasePointerCapture?.(e.pointerId);
      }
    };

    carousel.addEventListener("pointerdown", onPointerDown);
    carousel.addEventListener("pointermove", onPointerMove);
    carousel.addEventListener("pointerup", stopDragging);
    carousel.addEventListener("pointercancel", stopDragging);
    carousel.addEventListener("pointerleave", stopDragging);

    return () => {
      carousel.removeEventListener("pointerdown", onPointerDown);
      carousel.removeEventListener("pointermove", onPointerMove);
      carousel.removeEventListener("pointerup", stopDragging);
      carousel.removeEventListener("pointercancel", stopDragging);
      carousel.removeEventListener("pointerleave", stopDragging);
    };
  }, [expandedIndex]);

  const toggleImage = (index: number) => {
    // If the pointer moved, treat it as drag, not click
    if (movedRef.current) {
      movedRef.current = false;
      return;
    }

    setExpandedIndex((prev) => (prev === index ? null : index));
  };

  return (
    <>
      <div className={styles.carousel} ref={carouselRef}>
        {Array.from({ length: 8 }, (_, i) => (
          <Image
            key={i}
            width={225}
            height={500}
            src={`/images/maid-screenshot-${i + 1}.png`}
            alt={`mobile ai distribution ${i + 1}`}
            onClick={() => toggleImage(i)}
            className={`${styles.carouselImg} ${
              expandedIndex === i ? styles.expanded : ""
            }`}
            draggable={false}
            sizes="(min-width: 1536px) 300px, (min-width: 768px) 225px, 150px"
          />
        ))}
      </div>

      {/* optional backdrop */}
      {expandedIndex !== null && (
        <div
          className={styles.backdrop}
          onClick={() => setExpandedIndex(null)}
          aria-hidden="true"
        />
      )}
    </>
  );
}