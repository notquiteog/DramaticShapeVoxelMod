# Half-submerged Hoenn rock geometry — 2026-10-17

Complete native sea boulders (`150/151/158/159`) and sea stacks
(`175/176/17D/17E`) now straddle the surrounding water plane. The original closed
hull is retained, with half its actual vertical extent below water. No source
faces, UVs, collision, interaction or walking permissions are removed.

The geometric midpoint is cached once with each source template. A local
`shape.waterline` positions each copy relative to its native terrain base;
`Gen3Water.bind` supplies the adjacent water body's actual world height. GPU
instances use a centered model and separate per-instance height. Ordinary
emission and failed-instancing fallback produce identical world coordinates,
including different native base heights and different local water levels.

Small native water boulders (`C5/18C/194`) receive the same treatment only when
the reviewed classifier sets `wetRock`. Land boulders retain their geometry and
position. The optional original-art rock card remains a flat card. All actors,
Pokémon and flowers remain HD-2D; no companion is required.

## Verification

Focused sea-rock and wet-rock tests cover both complete families, guarded
source ownership, native blocked footprints, retained UVs/topology, half
immersion, differing water/terrain levels, instance parity and GPU fallback.
Cave-profile and outdoor regressions also pass.

Matched source verification uses the frozen 1.49.0 release and the changed
source on official Gen1Recomp 0.3.89. All six matching scene runs exit 0 and log
NVIDIA RTX 5060 Ti / driver 615.71.09. Explicit NVIDIA GLX dispatch is required;
earlier software-rendered baseline captures are excluded from this comparison.
Four orbit views and an eye-level view cover a brown stack, a gray boulder and
a small Mossdeep boulder per Hoenn edition: 45 before and 45 after captures,
all inspected. The changed water sheet removes the rectangular native-art
patches around the submerged models.

`tools/qa/gen3-sea-rock-coverage.lua` observes public mod producers and actual
water mesh uploads. Across twelve changed-source scene builds it verifies
2,808 wet-cell water planes, 696 complete hulls and 24 small hulls. Counts
include repeated streamed builds, not unique placements. Every wet source cell
has a matching uploaded water quad; each actual carved hull straddles that
same world plane and remains inside its source footprint. Independent audit
templates preserve production caches.

`tools/qa/gen3-sea-rock-walks.lua` repeats native dry shore movement and the
no-surf boundary in Emerald, Ruby and Sapphire. Before and after both pass
three walks and three blocked approaches, with unchanged native cell digests;
twelve OFF/actual-first-person captures are inspected. All six input runs exit
0. This proves native movement and boundary preservation, not surfing, a manual
keyboard session, multiplayer, or every water map. No performance claim is
inferred from these visual checks; separate benchmark evidence owns timing.

Final release evidence records its own packaged rerun separately from these
source comparisons.
