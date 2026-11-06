#!/bin/sh
# Install rex resurrect: save the Claude Code, Codex and Pi conversations open
# in Rex panes, and resume them after Rex or the Mac restarts.
#
#   curl -fsSL https://raw.githubusercontent.com/mertdeveci5/rex-resurrect/main/install.sh | sh
#
# Safe to run again: it updates the files and adds the shell function once.
set -eu

REPO_RAW="https://raw.githubusercontent.com/mertdeveci5/rex-resurrect/main"
BIN_DIR="$HOME/.local/bin"
PI_DIR="$HOME/.pi/agent/extensions"
MARK_BEGIN="# >>> rex resurrect >>>"
MARK_END="# <<< rex resurrect <<<"

say() { printf '%s\n' "$*"; }
fail() { printf 'rex-resurrect install: %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "rex resurrect supports macOS only."
command -v python3 >/dev/null 2>&1 || fail "python3 is required (xcode-select --install provides it)."
command -v rex >/dev/null 2>&1 || say "Note: the rex CLI isn't on PATH yet. Install Rex, then run rex resurrect from a Rex pane."

# Use the files next to this script when run from a clone, else download them.
HERE=""
case "$0" in */install.sh) HERE=$(cd "$(dirname "$0")" && pwd) ;; esac
fetch() { # fetch SOURCE DEST
  if [ -n "$HERE" ] && [ -f "$HERE/$1" ]; then
    cp "$HERE/$1" "$2"
  else
    curl -fsSL "$REPO_RAW/$1" -o "$2" || fail "couldn't download $1"
  fi
}

mkdir -p "$BIN_DIR"
fetch rex-resurrect "$BIN_DIR/rex-resurrect.tmp"
chmod +x "$BIN_DIR/rex-resurrect.tmp"
mv "$BIN_DIR/rex-resurrect.tmp" "$BIN_DIR/rex-resurrect"
say "Installed $BIN_DIR/rex-resurrect"

if [ -d "$HOME/.pi/agent" ]; then
  mkdir -p "$PI_DIR"
  fetch pi/rex-resurrect.ts "$PI_DIR/rex-resurrect.ts"
  say "Installed the Pi extension: $PI_DIR/rex-resurrect.ts (takes effect in new Pi sessions)"
fi

# `rex resurrect ...` runs this tool; every other `rex` command is unchanged.
case "${SHELL:-}" in
  */zsh) RC="$HOME/.zshrc" ;;
  */bash) RC="$HOME/.bashrc" ;;
  *) RC="" ;;
esac
if [ -z "$RC" ]; then
  say "Your shell isn't zsh or bash, so no shell function was added."
  say "Run the tool as: $BIN_DIR/rex-resurrect save   (and without 'save' to restore)"
elif grep -q 'rex-resurrect' "$RC" 2>/dev/null; then
  say "$RC already sets up rex resurrect; left as it is."
else
  cat >>"$RC" <<EOF

$MARK_BEGIN
# \`rex resurrect save\` before quitting; \`rex resurrect\` after reopening. See rex-resurrect --help.
rex() {
  if [[ \$1 == resurrect ]]; then
    shift
    "\$HOME/.local/bin/rex-resurrect" "\$@"
  else
    command rex "\$@"
  fi
}
$MARK_END
EOF
  say "Added the rex resurrect shell function to $RC"
fi

say ""
say "Done. Open a new Rex pane (or run: source ${RC:-your shell rc}), then:"
say "  rex resurrect save      before restarting Rex"
say "  rex resurrect           after it comes back"
