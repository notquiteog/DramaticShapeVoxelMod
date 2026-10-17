# Connected scene reuse and classification — 2026-10-17

Official Gen1Recomp0.3.89 (latest checked this date), NVIDIA RTX5060Ti,
driver615.71.09, native2560x1440, AUTO distance and high shadows. Isolated
QA profiles only; native running across real connections and six reversals.
Baseline is published1.44.0 /1050a22. No visuals, collision or gameplay changed.

## Implementation

A successfully promoted destination puts the previous complete scene in the
vacated prefetch slot. No additional scene slot or unbounded world cache is
introduced. Native outside-cell interpolation preserves only that completed
scene for at most the single-cell edge zone. Current map/content/provider keys
and existing nearby-window checks still govern reuse; edits, far windows,
changed providers, new predictions and explicit invalidation release it.

Build-local classification memoizes the exact primary/secondary/metatile/
behavior/collision tuple. Cells receive separate recursive copies, so geometry
preparation cannot modify another cell or native recipe. The cache expires
with each build and cannot cross editions or provider/recipe changes.

## Verification

318 regression suites passed,0 failed,58 external-fixture skips. Focused tests
exercise repeated return swaps, bounded lifetime, provider/gameplay rejection,
cleanup and all four outside-edge cases;30,720 native shape combinations across
FR/LG/R/S/E match uncached output, including nested mutable-copy isolation.

All five native running fixtures crossed successfully and performed six
reversals with the voxel camera retained, no prefetch failure, exact comparison
to the engine's connected-map sampler and native GC policy restored on OFF.
Emerald recorded70 retained-frame hits,7 promotions and5 newly prepared scenes
instead of7. FR/LG recorded78 retained hits; Ruby/Sapphire70. Cache hits count
frames, not distinct scenes. Some crossings still need fresh window work.

Emerald's baseline six return maxima were16.06,12.72,13.43,12.54,13.61,11.95ms.
Candidate maxima were12.58,17.69,5.34,13.81,4.94,12.50ms. FR return maxima ranged
4.62–23.62ms; LG6.00–64.28ms; Ruby6.86–18.12ms; Sapphire5.82–21.14ms.
These are bounded runs under desktop scheduling, not a whole-game FPS promise.

The final profiled cold pair reduced native classifier calls from8749 to5485
on Route104 and6696 to3630 in Petalburg. Classifier time fell28.27→18.24ms and
25.22→14.00ms. Whole cold builds were736.96→691.69ms and185.78→207.88ms: total
loading remains variable and is not uniformly faster in these samples. An
initial sample was609.13→646.98ms and155.30→147.49ms. Do not report only the
favorable total-time samples.

Final Emerald high-shadow battle:180 frames,mean3.11ms,p955.51ms,max8.14ms;
Baseline battle under the same current desktop conditions:mean3.54ms,
p955.54ms,max8.29ms. Neither sample rebuilds scenes during the stationary phase. Scene reuse does
not run during battles. Gen1/2 share tested stream update behavior; this batch
does not claim a new native performance sweep for those six games.

## Remaining

Steady165FPS requires6.06ms. Unprepared loads, first approaches, some reverse
crossings and occasional battle frames still exceed it. More allocation/upload
and engine-transition profiling is needed. No arbitrary regions or long-session
memory guarantees. Scratch drivers/logs/captures live outside the repo in
`.scratch/scene-reuse-20261017/`; benchmark instrumentation is not shipped.
