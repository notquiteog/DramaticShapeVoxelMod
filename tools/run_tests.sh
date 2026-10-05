#!/usr/bin/env bash
# Run the mod's Lua test suite and write a summary.
#
#   usage: tools/run_tests.sh [engine-root]
#
# CWD must be the MOD root: many suites dofile("lib/X.lua") or
# require("lib.X") with paths relative to the mod, so running them from the
# engine root fails on the file layout, not on the code. An engine root, if
# given, goes on LUA_PATH and unlocks the ~31 suites that need src/ (the ones
# using tests.harness, tests.modkit, or ASTRA_ENGINE).
#
# Suites that need a generated dataset this repository does not carry
# (ASTRA_GENERATED / ASTRA_FULL_BASELINE) are reported as SKIP, not FAIL:
# they are A/B harnesses, and an absent fixture is not a broken build.
#
# This exists because nothing ran the suite automatically. A `map.width` read
# added in 1.28.5 broke the Gen 2 classifier suite, and it stayed red through
# several releases; a grass shape change in 1.27.1 and a ladder pin split in
# 1.24.0 each left their own suite failing for the same reason.
set -u
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 2
engine="${1:-}"
[ -n "$engine" ] && export LUA_PATH="$engine/?.lua;$engine/?/init.lua;;"
[ -n "$engine" ] && export ASTRA_ENGINE="$engine"
export DS_MOD_PATH=.
export ASTRA_CANDIDATE="${ASTRA_CANDIDATE:-$root}"
pass=0; fail=0; skip=0
for t in tests/*_test.lua; do
  name=$(basename "$t")
  log=$(mktemp)
  timeout 300 luajit "$t" > "$log" 2>&1
  rc=$?
  needs_dataset=no
  needs_engine=no
  # These use the ENGINE's tests.modkit, which lives in the engine checkout and
  # is not part of this repository. Without an engine root they cannot run at
  # all, which is a missing harness rather than a broken suite.
  if grep -q "module 'tests.modkit' not found" "$log" \
     || grep -q "module 'tests.harness' not found" "$log"; then
    needs_engine=yes
  fi
  missing=""
  if [ $rc -ne 0 ] && ! grep -qE '^FAIL' "$log"; then
    missing=$(python3 tools/test_prerequisites.py "$log")
    [ -n "$missing" ] && needs_dataset=yes
  fi
  if [ $rc -eq 0 ] && ! grep -qE '^FAIL' "$log"; then
    printf 'PASS  %-52s %s\n' "$name" "$(grep -oE '[0-9]+/[0-9]+ checks passed' "$log" | tail -1)"
    pass=$((pass + 1))
  elif [ "$needs_dataset" = yes ]; then
    printf 'SKIP  %-52s (%s)\n' "$name" "$missing"
    skip=$((skip + 1))
  elif [ "$needs_engine" = yes ] && [ -z "$engine" ]; then
    printf 'SKIP  %-52s (needs the engine test harness)\n' "$name"
    skip=$((skip + 1))
  elif [ $rc -ne 0 ] && [ -z "$engine" ] \
       && grep -qE "module 'src\.|no file '.*/src/|src\.core|src\.world" "$log"; then
    printf 'SKIP  %-52s (needs an engine root)\n' "$name"
    skip=$((skip + 1))
  else
    printf 'FAIL  %-52s rc=%s\n' "$name" "$rc"
    grep -E '^FAIL' "$log" | head -3 | sed 's/^/        /'
    fail=$((fail + 1))
  fi
  if [ -n "${TEST_LOG_DIR:-}" ]; then mkdir -p "$TEST_LOG_DIR"; cp "$log" "$TEST_LOG_DIR/$name.log"; fi
  rm -f "$log"
done
# Missing external resources are explicit skips; every executable failure is fatal.
echo "== $pass passed, $fail failed, $skip skipped =="
if [ "$fail" -ne 0 ]; then
  echo "::error::$fail suites failed"
  exit 1
fi
exit 0
