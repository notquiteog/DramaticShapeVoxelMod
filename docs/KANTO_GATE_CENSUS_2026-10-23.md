# Route2 gate census correction and source assessment

The read-only exterior ledger now uses the same standalone recipe order as
production Gen3Scene: Gen3RouteGates.recipes followed by gen3_exteriors. Previous
identifier inventories omitted those gate recipes, while the renderer already
modeled their native art. This correction changes no production geometry.

Fresh native official0.3.96 ledgers pass0 in both editions,426 maps each. Three
additional complete native assemblies appear on FR_ROUTE_2: forest_south(2,45),
8×7; forest_north(2,13),8×7; east_checkpoint(13,6),8×6. Original permissions,
MID drawing hashes and ground donors are recorded per assembly. Partial gates
outside a native map remain unclaimed. Optional Legendary recipes are outside
this standalone native census; they are not inferred from missing vanilla art.

Corrected totals per edition:136 identified assemblies,81 source eligible,
74 rendered accepted,55 unmatched;6232 unclassified blocked cells. Earlier
133-assembly denominators omitted these3 already-classified gates and their92
previously unclassified blocked cells. Modern acceptance remains unchanged.
The inventory still reports all426 maps/76 outdoors and separate7 eligible
shared-ground review gaps. This is not a full-map/game completion claim.

Original Saffron regional source592877 includes kn_gate_a_002-mesh (north/south
portal orientation) and kn_gate_b_001-mesh (east/west portals). Original UV/PNG
source front/side/rear/underside views were inspected in the official LÖVE shell.
North/south source physical bounds X[-44,44], Y[1.96875,81.50391],
Z[-68.08984,56] include its original entrance ramps. Uniform fitting within a
128×96 native body with.25px padding yields67.7251px width, about53% of the
native footprint. The broader source's portals face the other axis. Thus these
straight fits are not eligible: matching footprint, portal and authoritative
floor treatment remain unresolved. No model is stretched, ramp flattened,
doorway substituted or native floor/warp moved. Candidate metadata records this
specific gap, not a claim that no future genuine matching adapter is possible.

Source page/archive/model hashes are in the canonical candidates JSON. Raw
archives and generated source-gallery assets remain scratch-only. Native evidence
`.scratch/frlg-exteriors/api3-resume/out/gates-ledger-{firered,leafgreen}`;
source views `.scratch/frlg-exteriors/source-intake/gate-views`.
Continuing other original Kanto regional sources while these gate candidates
remain held. Current model additions Cerulean7b3aeefa and Celadon944cbf01 are
independent verified batches; root coordinates integration/release.
