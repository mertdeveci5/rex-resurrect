#!/bin/sh
# Remove rex resurrect. Your saves in ~/.local/state/rex-resurrect are kept
# unless you pass --purge.
set -eu

rm -f "$HOME/.local/bin/rex-resurrect" "$HOME/.pi/agent/extensions/rex-resurrect.ts"
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  [ -f "$rc" ] || continue
  if grep -q '# >>> rex resurrect >>>' "$rc"; then
    sed -i '' '/^# >>> rex resurrect >>>$/,/^# <<< rex resurrect <<<$/d' "$rc"
    echo "Removed the shell function from $rc"
  fi
done
if [ "${1:-}" = "--purge" ]; then
  rm -rf "$HOME/.local/state/rex-resurrect"
  echo "Removed saved state."
fi
echo "rex resurrect is uninstalled. Open a new shell to drop the rex function."
