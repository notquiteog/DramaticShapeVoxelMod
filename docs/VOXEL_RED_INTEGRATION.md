# Voxel Red integration work

Requested 2026-09-22. Target actual Gen1Recomp 0.2.73 FireRed. Five separately
installable mods: Battle Art, Wilds of Kanto, Gen1Online+, Dramatic Sky Ride,
Double Battles. Public cart/repository name: Voxel Red. No required dependencies
between these mods; all cross-mod behavior must use optional public exports.

Acceptance work, not yet certified:
- Standalone and combined FireRed boot for all five packages.
- Visible wild encounters preserve the exact selected Pokemon and remain singles
  unless their owning mod explicitly requests a different format.
- Respect native story/trainer/postgame doubles; use the native Gen3 simulator,
  partner selection, targeting, switch/KO logic and link protocol.
- Nearby online players can mutually accept trades/single battles; offer doubles
  only with mutually supported capability and eligible parties. Preserve native
  Pokemon data and trade confirmation/writeback; validate two real endpoints.
- Mounts work in native 2D without Battle Art or spawn mods; optional renderer
  providers share poses without duplicated riders.
- Render distance Auto/Low/Medium/Far/Full in Crystal and FireRed. Connected
  maps win over generated fill. Coast/water, mountains/rock and forest/native
  tree continuation derived per boundary, stable when the camera rotates.
- Public releases/pinned cart only after compatibility and runtime checks.

Engine evidence: core/game3/link has trade, battle and union-room services;
Gen3 battle_bridge preserves native double trainers and native link flags.
FireRed Map.worldMidAt resolves connected maps and flags border fallback as
its third return value. The fixed scene range and repeated border art have been replaced in the
working tree by shared distance and contextual perimeter presentation. See
[scenery implementation and QA](RENDER_DISTANCE.md). Companion FireRed ports
and the public five-mod cart remain pending; no release claims for those.
