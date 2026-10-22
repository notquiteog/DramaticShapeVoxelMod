# Weather clarity

Battle Art's weather drew broad pixel rectangles and a constant fog veil on the
completed world image. Replaced that with shader mist based on world distance
from the scene focus: the central five tiles stay clear in elevated and first
person cameras, with a capped, continuous falloff beyond them. No fog overlay
or extra fog render target. Rain and snow now share smooth, translucent bands
across overworld/battle; storms use restrained diffuse flashes instead of block
bolts and a heavy dark blanket. Weather remains presentation-only.

Clear scenes also faded prematurely at render-distance boundaries. Moved the
fade onset outward while retaining >99% fade at the existing culling edge.
Full-distance rectangular boundaries similarly retain a wider clear interior.
Existing forest/tower atmosphere, native weather gameplay and UI are unchanged.

Official engine0.3.95, Linux LÖVE11.5 shell from0.3.89: isolated Emerald Littleroot
clear/fog/rain/snow/storm captures, 3D-active and resolved-mode assertions.
Initial partial runtime sync fell back due to a missing newer building module;
corrected using the complete mod source before accepting any capture. No physical
phone or every-map acceptance claim. Weather parity and boundary tests pass.
