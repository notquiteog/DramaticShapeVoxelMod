# Native audio option ownership — 2026-10-22

Cave ambience and Kanto First Person ambience used only `game.save.options`.
Gen3 owns live settings in `game.options`, so SFX volume/mute could be ignored.
Both now prefer native live options with GB/GBC save-options fallback. Regional
Kanto ambience and Ember's fallback mixer use the same precedence; explicit
native battle mixer providers retain priority.

Cave mute immediately stops ambience and an active footstep. KFP mute stops
active door/step sounds as well as looping beds. Ordinary map transitions keep
existing fades. Gameplay, native audio and model assets are untouched.

Validation: eight focused Lua suites passed, including15 installed update-hook
checks across three generations, live values, mute, stale save-options precedence,
optional asset failure and independent companion behavior. No new audible-device
verification or all-eleven-game runtime certification is claimed.
