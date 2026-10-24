# Kanto source-door dispatcher integration

Standard HGSS Centers and the plain Viridian house now use the existing
Gen3ModernKantoBuildings dispatcher for build, original door draw, animation
ownership, chimney and teardown. Removes only the two stale direct build
branches (eleven lines) from Gen3Scene. Their body adapters already exclude the
separate original source panel; the direct paths previously skipped its draw
and release. Native door timing, warps, collision, floors, source fits and source
geometry remain unchanged. Missing source assets retain native fallback.

Production Scene SHA256 now exactly matches the isolated38-placement candidate:
`814cb7754b2445042cb8c71fa0c59126b39b7a143ad5baad43b68dfee0bb3439`.
Latest official engine rechecked0.3.96; isolated official Linux LÖVE11.5,
standalone API3. Current production reruns pass process0 for all18 standard
Centers and the plain Viridian house in each edition, with an assertion that
its actual source-door helper reached Scene draw. This is38 final placements:
34 Center actual entries/returns, two blocked Saffron no-warp projections and
two Viridian actual entries/returns. All native hashes remain unchanged.

Final36 Center overviews and both Viridian returns/door states inspected;
original blue sliding and orange hinged source panels now render. Identical-
code candidate front/side/rear/underside contact evidence remains applicable;
all36 Center close front views and both plain-house hinge views were inspected
there. Native view occlusions remain as recorded; source eligibility alone is
not substituted for rendered evidence. Four focused Center/door/Viridian/
dispatcher suites, Scene LuaJIT compilation and review-history regression pass.

All19 per-edition source-door holds are cleared after this final production
proof. Canonical per-edition counts now426 maps,76 outdoors,136 assemblies,
82 source eligible and82 rendered accepted,54 unmatched and6232 unclassified
blocked cells. This supersedes the63/19-held checkpoint and resolves the two
Saffron Center acceptance holds after their native paving fix. Remaining
regional/gate/landmark source gaps remain explicit; no whole-game completion
claim. Old failed reviews remain historical evidence, not current failures.

Exact final native commands from the mod checkout, separately per edition:

```sh
QA_QUICK=1 QA_DRIVER=$PWD/tools/qa/frlg-imported-center-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered center-final
QA_QUICK=1 QA_DRIVER=$PWD/tools/qa/frlg-imported-center-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py leafgreen center-final
QA_QUICK=1 python3 .scratch/frlg-exteriors/api3-resume/run.py firered viridian_plain
QA_QUICK=1 python3 .scratch/frlg-exteriors/api3-resume/run.py leafgreen viridian_plain
```

Evidence excluded from Git: `.scratch/frlg-exteriors/api3-resume/out/`
`center-final-{firered,leafgreen}` and `viridian_plain-{firered,leafgreen}`;
manual inspected-review receipts are `reviewed-results.json` alongside untouched
native `results.json`. Candidate full-angle evidence remains in
`center-dispatch-{firered,leafgreen}`. No assets, archives, runtime, caches,
captures or user saves added; version/push/release remain root-owned.
