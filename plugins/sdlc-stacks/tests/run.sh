#!/usr/bin/env bash
# Runs the sdlc-stacks hook against throwaway projects.
#   bash plugins/sdlc-stacks/tests/run.sh
# Prints one line when all pass; otherwise each failure, and exits 1.
set -u
PLUGIN="$(cd "$(dirname "$0")/.." && pwd)"
pass=0 fails=""
check() { # check <name> <condition command...>
  local name=$1; shift
  if "$@" >/dev/null 2>&1; then pass=$((pass + 1)); else fails="$fails
  FAIL: $name"; fi
}
has() { printf '%s' "$1" | grep -qF -- "$2"; }
empty() { [ -z "$1" ]; }
lacks() { ! has "$1" "$2"; }

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
export CLAUDE_PLUGIN_DATA="$T/data"
P="$T/project" && mkdir -p "$P/src" && git -C "$P" init -q
# hook <session> <tool> <path relative to the project, or absolute>
hook() {
  local f=$3
  case $f in /*) ;; *) f="$P/$f" ;; esac
  printf '{"session_id":"%s","tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2" "$f" |
    CLAUDE_PROJECT_DIR=$P bash "$PLUGIN/scripts/stack-rules.sh"
}
context() { printf '%s' "$1" | jq -r '.hookSpecificOutput.additionalContext // empty'; }

# The real rules: Python has no markers, so its rules apply to any matching file.
out=$(hook s1 Read src/app.py)
check "a read of a .py file gets the Python rules" has "$(context "$out")" "R-PY-003"
check "the rules name the file" has "$(context "$out")" "Stack rules for src/app.py"
check "a read is not denied" lacks "$out" '"deny"'
check "rules for other files stay out" lacks "$out" "R-PY-006"
out=$(hook s1 Read src/other.py)
check "a rule is shown once per session" empty "$out"
out=$(hook s1 Edit tests/test_app.py)
check "a first edit of a test file is denied once" has "$out" '"permissionDecision": "deny"'
check "the denial carries the new rule" has "$out" "R-PY-006"
check "the denial leaves out rules already shown" lacks "$out" "R-PY-003"
out=$(hook s1 Edit tests/test_app.py)
check "the same edit then passes" empty "$out"
out=$(hook s2 Write src/app.py)
check "a new session shows the rules again" has "$out" "R-PY-001"
out=$(hook s3 Read README.md)
check "a file no rule covers gets nothing" empty "$out"
out=$(hook s3 Read /etc/hosts)
check "a file outside the project gets nothing" empty "$out"
out=$(hook s3 Read pyproject.toml)
check "a pattern without * matches the file at the root" has "$(context "$out")" "R-PY-002"

# The real web stacks. new_project <name> [git]: a fresh project in $P, a git repo unless told otherwise.
new_project() { P="$T/$1" && mkdir -p "$P" && { [ "${2:-git}" = git ] && git -C "$P" init -q || true; }; }
new_project next-app
printf '{}\n' >"$P/tsconfig.json"
printf '{ "dependencies": { "next": "16.4.0", "react": "19.2.0" } }\n' >"$P/package.json"
out=$(context "$(hook w1 Read app/page.tsx)")
check "a Next.js page gets the TypeScript rules" has "$out" "R-TS-002"
check "a Next.js page gets the React rules" has "$out" "R-REACT-002"
check "a Next.js page gets the Next.js rules" has "$out" "R-NEXT-001"
check "a Next.js page gets no Python rules" lacks "$out" "R-PY-"
out=$(context "$(hook w1b Read .env.local)")
check "an env file gets the secrets rule" has "$out" "R-NEXT-002"
out=$(context "$(hook w1c Read src/hooks/useCart.ts)")
check "a custom hook file gets the hook rules" has "$out" "R-REACT-001"

new_project vite-app
printf '{}\n' >"$P/tsconfig.json"
printf '{ "dependencies": { "react": "19.2.0", "react-dom": "19.2.0" } }\n' >"$P/package.json"
out=$(context "$(hook w2 Read src/App.tsx)")
check "a React app without Next.js gets the React rules" has "$out" "R-REACT-003"
check "a React app without Next.js gets no Next.js rules" lacks "$out" "R-NEXT-"
printf '{ "dependencies": { "react-dom": "19.2.0" } }\n' >"$P/package.json"
out=$(context "$(hook w3 Read src/App.tsx)")
check "react-dom alone does not count as react" lacks "$out" "R-REACT-"

new_project no-tsconfig
out=$(hook w4 Read src/index.ts)
check "a .ts file without a tsconfig.json gets nothing" empty "$out"

new_project mixed
mkdir -p "$P/web" "$P/api" && printf 'export default {}\n' >"$P/web/next.config.mjs"
out=$(context "$(hook w5 Read api/main.py)")
check "a mixed project gives Python rules to Python files" has "$out" "R-PY-003"
check "Python files get no web rules" lacks "$out" "R-NEXT-"
out=$(context "$(hook w5 Read web/app/layout.tsx)")
check "a mixed project gives Next.js rules to its app folder" has "$out" "R-NEXT-001"

new_project not-git nogit
mkdir -p "$P/node_modules/lib" && printf '{}\n' >"$P/node_modules/lib/tsconfig.json"
out=$(hook w6 Read src/index.ts)
check "outside git, a tsconfig.json in node_modules does not count" empty "$out"
printf '{}\n' >"$P/tsconfig.json"
out=$(context "$(hook w7 Read src/index.ts)")
check "outside git, markers are still found" has "$out" "R-TS-001"

new_project expo-app
printf '{}\n' >"$P/tsconfig.json"
printf '{ "dependencies": { "expo": "~55.0.0", "react": "19.2.0", "react-native": "0.83.0" } }\n' >"$P/package.json"
out=$(context "$(hook e1 Read app/index.tsx)")
check "an Expo screen gets the TypeScript layer" has "$out" "R-TS-002"
check "an Expo screen gets the React layer" has "$out" "R-REACT-002"
check "an Expo screen gets the React Native layer" has "$out" "R-RN-002"
check "an Expo screen gets the Expo layer" has "$out" "R-EXPO-003"
check "an Expo app/ folder gets no Next.js rules" lacks "$out" "R-NEXT-"
out=$(hook e2 Edit ios/App/AppDelegate.swift)
check "a first edit in ios/ is denied with the prebuild rule" has "$out" "R-EXPO-002"

new_project bare-rn
printf '{ "dependencies": { "react": "19.2.0", "react-native": "0.83.0" } }\n' >"$P/package.json"
out=$(context "$(hook e3 Read src/List.jsx)")
check "a bare React Native app gets the React Native layer" has "$out" "R-RN-001"
check "a bare React Native app gets no Expo rules" lacks "$out" "R-EXPO-"

# Native mobile, desktop, IoT, games and .NET. files <path>...: empty files in the current project.
files() { local f; for f in "$@"; do mkdir -p "$(dirname "$P/$f")" && : >"$P/$f"; done; }
n=0
# expect <file to read> <rule it must get> [rule it must not get]: each read in a new session.
expect() {
  n=$((n + 1))
  local got; got=$(context "$(hook "x$n" Read "$1")")
  check "$(basename "$P"): $1 gets $2" has "$got" "$2"
  [ -z "${3:-}" ] || check "$(basename "$P"): $1 does not get $3" lacks "$got" "$3"
}
new_project swift-package; files Package.swift
expect Sources/App/Model.swift R-SWIFT-002
new_project ios-app; files App.xcodeproj/project.pbxproj
expect App/ContentView.swift R-SWIFT-001
expect App/Info.plist R-SWIFT-003
new_project android-app; files app/src/main/AndroidManifest.xml build.gradle.kts settings.gradle.kts
expect app/src/main/java/NewsRepository.kt R-ANDROID-001
expect app/build.gradle.kts R-GRADLE-001
new_project jvm-lib; files build.gradle
expect build.gradle R-GRADLE-002
out=$(hook x-jvm Read src/main/kotlin/Lib.kt)
check "jvm-lib: Kotlin source outside Android gets no Android rules" empty "$out"
new_project electron-app; printf '{ "devDependencies": { "electron": "38.0.0" } }\n' >"$P/package.json"
expect src/main.ts R-ELECTRON-003 R-TS-
new_project tauri-app; files src-tauri/tauri.conf.json src-tauri/Cargo.toml
expect src-tauri/src/lib.rs R-TAURI-002
expect src-tauri/src/main.rs R-RUST-001
expect src-tauri/capabilities/default.json R-TAURI-001
new_project rust-cli; files Cargo.toml
expect src/main.rs R-RUST-002 R-TAURI-
new_project arduino-sketch; files blink/blink.ino
expect blink/blink.ino R-ARDUINO-001 R-PIO-
new_project pio-firmware; files platformio.ini
expect src/main.cpp R-PIO-001
expect include/secrets.h R-ARDUINO-002
new_project godot-game; files project.godot
expect scenes/player.gd R-GODOT-002
new_project unity-game; files ProjectSettings/ProjectVersion.txt
expect Assets/Scripts/Player.cs R-UNITY-003 R-DOTNET-
expect Assets/Art/hero.png R-UNITY-001
new_project dotnet-app; files App.csproj
expect Program.cs R-DOTNET-001 R-UNITY-

# Markers, with a rules file made for the test.
export SDLC_STACKS_RULES="$T/rules.json"
cat >"$SDLC_STACKS_RULES" <<'JSON'
{ "stacks": [
    { "id": "next", "title": "Next.js", "markers": [{ "file": "*package.json", "contains": "\"next\"" }] },
    { "id": "godot", "title": "Godot", "markers": [{ "file": "*project.godot" }] } ],
  "rules": [
    { "id": "R-NEXT-001", "stack": "next", "status": "proposed", "paths": ["*.tsx"], "text": "Next rule." },
    { "id": "R-GD-001", "stack": "godot", "status": "proposed", "paths": ["*.gd"], "text": "Godot rule." } ] }
JSON
out=$(hook m1 Read src/page.tsx)
check "a stack without its markers stays off" empty "$out"
printf '{ "dependencies": { "react": "19" } }\n' >"$P/package.json"
out=$(hook m2 Read src/page.tsx)
check "a marker file without its text leaves the stack off" empty "$out"
mkdir -p "$P/web" && printf '{ "dependencies": { "next": "16" } }\n' >"$P/web/package.json"
out=$(hook m3 Read web/app/page.tsx)
check "a marker in a subfolder turns the stack on" has "$(context "$out")" "R-NEXT-001"
check "other stacks stay off" lacks "$out" "R-GD-001"
mkdir -p "$P/game" && touch "$P/game/project.godot"
out=$(hook m3 Read game/player.gd)
check "stacks are worked out once per session" empty "$out"
out=$(hook m4 Read game/player.gd)
check "a marker without text turns its stack on" has "$(context "$out")" "R-GD-001"
out=$(hook m4 Read src/app.py)
check "a stack missing from the rules file adds nothing" empty "$out"

if [ -n "$fails" ]; then
  echo "sdlc-stacks tests: $pass passed, $(printf '%s' "$fails" | grep -c FAIL) failed:$fails"
  exit 1
fi
echo "sdlc-stacks tests: $pass passed"
