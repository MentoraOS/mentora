import { runServerProcess } from './startup/run-server-process.js';

/**
 * The first living process of Mentora — the Application species (F5.1).
 * This file is the PURE PROCESS WIRE: it lends the real `process` and the
 * real stderr to runServerProcess and nothing else — every behavior
 * (configuration, Root, boot, signals, report, death) lives in
 * runServerProcess and is fully proven there. Excluded from coverage the
 * way barrels are: zero logic may ever live here.
 */
void runServerProcess({
  on: (signal, handler) => {
    process.on(signal, handler);
  },
  exit: (code) => {
    process.exit(code);
  },
  stderrLine: (line) => {
     
    console.error(line);
  },
});
