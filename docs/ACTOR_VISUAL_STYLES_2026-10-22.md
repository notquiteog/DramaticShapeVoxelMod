# Actor style provider gates

`VisualStyles` now controls the optional actor paths owned by Battle Art:

- `StadiumModels.active()` requires Pokemon style `modern` plus both existing
  provider toggles. HD2D/voxel do not allocate instances. Draw, shadow and
  ownership checks also reject stale placements after a category switch.
- `XDModels.active()` checks Pokemon style before its existing ON option and
  optional pack validation. HD2D never reads the local model manifest.
- `Gen3XDActors` checks the same preference for preparation, contexts and draws;
  disabling the style releases held instances and retains native cards.
  Construction exceptions are isolated like missing species/variant data.
- `CharacterRenderers` filters every callback entry point, including capability
  queries, reflections, shadows, ghost suppression and `afterActors`. Trainer
  generation declarations still apply. A stale battle hand cannot survive a
  switch away from a compatible trainer provider. Style changes advance the
  bridge revision used by derived shadow caches.

Existing providers without a declaration are treated as **modern only**. A
provider may opt into its actual supported styles using either shape:

```lua
supportedStyles = { 'modern', 'voxel' }
-- or category-specific capabilities:
supportedStyles = { characters = { 'hd2d' }, pokemon = { 'voxel' } }
```

Style sets such as `{modern=true}` are also accepted. Omitted categories in the
second form support no styles. Registration rejects unknown style names. This
is a capability contract, not proof that a provider has a model for an actor;
callbacks still return exactly `true` only after drawing a supported actor.
Errors/false results leave the existing source sprite/UI path available.

`CharacterRenderers.category(context, method)` distinguishes trainer/player
characters from explicit `visualCategory`/`category`, Pokemon roles/markers,
engine Pikachu followers, original generic creature icons, and named Pokemon
sprite IDs resolved against the native `state.data.pokemon` or
`state.game.data.pokemon` table. Hosts/providers with custom identities should
supply `visualCategory='pokemon'` or `'characters'`. No companion files or private
state are read. The ordinary item-Pokeball dispatch runs before actor filtering
and keeps its existing prop settings and live pickup ownership.

## Native voxel boundary

This change does **not** claim a built-in voxel actor implementation:

- GB world cards are built by `SpriteBillboards.mesh`; they remain planar.
  Its `shadowQuad` is also used by the inverted-depth occlusion silhouette,
  where substituting a closed solid would create self-occlusion artifacts.
- GBA world cards are created inside `Gen3Scene.actor`; adding actual pixel
  extrusion needs a hook there, owned by the scene integration task.
- Battle cards are captured by `Gen3BattleActors`/`BattleBillboard` and the GB
  `BattleScene` card path. Their native animation, masks, palette/flash effects,
  release particles and UI remain authoritative.

Selecting voxel prevents modern models and admits a provider only when it
explicitly declares voxel support. With no such provider, the existing sprite
card remains as fallback. The shared animation-safe pixel extrusion helper and
its world/battle integration are deferred to the next batch. No RGB-merged
static hull or modern model is labeled as native voxel.

## Verification

Headless LuaJIT tests cover actual ModSetting/VisualStyles defaults, independent
character/Pokemon choices, provider declarations, provider OFF/missing/invalid
packs, construction/draw failure, stale model/shadow/hand rejection, native
trainer generation handoff, and retained item prop ownership. Existing model
lifecycle tests explicitly select modern before exercising model behavior.

No GPU/native gameplay run was performed for these policy gates. Parent native
QA remains responsible for combined rendering changes. No `main.lua`,
`Gen3Scene.lua`, source sprite/UI art or gameplay fields changed.
