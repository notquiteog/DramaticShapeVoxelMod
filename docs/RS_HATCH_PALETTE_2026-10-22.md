# Ruby/Sapphire selected hatch artwork

The selected-art adapter now converts binary-alpha 64×64 artwork with more than
15 RGB555 colors into a deterministic weighted median-cut palette. Previously
these images silently retained the native ROM front sprite. Frames already
within the native palette limit retain their colors. Palette conversion is cached
per image; it does not repeat on every draw.

The native hatch scene still owns OBJ placement, visibility, affine transforms,
priority, masks, fade, animation sequencing, input, and naming. Temporary sheet
and palette substitutions restore on errors. Shared palette banks, mismatched
forms, unsupported dimensions, partial transparency, and unavailable artwork
retain the native renderer.

This is indexed-art compatibility, not unrestricted RGBA parity. Official
0.3.95's `src/core/game3/gba_ppu.lua` exposes `render`/`draw`, but its RGBA shader
and object compositor have no public per-object replacement callback. Overdrawing
an RGBA image after final composition would violate native masks, depth and fade;
overriding `_renderObjs` would couple the mod to a private renderer. Larger-than-
64×64 FULL artwork and fractional alpha still need an engine-owned insertion seam.

Validation after the combined code batch: 33 mocked adapter checks pass and
53 combinations pass against the actual official 0.3.95 indexed decoder and
palette arithmetic. Tests cover restored OAM/palette, cache, native draw errors,
shared palette fallback, exact native blend arithmetic, deterministic reduction,
palette capacity and transparent footprint preservation. `git diff --check`
passes. These are CPU/headless checks, not a new visual or physical-device review.
