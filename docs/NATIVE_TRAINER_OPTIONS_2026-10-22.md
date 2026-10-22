# Native trainer option ownership

`Gen3TrainerArt.front` called `BattleArt.trainerImage`, whose optional rival
setting fallback imported `src.core.Game` for every trainer. Gen 3 never runs
that Gen 1 singleton. Although caught, the import still entered the engine's
mod error feed and could not read native companion portrait preferences.

Battle Art now captures the real `game.ready` payload and reads its current
session (or Gen 1/2 save). Gen 3 before readiness returns defaults safely;
Gen 1/2 retain their legacy fallback. Only rival classes query the optional
rival preference. Native explicit art choices and absent companion defaults
remain unchanged. The companion remains optional.

The choose-your-hero regression covers early Gen 3 boot, live session ownership
over a serialized save snapshot, session replacement and Gen 2 fallback. Native
Ruby on official0.3.95/LÖVE11.5 Linux/NVIDIA reproduces the old import stack and
passes after the fix without that diagnostic; injected session-only Green/
Yellow choices resolve correctly. Its trainer-double fixture still animates
all four Pokemon slots. Native anchor checks also pass. No all-platform claim.
