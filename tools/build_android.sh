#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${WRONG_MOVE_GODOT:-godot}"
build_kind="${1:-debug}"
if [[ "$build_kind" != debug && "$build_kind" != release ]]; then
    echo 'Usage: tools/build_android.sh [debug|release]' >&2
    exit 2
fi
if [[ "$build_kind" == release ]]; then
    echo 'Release production preset/signing and acceptance gates are not ready. Use debug.' >&2
    exit 2
fi
if [[ ! -f "$project_root/android/build/build.gradle" ]]; then
    echo 'Install Godot Android build template first (Project > Install Android Build Template).' >&2
    exit 2
fi
mkdir -p "$project_root/builds/android"
"$godot_bin" --headless --path "$project_root" --editor --import
"$godot_bin" --headless --path "$project_root" "--export-$build_kind" Android "$project_root/builds/android/wrong-move-$build_kind.apk"
echo "APK: $project_root/builds/android/wrong-move-$build_kind.apk"
