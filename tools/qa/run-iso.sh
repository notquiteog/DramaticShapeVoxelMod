#!/usr/bin/env bash
# Sweep every map in one game, both camera modes, using an isolated profile.
#
#   usage: tools/qa/run-iso.sh <game> [timeout-seconds]
#
# env:
#   QA_ENGINE  gen1recomp root (required)
#   QA_WORK    scratch root holding profiles/ and results/ (default: $PWD/tmp/qa)
#   QA_LOVE    love binary (default: love)
set -u
v="$1"; limit="${2:-2400}"
engine="${QA_ENGINE:?set QA_ENGINE to the gen1recomp root}"
work="${QA_WORK:-$PWD/tmp/qa}"
love_bin="${QA_LOVE:-love}"
home="$work/profiles/$v"

if [ ! -d "$home" ]; then
  echo "no isolated profile at $home -- run tools/qa/import-game.sh $v first" >&2
  exit 2
fi
mkdir -p "$work/results/$v-sweep"
cd "$engine" || exit 2

exec env XDG_DATA_HOME="$home" POKEPORT_IDENTITY="iso-$v-qa" \
  POKEPORT_VERSION="$v" POKEPORT_DEV=1 POKEPORT_SPEED=1 \
  POKEPORT_DRIVER="$work/sweep.lua" SHOT_DIR="$work/results/$v-sweep" \
  SDL_AUDIODRIVER=dummy ALSOFT_DRIVERS=null \
  timeout -k 20 "$limit" xvfb-run -a stdbuf -oL -eL \
  "$love_bin" . --game="$v" --developer --no-sync \
  > "$work/results/$v-sweep/run.log" 2>&1
