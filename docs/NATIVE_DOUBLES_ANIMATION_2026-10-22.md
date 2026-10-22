# Native Gen3 doubles animation check — 2026-10-22

Unverified report: allied Pokemon frozen while opponents animate; edition and
selected style unknown. Extended the selected-BW regression to assert both allies
as well as both opponents advance, including independent normal/shiny identity.
784 checks pass. No Gen3 production change was justified by this reproduction.

Official0.3.95 engine, LÖVE11.5 shell from0.3.89 AppImage, NVIDIA, isolated profiles:
FireRed, LeafGreen, Ruby, Sapphire and Emerald each rendered a native trainer
double battle with Pikachu/Rattata on both teams. Over90update ticks the selected
images advanced for all four identities: allied full-body images had15/16 unique
frames, opposite Crystal fronts3/4. Five resulting scene captures inspected.

Fixture corrections: trainer class/name metadata was initially missing; first
LeafGreen attempt used a nonexistent LG map prefix rather than shared FR IDs.
Final fixtures passed. RSE logs also contain a caught legacy Game-facade warning;
this animation result is not a general clean-runtime certification.

This does not establish the reporter's unknown configuration or physical-phone
behavior. Gen1 paused target-animation defect is independently documented in
CRYSTAL_TARGET_ANIMATION_2026-10-22.md. Static source back sets intentionally stay
static; no animation style preference was silently overridden.
