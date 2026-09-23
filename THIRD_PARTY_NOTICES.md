# Third-party code

`assets/shaders/fsr1/ffx_a.h` and `ffx_fsr1.h` are the AMD FidelityFX Super Resolution 1 reference headers, from [GPUOpen-Effects/FidelityFX-FSR](https://github.com/GPUOpen-Effects/FidelityFX-FSR/tree/a21ffb8f6c13233ba336352bdff293894c706575/ffx-fsr), revision `a21ffb8f6c13233ba336352bdff293894c706575`. Copyright (c) 2021 Advanced Micro Devices, Inc.; additional notices appear in the headers. Distributed under the MIT license printed in both files.

The headers are unchanged. `lib/SpatialUpscale.lua` supplies texture callbacks, GLSL 330 packing/bitfield compatibility and unsigned setup literals, canvas management and quality options. It uses the full-precision EASU and RCAS algorithms. It does not implement AMD temporal upscaling, frame generation or NVIDIA DLSS.
