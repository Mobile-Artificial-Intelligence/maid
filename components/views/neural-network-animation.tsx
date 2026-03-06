import { useSystem } from "@/context";
import { useEffect, useRef, useState } from "react";
import Svg, { Circle, Line } from "react-native-svg";

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

const L1 = ["1A", "1B", "1C"];
const L2 = ["2A", "2B", "2C", "2D", "2E"];
const L12 = ["1A-2A", "1A-2B", "1A-2C", "1A-2D", "1A-2E", "1B-2A", "1B-2B", "1B-2C", "1B-2D", "1B-2E", "1C-2A", "1C-2B", "1C-2C", "1C-2D", "1C-2E"];
const L3 = ["3A", "3B", "3C", "3D", "3E"];
const L23 = ["2E-3E", "2E-3D", "2E-3C", "2E-3B", "2E-3A", "2D-3E", "2D-3D", "2D-3C", "2D-3B", "2D-3A", "2C-3E", "2C-3D", "2C-3C", "2C-3B", "2C-3A", "2B-3E", "2B-3D", "2A-3C", "2B-3B", "2B-3A", "2A-3E", "2A-3D", "path1", "2A-3B", "2A-3A"];
const L4 = ["4A", "4B", "4C", "4D", "4E"];
const L34 = ["3E-4E", "3E-4D", "3E-4C", "3E-4B", "3E-4A", "3D-4E", "3D-4D", "3D-4C", "3D-4B", "3D-4A", "3C-4E", "3C-4D", "3C-4C", "3C-4B", "3C-4A", "3B-4E", "3B-4D", "3B-4C", "3B-4B", "3B-4A", "3A-4E", "3A-4D", "3A-4C", "3A-4B", "3A-4A"];
const L5 = ["5A", "5B", "5C"];
const L45 = ["4E-5C", "4E-5B", "4E-5A", "4D-5C", "4D-5B", "4D-5A", "4C-5C", "4C-5B", "4C-5A", "4B-5C", "4B-5B", "4B-5A", "4A-5C", "4A-5B", "4A-5A"];

// 9 phases over ~4s: 50ms initial pause, 460ms between phases, 250ms spread within each phase
const INITIAL_DELAY = 50;
const PHASE_GAP = 460;
const PHASE_SPREAD = 250;

type Props = {
  onDone?: () => void;
  repeat?: boolean;
};

