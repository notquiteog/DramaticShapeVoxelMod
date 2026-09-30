#!/usr/bin/env bash
# Import one Gen 1/2 ROM into a DEDICATED data home, then report what landed.
#
# Give every game its own XDG_DATA_HOME. A shared one lets one game's cache be
# served to another, and the per-game count then cannot be trusted.
#
#   usage: tools/qa/import-game.sh <game> [timeout-seconds]
#
# env:
#   QA_ENGINE   gen1recomp root            (required)
#   QA_ROM_DIR  directory holding the ROMs (required)
#   QA_WORK     scratch root for profiles  (default: $PWD/tmp/qa)
#
# The engine is invoked with POKEPORT_IMPORT_ROM / POKEPORT_IMPORT_ONLY, which
# is the non-interactive import path; no launcher interaction is needed.
set -u
v="$1"; limit="${2:-1800}"
engine="${QA_ENGINE:?set QA_ENGINE to the gen1recomp root}"
roms="${QA_ROM_DIR:?set QA_ROM_DIR to the directory holding the ROMs}"
work="${QA_WORK:-$PWD/tmp/qa}"

case "$v" in
  crystal)   rom="$roms/PokemonCrystal(UE)(V1.1).gbc" ;;
  gold)      rom="$roms/Pokemon - Gold Version (USA, Europe) (SGB Enhanced) (GB Compatible).gbc" ;;
  silver)    rom="$roms/Pokemon - Silver Version (USA, Europe) (SGB Enhanced) (GB Compatible).gbc" ;;
  yellow)    rom="$roms/PokemonYellow(UE).gbc" ;;
  firered)   rom="$roms/1636 - Pokemon Fire Red (U)(Squirrels).gba" ;;
  leafgreen) rom="$roms/Pokemon - Leaf Green Version (U) (V1.1).gba" ;;
  *) echo "unknown game: $v" >&2; exit 2 ;;
esac

if [ ! -f "$rom" ]; then
  echo "NO ROM for $v: $rom" >&2
  exit 2
fi

home="$work/profiles/$v"
rm -rf "$home"; mkdir -p "$home"
log="$work/import-$v.log"; mkdir -p "$work"

echo "=== importing $v ==="
echo "    rom:  $rom"
echo "    home: $home"
( cd "$engine" || exit 2
  env XDG_DATA_HOME="$home" POKEPORT_IDENTITY="iso-$v-qa" \
      POKEPORT_IMPORT_ROM="$rom" POKEPORT_IMPORT_ONLY=1 \
      timeout -k 20 "$limit" xvfb-run -a stdbuf -oL -eL \
      love . --developer --no-sync ) > "$log" 2>&1
echo "    exit: $?    log: $log"

maps="$home/love/iso-$v-qa/$v/data/generated/maps.lua"
if [ -f "$maps" ]; then
  echo "    maps: $(stat -c%s "$maps") bytes" \
       "stub=$(grep -c 'stub = true' "$maps")" \
       "entries=$(grep -cE '^  [A-Z][A-Z0-9_]+ = \{' "$maps")"
else
  # A 0-entry stub here means the game has no overworld map extraction. For
  # FireRed/LeafGreen on a stock gen1recomp that is EXPECTED: the FRLG import
  # plan has no map step, and overworld maps come from the Kanto-Reforged
  # companion mod, which src/core/game3/host_stub.lua stands in for when it is
  # absent. Gen 3 is therefore not sweepable without that mod.
  echo "    maps: MISSING or stub -- not sweepable"
fi
