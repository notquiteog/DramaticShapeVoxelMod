# Original Celadon landmark portal and footprint gaps

Further source intake reviewed genuine HGSS `ta_depart-mesh` and
`ta_mansion-mesh`, including their original separate panels, against the current
native FR/LG drawings. No production model or placement is added. The exact
failed candidates now replace generic gaps in the canonical per-map ledger.

[Celadon source592831](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592831/),
archive SHA256 `f2289da05c3190d9b21940b88f66233fc6b106198ab922aa64261384ed4b483f`,
DAE SHA256 `4a391a04af9bbad3391a35b8dd2bbe9cdda3800ff6626be0639e31ca7eab2d75`.
Original game art Nintendo/Creatures/GAME FREAK. Original source geometry, UVs
and images were extracted into scratch only; baked source shadow parts excluded
from the inspection gallery. These unclosed original exports are candidates,
not eligible/rendered-accepted runtime models.

Native Celadon department store(9,5) is9×10 with one walkable header and a
144×144px blocked body. Its original entrances are64px apart, at local body
(40,136) and(104,136). The HGSS source has one central entry, original panel
`p_door_004-mesh`, scene-derived offset(.4453,2.45313,32.4023). Current actual
SceneryModels.fit with padding.25 and each authoritative doorway yields only
78.91368×51.47417 or80.09510×52.24479px source footprint. Neither fills the native
body or supplies both native entrances. Duplicating the source entrance or
stretching the facade is not silently enabled.

Native Celadon Mansion(27,4) is7×8 with three original roof/header rows and a
112×80px blocked body. The native entry is centered at local body(56,72).
HGSS `ta_mansion` retains its original right-offset entry, panel
`p_door_005-mesh`, scene-derived offset(25.24218,2.45313,19.9101). At that exact
native portal, uniform fit is73.07265×52.86290px: under44percent of the blocked
area. A source wall cannot cover the remaining authoritative blocked cells
without another matching source/adaptation. Building, original door and native
collision are retained; no acceptance is inferred from a model merely fitting
inside its rectangle.

The remaining Saffron wide entrance drawing at City(41,34), connection(31,27),
was also inspected: a separate5×5 two-floor Trainer Fan Club, original centered
native portal. Existing `ybc_mmc` is the separately documented Copycat source;
its left-entry drawing is not automatically substituted for the wider native
club. No matching club placement was verified in this intake.

Latest official engine0.3.96: isolated native FireRed before-reference batch
passes process0 and displays original2D plus current3D drawings. Neutral source
front/quarter/back and all-side galleries inspected; source open rear/underside
limits remain visible. This is intake evidence, not completed native source
placement or LeafGreen visual acceptance. Both editions' canonical native hashes
and family/eligibility/acceptance counts remain unchanged by this metadata:
426 maps,136 assemblies,82 eligible,63 accepted,54 unmatched,19 explicit current
Scene-door holds per edition. No whole-game completion claim.

Scratch evidence: `.scratch/frlg-exteriors/api3-resume/out/next-fit-native-firered`
and `.scratch/frlg-exteriors/source-intake/portal-views`, source fit data
`models-next-fits.lua`. No original archives, models, native pixels, ROMs or
captures are committed. Additional regional source intake remains pending;
Vermilion592879/Fuchsia592836 original ZIPs are absent locally and normal download
currently returns403, with no browser surface available in this agent session.
The separate Scene dispatcher patch/proof is ready for root integration.
