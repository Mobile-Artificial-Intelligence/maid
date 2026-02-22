"use client"; // required for useEffect and refs in app directory

import { useEffect, useRef } from "react";
import styles from "./carousel.module.css";
import Image from "next/image";

export default function Carousel() {
  const carouselRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const carousel = carouselRef.current;
    if (!carousel) return;

    let isDown = false;
    let startX = 0;
    let scrollLeft = 0;

    const startDragging = (x: number) => {
      if (carousel.querySelector(`.${styles.expanded}`)) return;
      isDown = true;
      carousel.classList.add(styles.dragging);
      startX = x - carousel.offsetLeft;
      scrollLeft = carousel.scrollLeft;
    };

    const stopDragging = () => {
      isDown = false;
      carousel.classList.remove(styles.dragging);
    };

    const doDragging = (x: number) => {
      if (!isDown) return;
      const walk = x - carousel.offsetLeft - startX;
      carousel.scrollLeft = scrollLeft - walk;
    };

    const mouseDown = (e: MouseEvent) => startDragging(e.pageX);
    const mouseMove = (e: MouseEvent) => {
      if (!isDown) return;
      e.preventDefault();
      doDragging(e.pageX);
    };
    const mouseUp = stopDragging;
    const mouseLeave = stopDragging;

    const touchStart = (e: TouchEvent) => {
      if (e.touches.length === 1 && !carousel.querySelector(`.${styles.expanded}`)) {
        startDragging(e.touches[0].pageX);
      }
    };
    const touchMove = (e: TouchEvent) => {
      if (!isDown) return;
      doDragging(e.touches[0].pageX);
    };
    const touchEnd = stopDragging;

    carousel.addEventListener("mousedown", mouseDown);
    carousel.addEventListener("mousemove", mouseMove);
    carousel.addEventListener("mouseup", mouseUp);
    carousel.addEventListener("mouseleave", mouseLeave);

    carousel.addEventListener("touchstart", touchStart, { passive: false });
    carousel.addEventListener("touchmove", touchMove, { passive: false });
    carousel.addEventListener("touchend", touchEnd);

    return () => {
      carousel.removeEventListener("mousedown", mouseDown);
      carousel.removeEventListener("mousemove", mouseMove);
      carousel.removeEventListener("mouseup", mouseUp);
      carousel.removeEventListener("mouseleave", mouseLeave);
      carousel.removeEventListener("touchstart", touchStart);
      carousel.removeEventListener("touchmove", touchMove);
      carousel.removeEventListener("touchend", touchEnd);
    };
  }, []);

  const toggleImage = (e: React.MouseEvent<HTMLImageElement>) => {
    const img = e.currentTarget;
    img.classList.toggle(styles.expanded);
  };

  return (
    <div className={styles.carousel} ref={carouselRef}>
      {Array.from({ length: 7 }, (_, i) => (
        <Image
          key={i}
          width={225}
          height={500}
          src={`/images/maid-screenshot-${i + 1}.png`}
          alt={`mobile ai distribution ${i + 1}`}
          onClick={toggleImage}
          style={{ pointerEvents: "auto", cursor: "zoom-in" }}
          className={styles.carouselImg}
          draggable={false}
        />
      ))}
    </div>
  );
}
