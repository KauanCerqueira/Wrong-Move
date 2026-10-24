#!/usr/bin/env bash
set -u
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${WRONG_MOVE_GODOT:-godot}"
test_log="$(mktemp -t wrong-move-tests.XXXXXX)"
trap 'rm -f -- "$test_log"' EXIT
"$godot_bin" --headless --path "$project_root" --script tests/run_tests.gd -- "$@" >"$test_log" 2>&1
test_status=$?
sed -n '1,160p' "$test_log"
# Godot can log script runtime errors yet leave the process exit code at zero.
if rg -q 'SCRIPT ERROR:|Parse Error:|Failed to load script|^ERROR:' "$test_log"; then
    exit 1
fi
exit "$test_status"
