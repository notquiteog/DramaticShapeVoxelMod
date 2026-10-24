# Inactive Slateport Shipyard prototype snapshot — 2026-10-23

This preserves curated original-source output and importer work while the user consolidates all worker changes. It is **inactive and not accepted for gameplay**: no production dispatcher/Scene references the new modules, and Gen3ImportedSlateportShipyard.enabled defaults to false. Existing native Shipyard presentation is unchanged. Deliberate scratch opt-in plus dispatcher work would be required for future verification.

Preserved files are the normalized Shipyard body/door Lua data, five diffuse PNGs with provenance hashes, standalone building/door prototypes, the source importer, and two draft QA drivers. No ROM, raw BCH/GARC/model archive, generated cache or capture is included. The data came from the supplied original Alpha Sapphire GR152/ZO14→267/AD20/BM39 source; provenance.json records texture/model/animation hashes and geometric processing.

Outstanding: native fit, footprint, source scale, clearance, actual native open passage, door ownership, source transparency, contacts/closed backs and underside geometry need final review. Draft source/entry drivers assume a temporary Shipyard dispatcher and contain preliminary assertions; they are preserved research tools, not passing acceptance evidence. The prototype has no accepted runtime source count. Activation is explicitly held.

Snapshot checks: all five PNG bytes match their recorded PNG SHA256, generated Lua and prototype/driver Lua compile under LuaJIT, Python importer parses, and a direct adapter fixture proves default eligibility is false. This is static preservation evidence only.

The broader uncommitted source research/captures remain under `/home/admin/Projects/.scratch/hoenn-world-096-20261023/`, including the separate Sootopolis source viewer and rejected conditional-cave draft. They are outside the repository and are not release assets.
