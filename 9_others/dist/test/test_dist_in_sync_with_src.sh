#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════════╗
# ║                                                                  ║
# ║   GENERATED FILE — DO NOT EDIT                                   ║
# ║                                                                  ║
# ║   Source : 9_others/test/test_dist_in_sync_with_src.sh
# ║   Engine : 1_cicd/src/scripts/unix-ship-repo-workflow-engine.sh
# ║   Rebuild: ./9_others/build.sh
# ║                                                                  ║
# ║   Manual edits will be overwritten on next build.                ║
# ║                                                                  ║
# ╚══════════════════════════════════════════════════════════════════╝

# Test: workflow parity src/cicd -> 1_cicd/dist -> .github/workflows.
# Every workflow source has an identical dist and deployed copy (banner aside),
# and .github/workflows holds no workflow without a source (deploy deletes those).
set -eu
R="$(_d="$(cd "$(dirname "$0")" && pwd)"; while [ "$_d" != "/" ] && [ ! -e "$_d/.git" ]; do _d="$(dirname "$_d")"; done; printf '%s' "$_d")"
S="$R/1_cicd/src/cicd"; D="$R/1_cicd/dist"; G="$R/.github/workflows"
strip() { awk 'NR==1&&/^# ╔/{b=1} b&&/^# ╚/{b=2;next} b==2&&/^$/{b=0;next} !b{print}' "$1"; }
fail=0
n=0
for f in "$S"/*.yml "$S"/*.yaml; do
  [ -f "$f" ] || continue; n=$((n+1)); b=$(basename "$f")
  for t in "$D" "$G"; do
    if [ ! -f "$t/$b" ]; then echo "FAIL: $b missing in $t (run 9_others/build.sh)"; fail=1
    elif ! [ "$(strip "$f")" = "$(strip "$t/$b")" ]; then echo "FAIL: $b differs in $t (run 9_others/build.sh)"; fail=1; fi
  done
done
[ "$n" -gt 0 ] || { echo "FAIL: no workflow sources in $S"; exit 1; }
for f in "$G"/*.yml "$G"/*.yaml; do
  [ -f "$f" ] || continue
  [ -f "$S/$(basename "$f")" ] || { echo "FAIL: orphan $(basename "$f") has no source in 1_cicd/src/cicd"; fail=1; }
done
[ "$fail" = 0 ] && echo "PASS: $n workflow(s) in sync"
exit "$fail"
