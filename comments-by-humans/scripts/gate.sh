#!/bin/sh
# Run gate.py with the first working Python 3: $CBH_PYTHON, then py -3, python3, python.
# Each candidate is run once to confirm it is Python 3, which skips the Microsoft Store
# aliases that Windows installs as python and python3 without a real interpreter behind them.
#
# With no working Python, a hook fails closed (exit 2) only in a project that has a gate, so a
# missing interpreter never blocks projects that do not use the plugin.

gate="$(dirname "$0")/gate.py"

is_python3() {
  "$@" -S -c 'import sys; sys.exit(sys.version_info[0] != 3)' </dev/null >/dev/null 2>&1
}

if [ -n "${CBH_PYTHON:-}" ] && is_python3 "$CBH_PYTHON"; then
  exec "$CBH_PYTHON" "$gate" "$@"
fi
if command -v py >/dev/null 2>&1 && is_python3 py -3; then
  exec py -3 "$gate" "$@"
fi
for python in python3 python; do
  if command -v "$python" >/dev/null 2>&1 && is_python3 "$python"; then
    exec "$python" "$gate" "$@"
  fi
done

msg="comments-by-humans: no working Python 3 found (tried \$CBH_PYTHON, py -3, python3, python). Install Python 3, or set CBH_PYTHON to its path."
if [ "${1:-}" != hook ]; then
  echo "$msg" >&2
  exit 1
fi
dir="${CLAUDE_PROJECT_DIR:-$PWD}"
while :; do
  if [ -f "$dir/.comments-by-humans/state.json" ]; then
    echo "$msg The gate in $dir fails closed until then; deleting $dir/.comments-by-humans/ removes it." >&2
    exit 2
  fi
  parent="$(dirname "$dir")"
  [ "$parent" = "$dir" ] && break
  dir="$parent"
done
exit 0
