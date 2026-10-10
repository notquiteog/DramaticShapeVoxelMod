# Optional custom-region scenery integration

Battle Art is never a required dependency. A region remains playable through
its native map, tile, collision and script systems without this provider.

Gen3 exposes `exports.gen3.scenery` (`apiVersion = 1`). Region authors reusing
an **identical metatile layout** may explicitly alias their imported tileset
pair to an existing Battle Art layout. This is not an asset importer and does
not make different artwork compatible by renaming it. Unknown artwork retains
its native presentation; custom quest logic remains the region's responsibility.

```lua
local provider = game.mods and game.mods.exports
  and game.mods.exports.BATTLE_ART_VOXEL_FORK
local scenery = provider and provider.gen3 and provider.gen3.scenery
local dispose
if scenery and scenery.apiVersion == 1 then
  local err
  dispose, err = scenery.registerTilesetAlias(
    "my_region__shop", "building__shop")
  -- A nil result means registration was rejected; retain native behavior.
end
-- On region/provider teardown:
if dispose then dispose(); dispose = nil end
```

Register after the game/mod providers are available. Keep the returned disposer
and invoke it when unloading the region. A successful registration and its first
disposal invalidate Battle Art's scene cache. Repeated disposal is harmless.
Duplicate ownership, self aliases and cycles are rejected. Native representative
aliases take precedence; registration never replaces an already owned pair.
Do not register a native pair belonging to another game/mod. Explicit aliases
survive map rebinding until disposed. Registration affects model selection only;
it does not modify source textures, map collision, actors, warps or quest state.

Gen1/2 companion geometry uses the existing optional
[voxel companion API](VOXEL_COMPANION_API_V1_HOST.md). This Gen3 alias API is a
narrow additional capability, not a claim of equivalent extension coverage.

UI ownership: native controls/dialogue remain with the engine; regional UI
should use its generation's native widgets. Optional Modern UI owns restyling.
Never make a region, gameplay mod or Battle Art require Modern UI to function.
