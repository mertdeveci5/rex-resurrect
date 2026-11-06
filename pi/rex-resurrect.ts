// rex-resurrect: record which session file this Pi process has open, so
// `rex resurrect save` can resume it with `pi --session <file>` after a restart.
// session_start fires at startup and again after /new, /resume and /fork.
// @ts-nocheck

import { mkdirSync, rmSync, writeFileSync, renameSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const dir = join(homedir(), ".local/state/rex-resurrect/pi");
const file = join(dir, `${process.pid}.json`);

export default function (pi) {
  pi.on("session_start", (_event, ctx) => {
    try {
      const sessionFile = ctx?.sessionManager?.getSessionFile?.();
      if (typeof sessionFile !== "string" || !sessionFile.startsWith("/")) {
        rmSync(file, { force: true }); // --no-session: nothing to resume
        return;
      }
      mkdirSync(dir, { recursive: true });
      const tmp = `${file}.tmp`;
      writeFileSync(tmp, JSON.stringify({ pid: process.pid, sessionFile, cwd: process.cwd() }));
      renameSync(tmp, file);
    } catch {
      // Never break Pi over bookkeeping.
    }
  });
}