function NeuralNetworkAnimation({ onDone, repeat = false }: Props) {
  const { colorScheme } = useSystem();
  const [visible, setVisible] = useState<Set<string>>(new Set());
  const [runKey, setRunKey] = useState(0);
  const onDoneRef = useRef(onDone);
  const repeatRef = useRef(repeat);
  onDoneRef.current = onDone;
  repeatRef.current = repeat;

  useEffect(() => {
    const phases = [
      shuffle([...L1]),
      shuffle([...L2]),
      shuffle([...L12]),
      shuffle([...L3]),
      shuffle([...L23]),
      shuffle([...L4]),
      shuffle([...L34]),
      shuffle([...L5]),
      shuffle([...L45]),
    ];

    setVisible(new Set());
    const timeouts: ReturnType<typeof setTimeout>[] = [];

    phases.forEach((phase, pi) => {
      const phaseStart = INITIAL_DELAY + pi * PHASE_GAP;
      phase.forEach((id, ei) => {
        const delay = phaseStart + (phase.length > 1 ? (ei / (phase.length - 1)) * PHASE_SPREAD : 0);
        timeouts.push(
          setTimeout(() => setVisible(v => { const n = new Set(v); n.add(id); return n; }), delay)
        );
      });
    });

    const doneAt = INITIAL_DELAY + (phases.length - 1) * PHASE_GAP + PHASE_SPREAD + 100;
    timeouts.push(
      setTimeout(() => {
        onDoneRef.current?.();
        if (repeatRef.current) {
          setTimeout(() => setRunKey(k => k + 1), 300);
        }
      }, doneAt)
    );

    return () => timeouts.forEach(clearTimeout);
  }, [runKey]);

  const o = (id: string): number => (visible.has(id) ? 1 : 0);

  return (
    <Svg
      id="neural-network-animation"
      width="100%"
      height="200px"
      viewBox="0 0 256.46249 140.18853"
      style={{ aspectRatio: 256.46249 / 140.18853, alignSelf: "center" }}
    >
    <Line
       x1={229.52361} y1={95.908183}
       x2={180.50348} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4E-5C")}
       id="4E-5C" />
    <Line
       x1={229.52361} y1={70.094273}
       x2={180.50348} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4E-5B")}
       id="4E-5B" />
    <Line
       x1={180.50348} y1={121.72209}
       x2={229.52361} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4E-5A")}
       id="4E-5A" />
    <Line
       x1={180.50348} y1={95.908193}
       x2={229.52361} y2={95.908183}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4D-5C")}
       id="4D-5C" />
    <Line
       x1={180.50348} y1={95.908193}
       x2={229.52361} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4D-5B")}
       id="4D-5B" />
    <Line
       x1={229.52361} y1={44.280363}
       x2={180.50348} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4D-5A")}
       id="4D-5A" />
    <Line
       x1={180.50348} y1={70.094273}
       x2={229.52361} y2={95.908183}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4C-5C")}
       id="4C-5C" />
    <Line
       x1={229.52361} y1={70.094273}
       x2={180.50348} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4C-5B")}
       id="4C-5B" />
    <Line
       x1={229.52361} y1={44.280363}
       x2={180.50348} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4C-5A")}
       id="4C-5A" />
    <Line
       x1={229.52361} y1={95.908183}
       x2={180.50348} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4B-5C")}
       id="4B-5C" />
    <Line
       x1={180.50348} y1={44.280363}
       x2={229.52361} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4B-5B")}
       id="4B-5B" />
    <Line
       x1={180.50348} y1={44.280363}
       x2={229.52361} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4B-5A")}
       id="4B-5A" />
    <Line
       x1={180.50348} y1={18.466453}
       x2={229.52361} y2={95.908183}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4A-5C")}
       id="4A-5C" />
    <Line
       x1={229.52361} y1={70.094273}
       x2={180.50348} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4A-5B")}
       id="4A-5B" />
    <Line
       x1={229.52361} y1={44.280363}
       x2={180.50348} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("4A-5A")}
       id="4A-5A" />
    <Circle
       id="5C"
       cx={229.52361} cy={95.908183}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("5C")}
       />
    <Circle
       id="5B"
       cx={229.52361} cy={70.094273}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("5B")}
       />
    <Circle
       id="5A"
       cx={229.52361} cy={44.280363}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("5A")}
       />
    <Line
       x1={180.50348} y1={121.72209}
       x2={128.23124} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3E-4E")}
       id="3E-4E" />
    <Line
       x1={180.50348} y1={95.908193}
       x2={128.23124} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3E-4D")}
       id="3E-4D" />
    <Line
       x1={128.23124} y1={121.72209}
       x2={180.50348} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3E-4C")}
       id="3E-4C" />
    <Line
       x1={180.50348} y1={44.280363}
       x2={128.23124} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3E-4B")}
       id="3E-4B" />
    <Line
       x1={128.23124} y1={121.72209}
       x2={180.50348} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3E-4A")}
       id="3E-4A" />
    <Line
       x1={128.23124} y1={95.908193}
       x2={180.50348} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3D-4E")}
       id="3D-4E" />
    <Line
       x1={128.23124} y1={95.908193}
       x2={180.50348} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3D-4D")}
       id="3D-4D" />
    <Line
       x1={180.50348} y1={70.094273}
       x2={128.23124} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3D-4C")}
       id="3D-4C" />
    <Line
       x1={128.23124} y1={95.908193}
       x2={180.50348} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3D-4B")}
       id="3D-4B" />
    <Line
       x1={128.23124} y1={95.908193}
       x2={180.50348} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3D-4A")}
       id="3D-4A" />
    <Line
       x1={128.23124} y1={70.094273}
       x2={180.50348} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3C-4E")}
       id="3C-4E" />
    <Line
       x1={128.23124} y1={70.094273}
       x2={180.50348} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3C-4D")}
       id="3C-4D" />
    <Line
       x1={180.50348} y1={70.094273}
       x2={128.23124} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3C-4C")}
       id="3C-4C" />
    <Line
       x1={180.50348} y1={44.280363}
       x2={128.23124} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3C-4B")}
       id="3C-4B" />
    <Line
       x1={180.50348} y1={18.466453}
       x2={128.23124} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3C-4A")}
       id="3C-4A" />
    <Line
       x1={180.50348} y1={121.72209}
       x2={128.23124} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3B-4E")}
       id="3B-4E" />
    <Line
       x1={128.23124} y1={44.280363}
       x2={180.50348} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3B-4D")}
       id="3B-4D" />
    <Line
       x1={128.23124} y1={44.280363}
       x2={180.50348} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3B-4C")}
       id="3B-4C" />
    <Line
       x1={128.23124} y1={44.280363}
       x2={180.50348} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3B-4B")}
       id="3B-4B" />
    <Line
       x1={180.50348} y1={18.466453}
       x2={128.23124} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3B-4A")}
       id="3B-4A" />
    <Line
       x1={180.50348} y1={121.72209}
       x2={128.23124} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3A-4E")}
       id="3A-4E" />
    <Line
       x1={180.50348} y1={95.908193}
       x2={128.23124} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3A-4D")}
       id="3A-4D" />
    <Line
       x1={180.50348} y1={70.094273}
       x2={128.23124} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3A-4C")}
       id="3A-4C" />
    <Line
       x1={128.23124} y1={18.466453}
       x2={180.50348} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3A-4B")}
       id="3A-4B" />
    <Line
       x1={180.50348} y1={18.466453}
       x2={128.23124} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("3A-4A")}
       id="3A-4A" />
    <Circle
       id="4E"
       cx={180.50348} cy={121.72209}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("4E")}
       />
    <Circle
       id="4D"
       cx={180.50348} cy={95.908193}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("4D")}
       />
    <Circle
       id="4C"
       cx={180.50348} cy={70.094273}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("4C")}
       />
    <Circle
       id="4B"
       cx={180.50348} cy={44.280363}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("4B")}
       />
    <Circle
       id="4A"
       cx={180.50348} cy={18.466453}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("4A")}
       />
    <Line
       x1={128.23124} y1={121.72209}
       x2={75.958993} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2E-3E")}
       id="2E-3E" />
    <Line
       x1={128.23124} y1={95.908193}
       x2={75.958992} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2E-3D")}
       id="2E-3D" />
    <Line
       x1={75.958992} y1={121.72209}
       x2={128.23124} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2E-3C")}
       id="2E-3C" />
    <Line
       x1={128.23124} y1={44.280363}
       x2={75.958992} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2E-3B")}
       id="2E-3B" />
    <Line
       x1={75.958992} y1={121.72209}
       x2={128.23124} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2E-3A")}
       id="2E-3A" />
    <Line
       x1={75.958992} y1={95.908193}
       x2={128.23124} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2D-3E")}
       id="2D-3E" />
    <Line
       x1={75.958993} y1={95.908193}
       x2={128.23124} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2D-3D")}
       id="2D-3D" />
    <Line
       x1={128.23124} y1={70.094273}
       x2={75.958992} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2D-3C")}
       id="2D-3C" />
    <Line
       x1={75.958992} y1={95.908193}
       x2={128.23124} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2D-3B")}
       id="2D-3B" />
    <Line
       x1={128.23124} y1={18.466453}
       x2={75.958992} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2D-3A")}
       id="2D-3A" />
    <Line
       x1={75.958995} y1={70.094273}
       x2={128.23124} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2C-3E")}
       id="2C-3E" />
    <Line
       x1={75.958992} y1={70.094273}
       x2={128.23124} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2C-3D")}
       id="2C-3D" />
    <Line
       x1={128.23124} y1={70.094273}
       x2={75.958993} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2C-3C")}
       id="2C-3C" />
    <Line
       x1={128.23124} y1={44.280363}
       x2={75.958992} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2C-3B")}
       id="2C-3B" />
    <Line
       x1={128.23124} y1={18.466453}
       x2={75.958995} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2C-3A")}
       id="2C-3A" />
    <Line
       x1={128.23124} y1={121.72209}
       x2={75.958995} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2B-3E")}
       id="2B-3E" />
    <Line
       x1={75.958995} y1={44.280363}
       x2={128.23124} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2B-3D")}
       id="2B-3D" />
    <Line
       x1={75.958992} y1={44.280363}
       x2={128.23124} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2A-3C")}
       id="2A-3C" />
    <Line
       x1={75.958993} y1={44.280363}
       x2={128.23124} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2B-3B")}
       id="2B-3B" />
    <Line
       x1={128.23124} y1={18.466453}
       x2={75.958992} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2B-3A")}
       id="2B-3A" />
    <Line
       x1={128.23124} y1={121.72209}
       x2={75.958995} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2A-3E")}
       id="2A-3E" />
    <Line
       x1={75.958995} y1={18.466453}
       x2={128.23124} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2A-3D")}
       id="2A-3D" />
    <Line
       x1={128.23124} y1={70.094273}
       x2={75.958995} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("path1")}
       id="path1" />
    <Line
       x1={75.958995} y1={18.466453}
       x2={128.23124} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2A-3B")}
       id="2A-3B" />
    <Line
       x1={128.23124} y1={18.466453}
       x2={75.958993} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("2A-3A")}
       id="2A-3A" />
    <Circle
       id="3E"
       cx={128.23124} cy={121.72209}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("3E")}
       />
    <Circle
       id="3D"
       cx={128.23124} cy={95.908193}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("3D")}
       />
    <Circle
       id="3C"
       cx={128.23124} cy={70.094273}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("3C")}
       />
    <Circle
       id="3B"
       cx={128.23124} cy={44.280363}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("3B")}
       />
    <Circle
       id="3A"
       cx={128.23124} cy={18.466453}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("3A")}
       />
    <Line
       x1={75.958993} y1={121.72209}
       x2={26.938867} y2={95.908183}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1C-2E")}
       id="1C-2E" />
    <Line
       x1={26.938867} y1={95.908183}
       x2={75.958995} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1C-2D")}
       id="1C-2D" />
    <Line
       x1={75.958995} y1={70.094273}
       x2={26.938867} y2={95.908183}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1C-2C")}
       id="1C-2C" />
    <Line
       x1={26.938867} y1={95.908183}
       x2={75.958995} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1C-2B")}
       id="1C-2B" />
    <Line
       x1={75.958995} y1={18.466453}
       x2={26.938867} y2={95.908183}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1C-2A")}
       id="1C-2A" />
    <Line
       x1={75.958995} y1={121.72209}
       x2={26.938867} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1B-2E")}
       id="1B-2E" />
    <Line
       x1={26.938867} y1={70.094273}
       x2={75.958993} y2={95.908193}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1B-2D")}
       id="1B-2D" />
    <Line
       x1={75.958993} y1={70.094273}
       x2={26.938867} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1B-2C")}
       id="1B-2C" />
    <Line
       x1={75.958995} y1={44.280363}
       x2={26.938867} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1B-2B")}
       id="1B-2B" />
    <Line
       x1={26.938867} y1={70.094273}
       x2={75.958995} y2={18.466453}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1B-2A")}
       id="1B-2A" />
    <Line
       x1={26.938867} y1={44.280363}
       x2={75.958995} y2={121.72209}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1A-2E")}
       id="1A-2E" />
    <Line
       x1={75.958995} y1={95.908193}
       x2={26.938867} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1A-2D")}
       id="1A-2D" />
    <Line
       x1={26.938867} y1={44.280363}
       x2={75.958995} y2={70.094273}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1A-2C")}
       id="1A-2C" />
    <Line
       x1={26.938867} y1={44.280363}
       x2={75.958993} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1A-2B")}
       id="1A-2B" />
    <Line
       x1={75.958993} y1={18.466453}
       x2={26.938867} y2={44.280363}
       stroke={colorScheme.onPrimaryContainer}
       strokeWidth={1.5}
       strokeLinecap="square"
       strokeOpacity={1}
       opacity={o("1A-2A")}
       id="1A-2A" />
    <Circle
       id="2E"
       cx={75.958993} cy={121.72209}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("2E")}
       />
    <Circle
       id="2D"
       cx={75.958993} cy={95.908193}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("2D")}
       />
    <Circle
       id="2C"
       cx={75.958993} cy={70.094273}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("2C")}
       />
    <Circle
       id="2B"
       cx={75.958993} cy={44.280363}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("2B")}
       />
    <Circle
       id="2A"
       cx={75.958993} cy={18.466453}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("2A")}
       />
    <Circle
       id="1C"
       cx={26.938867} cy={95.908183}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("1C")}
       />
    <Circle
       id="1B"
       cx={26.938867} cy={70.094273}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("1B")}
       />
    <Circle
       id="1A"
       cx={26.938867} cy={44.280363}
       r={5.625}
       fill={colorScheme.outlineVariant}
       fillOpacity={1}
       opacity={o("1A")}
       />
    </Svg>
  );
}

export default NeuralNetworkAnimation;
