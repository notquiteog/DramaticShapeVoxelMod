# Shared scenery resource ownership — 2026-10-23

Repeated regional source IDs previously charged identical original PNGs and
normalized geometry repeatedly. An uninterrupted RSE tour reached the existing
8 MiB image ceiling and rolled Route115 back from21 source fence cells to0.
Fresh Route115 alone passed21/21. Raising the limits would hide the duplication.

## Change and ownership

SceneryModels validates/copies each registration, then shares equal normalized
catalog data only for aliases of the same original definition table. Geometry
mutation and ID-dependent lighting roles remain isolated. Equal source aliases
also share immutable CPU and GPU prototypes. Model IDs retain separate public
registrations/providers and the existing256-ID ceiling.

Authorized image requests share exact SHA-256 PNG content plus sampler state,
including across provider paths. Same filename with different bytes and different
wrap modes stay separate. PNG bytes are not retained. Missing hashing retains the
previous bounded unshared path. Failed/stale yielding providers cannot publish an
image into a replacement registration. Existing byte, image, catalog, vertex,
prototype and model limits are unchanged.

Managed buildBatches parts hold image leases before a yielding upload. Cache
cleanup/unregister detaches aliases; the final managed mesh release frees its
image. Original pool callbacks permit cleanup across module reloads. Manual
image consumers (including animated doors) still release their meshes before
unregister/reset, as before. This does not claim opaque manual borrowers remain
valid across an active global reset. The native test exercises actual Scene
teardown, which releases both manual meshes and managed batches before clearing
resources. No registered/live-resource eviction was added.

## Verification

Official Gen1Recomp0.3.96 release checked before the final native batch, engine
commit0e92b587468c2db7c386f055fc272e6505b0f401. Exact tested SceneryModels SHA-256:
`ae97403489b24176aa74a51bf28a7878c5502c48759de524ac7ca90f3e70c30e`.
Own isolated profiles/source engine; player saves and central seeds untouched.

`tools/qa/hoenn-scenery-cache-tour.lua` performs two uninterrupted whole-reviewed-
fence tours per edition, compares settled native MID/collision/elevation grids,
checks every eligible source owner and records resource failures:

| Edition | Maps per tour | Source owners across both tours | Result |
| --- | ---: | ---: | --- |
| Emerald |14|1526/1526|PASS |
| Ruby |12|1504/1504|PASS |
| Sapphire |12|1504/1504|PASS |

Both tours restore Route11521/21. All editions record zero image/register errors,
zero recovery and stable unique resource totals after tour2:100 IDs/83 normalized
definitions,189053 catalog vertices/4712136 bytes,200 authorized image aliases/
65 physical Images/5500928 bytes. All existing caps remain unchanged, including
8388608 image bytes,262144 catalog vertices and10485760 catalog bytes. This
checkout includes queued rural/Mauville/Verdanturf sources and two held Littleroot
houses; these counts are source-checkout evidence, not a released ZIP claim.

Actual Scene.release reaches zero physical images, bytes, aliases and managed
leases in all three editions. Reenable/rebuild then restores Verdanturf4/4 with
no resource/recovery errors. Front/side reset captures in all editions inspected;
Route115 recovered source rails and Rustboro source paint also inspected. Native
floor/collision grids remain unchanged apart from separately recorded native
on-load script initialization. Actors/flowers retain HD2D defaults.

Eight relevant LuaJIT suites pass: scenery_resource_sharing, scenery_models,
scenery_catalog_capacity, scenery_source_lighting, shared_model_mesh,
imported_tree_models, gen3_imported_fences and gen3_scenery_models (official.96
SDK). New tests cover full unchanged byte/count/catalog/ID caps, exact PNG and
sampler isolation, source mutation/lighting normalization, prototype sharing,
unregister/reset/reload leases and final-ref accounting. Diff whitespace passes.

Scratch evidence (not committed):
`.scratch/hoenn-world-096-20261023/cache-tour-final/hoenn-scenery-cache-tour/`
contains each edition's scenery-resource-tour.json, run.log and final reset
captures. Before failure logs are under the same scratch area's
rural-diagnostics/hoenn-rural-fence-source/ruby. Earlier full-view source captures
are under cache-tour. Raw ROMs, caches and captures remain excluded.

Root still owns combined-companion/exact-package integration and release.
Whole-map/model coverage remains incomplete. Next active task is Hoenn outdoor
cave entrance depth; source fence and held house batches remain independent.
