export interface LogEntry { 
  level: "log" | "warn" | "error"; 
  message: string; 
  time: number 
};

const buffer: LogEntry[] = [];
const listeners = new Set<() => void>();
const MAX = 300;

function emit() { listeners.forEach((fn) => fn()); }
function push(level: LogEntry["level"], args: any[]) {
  const message = args.map(a => {
    try { return typeof a === "string" ? a : JSON.stringify(a); }
    catch { return String(a); }
  }).join(" ");

  buffer.push({ level, message, time: Date.now() });
  if (buffer.length > MAX) buffer.splice(0, buffer.length - MAX);
  emit();
}

export function getLogs() { return buffer.slice(); }
export function subscribeLogs(fn: () => void) { listeners.add(fn); return () => listeners.delete(fn); }

export function installConsoleCapture() {
  const orig = {
    log: console.log.bind(console),
    warn: console.warn.bind(console),
    error: console.error.bind(console),
  };

  console.log = (...args) => { push("log", args); orig.log(...args); };
  console.warn = (...args) => { push("warn", args); orig.warn(...args); };
  console.error = (...args) => { push("error", args); orig.error(...args); };
}
