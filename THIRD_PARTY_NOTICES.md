# Third-party code

`assets/shaders/fsr1/ffx_a.h` and `ffx_fsr1.h` are the AMD FidelityFX Super Resolution 1 reference headers, from [GPUOpen-Effects/FidelityFX-FSR](https://github.com/GPUOpen-Effects/FidelityFX-FSR/tree/a21ffb8f6c13233ba336352bdff293894c706575/ffx-fsr), revision `a21ffb8f6c13233ba336352bdff293894c706575`. Copyright (c) 2021 Advanced Micro Devices, Inc.; additional notices appear in the headers. Distributed under the MIT license printed in both files.

The headers are unchanged. `lib/SpatialUpscale.lua` supplies texture callbacks, GLSL 330 packing/bitfield compatibility and unsigned setup literals, canvas management and quality options. It uses the full-precision EASU and RCAS algorithms. It does not implement AMD temporal upscaling, frame generation or NVIDIA DLSS.

## Voxel Ascendant weather

`lib/Weather.lua` is adapted from [Voxel Ascendant 2.0.2](https://github.com/Roxas2712/voxel-ascendant/blob/22c2bb5502290d4396aa3ab11d075ee2fb70e341/lib/Weather.lua).
Revision `22c2bb5502290d4396aa3ab11d075ee2fb70e341`, by Roxas2712 and contributors.
Native-generation outdoor metadata and shared Battle Art menu/render consumers
were added; VASC's platform-specific presenter is not used. No reference art,
ROM data or Kanto Ascendant campaign content was copied.

Original license:

```text
MIT License

Copyright (c) 2026 DramaticShape

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
