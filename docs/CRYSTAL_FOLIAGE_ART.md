# Original Crystal foliage artwork

Asset: `assets/crystal/foliage-clusters.png` (1254 × 1254 RGBA).
Generated with the built-in image-generation tool on 2026-09-13. This is new
artwork; the user's Gamma Emerald screenshots were visual references only and
are not included in the package. Alpha was verified to span 0–255 and preserved.
The four atlas quadrants supply broadleaf, conifer, spreading broadleaf and shrub
materials. Geometry uses a dense interior crop on lobes and full cutouts on the
outer boughs. Gen 1 retains its existing materials. The original output is copied
unchanged into the project.

Final generation prompt:

> Use case: stylized-concept. Asset type: production foliage texture atlas for an HD-2D pixel-art RPG, inspired by the lush foliage rendering of Gamma Emerald. Create ONE square 1024x1024 PNG with a genuinely transparent alpha background, arranged as precisely four equal 512x512 quadrants, no grid lines. Each quadrant contains ONE compact, dense, irregular cluster of overlapping leaves occupying its central 85 percent with clear transparent margins. Top-left: rounded broadleaf oak bough with medium ovate leaves. Top-right: evergreen conifer bough, layered drooping dense small needle fans. Bottom-left: spreading beech bough with broad fan-shaped foliage, longer horizontal lobes. Bottom-right: small rounded shrub foliage cluster. These are close-up foliage clusters for texture cards, NOT complete trees. NO trunks, ground, pots, scenery, text, labels, borders or drop shadows. Style: carefully authored pixel art with crisp stair-stepped outlines and discrete small color clusters, consistent pixel scale (as if each quadrant were a 128x128 sprite enlarged nearest-neighbor to 512x512), limited rich natural green palette, shadow pockets deep forest green, middle emerald and olive green, sun-facing leaves warm yellow-green highlights. The leaf group as a whole should form a dense believable overlapping organic mass, no isolated floating leaves, no long grass blades, no transparent internal holes large enough to break the mass, no flat polygon mesh outlines, no smooth gradients, no antialias blur. Soft directional shading painted into clusters from upper-left, readable leaf group silhouettes, game-ready original artwork.

The tool returned 1254 px instead of the requested 1024 px. Normalized UVs
preserve the intended quadrant mapping; the original image was not resampled.
