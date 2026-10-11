# Kanto in First Person

Original author: mrmushrooms11.
Source: https://github.com/mrmushrooms11/kanto-first-person
Release: firstperson1.60.0 (kanto-first-person-1_60_0.zip).
SHA-256: b54b28271918aaab9a11ced66247898e51cff5e5f03d3530ff3b81bb3b25af29.

The project owner confirmed the author's permission to redistribute this code
and artwork on 2026-10-11. This is an attribution and provenance record, not a
claim that upstream grants a general-purpose open-source license.

Payload source, original panoramas/posters, audio and bird-transform source
are retained here. Bird sprites must be generated from the user's own imported
game data; no ROM-derived bird images are distributed. The upstream installer
and its file replacement/uninstall machinery are deliberately not included.
Runtime adapters live in lib/KantoFirstPerson.lua and related modules.

Not every vendored feature is enabled or ported merely because its source is
present. See docs/KANTO_FIRST_PERSON_INTEGRATION.md for runtime coverage.

Host adaptations: backdrop invalidation releases loaded images for live art
switching; sky initializes its star billboard before a night-first draw and
releases cloud textures on invalidation. Other payload sources are preserved.
