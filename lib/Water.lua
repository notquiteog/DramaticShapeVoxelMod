-- Smooth water material shared by every native game adapter.
-- The existing FULL/SKY/OFF ladder remains: FULL reflects the opaque scene,
-- SKY uses the same surface without SSR, OFF retains ordinary native artwork.
-- Only alpha coverage is read from source water tiles; their pixel-wave RGB
-- never colors the reflective material. Native banks/floors remain separate.
-- A single analytic wave/gradient evaluation replaces relief traversal and
-- finite-difference normals. No additional surface textures or render passes.

-- the mod namespace (see main.lua): V.require loads a sibling module
local V = ...

local ModSetting = V.require("ModSetting")
local Sky = V.require("Sky")
local Celestial = V.require("Celestial")
local DayNight = V.require("DayNight")
local ShadowMap = V.require("ShadowMap")
local Mat4 = V.require("Mat4")

local Water = {}

-- ------- the row
--
-- Three rungs rather than a toggle, because the two halves of this cost
-- very different things. SKY is a handful of instructions per water pixel
-- and no extra buffers read; FULL adds the screen-space march, which is the
-- part that samples a depth texture twenty-odd times. A phone that wants the
-- sunset on the lake but not the ray march has somewhere to stand.
Water.KEY = "water"
Water.LABEL = "WATER"

Water.setting = ModSetting.new(Water.KEY, Water.LABEL,
                               { "full", "sky", "off" },
                               { "FULL", "SKY", "OFF" })

function Water.level()
  local v = Water.setting:get()
  if v == "off" then return 0 end
  if v == "sky" then return 1 end
  return 2
end

-- Whether the reflective pass should run at all (either rung above OFF).
function Water.enabled()
  return Water.level() > 0
end

-- Smooth Schlick reflectance: modest reflection overhead, strong grazing
-- reflections. The shader uses a fixed fifth-power polynomial, no pow loop.
Water.FRESNEL_FLOOR=.08
Water.FRESNEL_CEIL=.92
Water.FRESNEL_POWER=5
-- Compatibility telemetry for old external camera probes. The realistic
-- shader reflects the actual wave normal and does not apply a horizon lean.
Water.LEAN_FROM=.30;Water.LEAN_FULL=.55;Water.LEAN_ELEV=math.asin(.30)
function Water.lean(descent)
 local t=((descent or 0)-Water.LEAN_FROM)/(Water.LEAN_FULL-Water.LEAN_FROM)
 return math.max(0,math.min(1,t))
end

-- Legacy telemetry retained for companion diagnostics. The active surface
-- does not use these quantized waves, their stepped clock or their geometry.
Water.WAVE_HEIGHT=5
Water.WAVE_TRAINS={{.150,.062,1.60,.60},{.058,.132,-1.05,.29},{-.041,.033,.55,.11}}
Water.WAVE_SWELL={.0325,.0134,.55,.35}
Water.WAVE_BEND={-.0138,.0333,.35,1.10}
Water.WAVE_FPS=12
Water.WAVE_PIXELS_PER_STEP=1
Water.WAVE_STEPS=0
Water.WAVE_STRIDE=1
Water.WAVE_SLOPE=3.5
Water.WAVE_SLOPE_LEAN=1.5
function Water.waveRate()
 local t=Water.WAVE_TRAINS[1];local freq=math.sqrt(t[1]^2+t[2]^2);local speed=math.abs(t[3])
 return freq>0 and speed>0 and Water.WAVE_PIXELS_PER_STEP*(freq/speed)*Water.WAVE_FPS or 0
end
Water.REALISTIC=true

-- ------- the cast, reflected in the plane rather than marched for
--
-- See Voxel3D.beginCast. The cast is drawn a second time through a camera
-- mirrored about the water plane, and this composites that canvas at each
-- fragment's OWN screen position, which is exactly where a flat mirror
-- would put it.
--
-- Composited AFTER the fresnel mix rather than into the reflection before
-- it, and that is deliberate. Fresnel is smallest looked straight down at,
-- so folding a person into `refl` would fade them out at precisely the
-- camera this exists to serve -- which is the same mistake the march made
-- by handing its ray to the horizon lean.
Water.CAST_ALPHA = 0.55
-- How far the wave normal drags the lookup, in screen widths. Small: this
-- ripples a reflection along with the surface carrying it, and much more
-- than a few thousandths tears the figure apart rather than disturbing it.
Water.CAST_WOBBLE = 0.006

-- TEST129: true water-plane reflection. The old +6 sprite-padding shift
-- lifts submerged 3D geometry through the real mount after swimming support
-- is corrected. Actors are now depth-tested and clipped in their cast pass.
Water.CAST_RAISE = 0

-- THE MARCH. Steps are in world pixels and lengthen as they go: near the
-- surface the reflection needs precision (a shoreline is a few pixels), far
-- from it reach matters more than accuracy, and a geometric ramp gets both
-- out of one loop. RAY_STEPS is compiled in -- GLSL wants a constant bound.
Water.RAY_STEPS = 16
Water.RAY_REFINE = 4           -- halvings once a crossing is found
Water.RAY_STEP = 3.0           -- world pixels in the first step
-- TEST10 uses fewer, wider steps for lower reflection cost.
-- The geometric ramp preserves broad reach at reduced sampling precision;
-- the existing tail fade still blends distant reflections into the sky.
Water.RAY_GROW = 1.33
-- How far behind the depth buffer a crossing may land and still count, as a
-- multiple of the depth the step itself covered. A ray that dives far past
-- what it crossed went BEHIND a thin thing rather than hitting it -- the
-- classic screen-space smear, where a tree between the camera and the pond
-- paints itself across the water -- and this is the test that drops it.
Water.RAY_THICK = 1.6
Water.EDGE_FADE = 0.14         -- reflection eased off over this much of the frame

-- Shared scene vertex/curve path; lighting/reflection uses the unbent
-- physical sheet and re-applies the scene curve during depth projection.
local SHADER_SRC = [[
varying float vShade;
varying vec3 vSun;
// World position, as drawn -- and a varying that cannot ride GLSL ES's
// mediump fragment default: everything below floors it into columns and
// marches it through the frame's matrices, and a route's coordinates run
// to a few thousand, where fp16 has no fraction left at all. The same
// reasoning the scene shader's vGrid states at length.
varying LOVE_HIGHP_OR_MEDIUMP vec3 vBent;

#ifdef VERTEX
uniform mat4 vp;
uniform mat4 model;
uniform mat4 sunVP;
uniform vec3 curve;          // xy = the focus in world XZ, z = k; 0 = off
attribute float VertexShade;

vec4 position(mat4 transform_projection, vec4 vertex_position) {
  vShade = VertexShade;
  vec4 w = model * vertex_position;
  vSun = (sunVP * w).xyz;
  if (curve.z > 0.0) {
    vec2 cd = w.xz - curve.xy;
    w.y -= dot(cd, cd) * curve.z;
  }
  vBent = w.xyz;
  return vp * w;
}
#endif

#ifdef PIXEL
// Everything below works in WORLD units through the frame's own matrices,
// and GLSL ES defaults fragment floats to mediump -- fp16, out of fraction
// by a coordinate of two thousand and quantising a depth into steps the
// march falls straight through. Worse than wrong pictures: `vp` is
// declared by BOTH stages, the vertex side's default is highp, and GLSL ES
// refuses to LINK a uniform whose precision the two stages disagree on --
// which is not broken water but NO water shader at all, the flat fallback
// with nothing in the log. One statement lifts the whole stage; the guard
// keeps the odd GPU without fragment highp compiling, and such a driver
// falls back to flat water exactly as it did before this pass existed.
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#endif
#endif
uniform mat4 vp;
uniform vec3 eye;
uniform vec3 fogColor;
uniform vec4 fogBounds;
uniform vec3 fogOrigin;
uniform vec4 fogInfo;
// The same bend the vertex stage applied. This stage has to undo it to get
// back to the flat world it reflects in, and re-apply it on every marched
// sample to get back to the screen. Declared in both stages, like `vp`, and
// both are highp here.
uniform vec3 curve;          // xy = the focus in world XZ, z = k; 0 = off

// How far the bend has pushed the world down at world XZ `q` -- the vertex
// stage's own displacement, as a number this stage can add and subtract.
// Zero when the curve is off, which is the shader's "skip it" everywhere.
float bendDrop(vec2 q) {
  if (curve.z <= 0.0) return 0.0;
  vec2 d = q - curve.xy;
  return dot(d, d) * curve.z;
}

// the sun's own pass, exactly as the scene shader reads it
uniform Image sunMap;
uniform float sunDark;
uniform float sunBias;
uniform vec2 sunTexel;
uniform vec3 dayTint;

// the frame as it stood before the water went down, and its depth. The
// depth sampler is qualified because GLSL ES defaults samplers to LOWP no
// matter what floats are set to, and eight bits of depth is a march with
// nothing to land on. The frame copy is honest 8-bit colour and can stay.
#ifndef SKY_ONLY
uniform Image reflectTex;
#ifndef NATIVE_WATER
uniform Image underColor;
#endif
uniform LOVE_HIGHP_OR_MEDIUMP Image underDepth;
uniform mat4 inverseVP;
uniform float underOn;
uniform float transmissionOn; // SSR RGB must not transmit a curved water prepass
uniform LOVE_HIGHP_OR_MEDIUMP Image depthTex;
uniform float rays;          // 0 = sky only, 1 = march the screen too
#endif

// The cast, mirrored in the water plane (Voxel3D.beginCast).
//
// OUTSIDE the SKY_ONLY guard, unlike the march's own buffers: this is a
// texture lookup at a fixed uv, not a walk, so the rung that cannot afford
// to march can still afford to have people in its water.
//
// Declared and bound whatever castOn says: an unbound sampler is a
// driver-dependent crash rather than a fallback, the same reason sunMap is
// always given something.
uniform LOVE_HIGHP_OR_MEDIUMP Image castTex;
uniform float castOn;        // 0 = there is no cast canvas this frame
uniform float castAlpha;
uniform float castWobble;
uniform float waveHeight;    // bounded physical ripple height
uniform float waveSlope;     // reflection-normal strength
uniform float rippleT; // continuous, independent of paused engine tile ticks
uniform float gardenWater;
uniform vec4 nativePalette;
uniform float reserveWater;
uniform float fresnelFloor;
uniform float fresnelCeil;
uniform float rayStep;
uniform float rayGrow;
uniform float rayThick;
uniform float edgeFade;

// the sky, as Sky paints it
uniform Image skyRamp;
uniform float skyCount;
uniform float skyEdge;       // the sky's bottom, in canvas pixels
uniform float skyOn;         // 0 indoors: there is no sky to reflect

// and what hangs in it
uniform vec3 bodyDir;
uniform float bodyOn;
uniform float bodyMoon;
uniform float bodyAng;       // the disc's angular radius, in radians
uniform vec3 bodyCore;
uniform vec3 bodyMain;
uniform vec3 bodyDark;
uniform float glowAmt;
uniform float glowReach;     // in radians, like bodyAng
uniform vec3 glowColor;


// ------- the sun's pass (the scene shader's, verbatim)

// One shadow tap: 1 where the sun reaches, 0 where something blocks it --
// EXCEPT that water declines one kind of blocker.
//
// The sun pass marks the cast in the blue channel (ShadowMap.sprites), and
// water ignores those. A character standing at a lake's edge laid a hard
// cut-out of its own sprite across the surface, and on something that is
// already showing the sky, the shoreline and the trees behind it, a
// silhouette of somebody reads as a sticker on the water rather than as a
// shadow in it. Everything the WORLD casts -- trees, buildings, cliffs,
// ledges -- still shades it, which is the half that was worth having.
float sunLit(vec2 uv, float z) {
  vec4 c = Texel(sunMap, uv);
  return max(step(z, c.r + c.g * (1.0 / 255.0)), c.b);
}

float sunlight(vec3 p) {
  if (sunDark <= 0.0) return 1.0;
  if (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0 || p.z > 1.0) {
    return 1.0;
  }
  vec2 e = min(p.xy, 1.0 - p.xy);
  float edge = smoothstep(0.0, 0.06, min(e.x, e.y));
  if (edge <= 0.0) return 1.0;
  float z = p.z - sunBias;
  float lit = sunLit(p.xy + sunTexel * vec2(-0.5, -0.5), z)
            + sunLit(p.xy + sunTexel * vec2( 0.5, -0.5), z)
            + sunLit(p.xy + sunTexel * vec2(-0.5,  0.5), z)
            + sunLit(p.xy + sunTexel * vec2( 0.5,  0.5), z);
  return 1.0 - sunDark * edge * (1.0 - lit * 0.25);
}

// ------- the sky, by direction

//@CLOUDS

vec3 bandAt(float i) {
  return Texel(skyRamp,
               vec2((clamp(i, 0.0, skyCount - 1.0) + 0.5) / skyCount, 0.5)).rgb;
}

// Where a DIRECTION lands on the sky's own gradient, as a band coordinate
// in [0, count]: 0 is straight overhead, count the horizon.
//
// Measured by putting the direction through the very matrix the frame is
// drawn with, as a point at infinity -- which is how Voxel3D finds both the
// vanishing line and the sun's place on the canvas. So the reflected sky and
// the painted sky are answering the same question with the same arithmetic,
// and they agree at the waterline for free at any pitch, fov or zoom.
//
// A direction whose w comes out negative is BEHIND the camera plane, which
// for an upward reflection means near-vertical: the top band, overhead.
float skyPos(vec3 d) {
 float elevation=asin(clamp(d.y,0.0,1.0));
 return (1.0-elevation/1.570796327)*max(skyCount-1.0,0.0);
}
vec3 skyAt(vec3 d,float parity) {
 float pos=skyPos(d);
 return mix(bandAt(floor(pos)),bandAt(floor(pos)+1.0),fract(pos));
}

//@CELESTIAL
float crater(vec2 p, vec2 c, float r) {
  vec2 dd = p - c;
  return step(dot(dd, dd), r * r);
}

// The sun or moon, and the twilight warmth around it, laid over the bands.
//
// By ANGLE, not by screen position: the reflected direction usually
// projects off the top of the frame entirely, where screen distances stop
// meaning anything. bodyAng is Sky.discRadius run back through the camera's
// field of view, so this disc is the same size as the painted one.
vec3 bodyAt(vec3 d, vec3 c, float parity) {
  if (bodyOn <= 0.0) return c;
  float ang = acos(clamp(dot(d, bodyDir), -1.0, 1.0));
  if (glowAmt > 0.0) {
    float g = glowAmt * pow(clamp(1.0 - ang / glowReach, 0.0, 1.0), 2.0);
    c = mix(c,glowColor,g*.65);
  }
  float t = ang / max(bodyAng,0.00001);
  if (t > 1.3) return c;
  vec3 right = cross(vec3(0.0, 1.0, 0.0), bodyDir);
  if (dot(right,right)<0.0001) right=vec3(1.0,0.0,0.0);
  right=normalize(right);
  // Sky image Y points down. Keep crater orientation on the reflected body.
  vec2 dc=vec2(dot(d,right),-dot(d,cross(bodyDir,right)))/max(bodyAng,0.00001);
  vec3 disc=celestialSurface(dc,bodyMoon,bodyCore,bodyMain,bodyDark);
  float edge=1.0-smoothstep(.985,1.015,t);
  float halo=exp(-max(0.0,t-1.0)*18.0)*.10*(1.0-smoothstep(1.10,1.29,t));
  disc=mix(c,mix(bodyCore,disc,edge),max(edge,halo));
  return disc;
}

#ifndef SKY_ONLY
// ------- the screen-space march

// A point as (uv, depth, valid), through the very matrix the frame was drawn
// with. The uv and the depth are the same numbers the hardware wrote -- the
// clip-space Y flip is already baked into `vp`, and a canvas texture's v runs
// the same way its pixel rows do, so one 0.5x+0.5 answers for both.
//
// The point arrives in the FLAT world -- the space the ray is straight in --
// and is bent here, by the same displacement the vertex stage applied, so it
// lands exactly where the geometry it is being compared against landed. That
// split is the whole trick: the reflection is worked out in a world that has
// not been tipped, and every sample of it is tipped on the way to the screen,
// so the march reads the depth buffer it actually has.
vec4 project(vec3 p) {
  p.y -= bendDrop(p.xz);
  vec4 c = vp * vec4(p, 1.0);
  if (c.w <= 1e-6) return vec4(0.0, 0.0, 0.0, 0.0);
  return vec4(c.xy / c.w * 0.5 + 0.5, c.z / c.w * 0.5 + 0.5, 1.0);
}

// Walk the reflected ray until it passes behind the depth buffer. Returns
// the colour found in .rgb and how much of it to believe in .a -- 0 for a
// ray that left the frame, ran out of steps, or crossed something it went
// straight through rather than landed on.
float reflectedDepth(vec2 uv) {
  if (reserveWater > .5 && underOn > .5) {
    vec3 sceneDepthRGB = floor(Texel(underDepth,uv).rgb*255.0+.5);
    return dot(sceneDepthRGB,vec3(65536.0,256.0,1.0))/16777215.0;
  }
  return Texel(depthTex,uv).r;
}
vec4 march(vec3 origin, vec3 dir) {
  vec4 miss = vec4(0.0, 0.0, 0.0, 0.0);
  vec3 a = origin;
  vec4 pa = project(a);
  if (pa.w < 0.5) return miss;
  float len = rayStep;
  for (int i = 0; i < RAY_STEPS; i++) {
    vec3 b = a + dir * len;
    vec4 pb = project(b);
    if (pb.w < 0.5) return miss;
    if (pb.x < 0.0 || pb.x > 1.0 || pb.y < 0.0 || pb.y > 1.0) return miss;
    float scene = reflectedDepth(pb.xy);
    if (pb.z > scene) {
      // how much depth this one step covered: the yardstick for whether
      // the crossing is a surface or a thin thing the ray shot past
      float span = max(abs(pb.z - pa.z), 1e-7);
      if (pb.z - scene > span * rayThick) return miss;
      // binary-refine onto the contact
      vec3 lo = a;
      vec3 hi = b;
      for (int k = 0; k < RAY_REFINE; k++) {
        vec3 m = (lo + hi) * 0.5;
        vec4 pm = project(m);
        if (pm.z > reflectedDepth(pm.xy)) { hi = m; } else { lo = m; }
      }
      vec4 hit = project(hi);
      if (hit.w < 0.5) return miss;
      // Ease out at the frame's rim, where the reflection is about to run
      // off the only evidence there is -- and with distance travelled, so a
      // long ray hands back to the sky instead of ending on a hard edge.
      //
      // The distance term is doing two jobs. It hides the march's own tail,
      // where the steps are longest and a grazing crossing is least likely
      // to be a real surface -- and it is also true: distant water reflects
      // haze rather than detail, and the haze is what the bands underneath
      // already are. The small floor keeps a genuine far hit as a trace
      // rather than deleting it.
      vec2 e = min(hit.xy, 1.0 - hit.xy);
      float edge = smoothstep(0.0, edgeFade, min(e.x, e.y));
      float far = 1.0 - clamp(float(i) / float(RAY_STEPS), 0.0, 1.0);
      return vec4(Texel(reflectTex, hit.xy).rgb, edge * (0.15 + 0.85 * far));
    }
    a = b;
    pa = pb;
    len *= rayGrow;
  }
  return miss;
}
#endif

// ------- the continuous surface and analytic gradient

// Analytic, continuous world-space surface; one evaluation supplies its
// height and exact X/Z gradient, with derivative-based horizon filtering.
//@NATIVE_SURFACE

// The float parameters are pinned to mediump BECAUSE the stage default is
// not: LOVE's own header forward-declares effect() under its default, and
// at least one mobile compiler (Samsung's Xclipse, in so many words) holds
// that a definition whose parameter precisions differ from its prototype's
// is a second function of the same name, and refuses the pair. The params
// can afford it -- the colour is a colour, and tc/sc arrived through
// LOVE's mediump plumbing whatever this signature says -- and the maths
// below runs on the stage default the moment the values touch a local.
EFFECT_PREC vec4 effect(EFFECT_PREC vec4 color, Image tex, EFFECT_PREC vec2 tc, EFFECT_PREC vec2 sc) {
  // THE DEPTH TEST, done here because the buffer that would have done it is
  // detached for the length of this pass so it can be READ (see the header).
  // Same comparison, same buffer, same result: a building in front of a pond
  // still hides it.
  //
  // Normalised by LOVE's own screen size, not by the `screen` uniform: `sc`
  // arrives in canvas PIXELS, and on a highdpi surface (Android's density
  // is routinely 2.625) a canvas holds that many pixels per canvas UNIT,
  // which is what `screen` counts. Divided by units, uv runs to 2.6 and
  // clamps, and the test reads edge texels for two thirds of the frame --
  // discarding water in blocks and letting the haze backdrop through, which
  // on a phone looked like lakes with pieces missing. love_ScreenSize.xy is
  // the bound canvas's own pixel size, the same units sc is measured in, on
  // every display. (`screen` stays in units: skyPos reads it against cell
  // and skyEdge, which are unit-measured with it.)
  //
  // The buffer now holds THIS SURFACE too (VoxelScene draws the water flat
  // before the pass that reflects it), which is what makes one lake able to
  // hide another -- and it means every fragment here is testing against its
  // own depth. That raises the bar on the fragment's own z: gl_FragCoord is
  // allowed to be MEDIUMP on GLES (and is, on Adreno), and fp16 near the far
  // end of the range steps by about half a thousandth -- which the old test
  // against the terrain far behind the surface never felt, and a comparison
  // of the surface against itself loses outright. Every fragment failed, the
  // pass discarded the whole lake, and Android showed the flat draw
  // underneath. So the depth is recomputed HERE, in highp, from the same
  // vBent and vp the vertex stage used -- full precision on every driver.
  //
  // The slack is sized to what remains after that, which is not rounding:
  // the buffer holds depth interpolated LINEARLY IN SCREEN SPACE, while the
  // recomputation projects the perspective-interpolated vBent -- the exact
  // answer. The two agree at the vertices and drift apart across a quad's
  // interior, by more the bigger the quad stands on screen; on a phone
  // (fit scale 6, water quads hundreds of pixels tall) the drift crosses
  // 1e-5 mid-quad, which discarded the middle of every tile row and looked
  // like flat water with reflective seams. Anything GENUINELY in front of a
  // water pixel is whole world units nearer -- upward of 1e-3 in depth --
  // so 2e-4 clears the drift with room while still catching every occluder.
#ifndef SKY_ONLY
  vec2 uv = sc / love_ScreenSize.xy;
  vec4 selfC = vp * vec4(vBent, 1.0);
  float selfZ = selfC.z / selfC.w * 0.5 + 0.5;
  // The pre-water snapshot contains opaque scenery only, so it needs no
  // self-water tolerance. Prevent reflection fragments leaking over walls.
  if (underOn > 0.5) {
    vec3 opaquePacked = floor(Texel(underDepth,uv).rgb*255.0+.5);
    float opaqueZ = dot(opaquePacked,vec3(65536.0,256.0,1.0))/16777215.0;
    // Pads are only fractions of a world pixel above the sheet. A fixed
    // 2e-6 slack erased their depth advantage at ordinary viewing distances.
    // The opaque snapshot has no water self-comparison: one packed-depth LSB
    // is enough for quantization, while keeping thin leaves in front.
    float opaqueSlack = gardenWater > .5 ? (1.0 / 16777215.0) : 2e-6;
    if (selfZ > opaqueZ + opaqueSlack) discard;
  }
  if (selfZ > Texel(depthTex, uv).r + 2e-4) discard;
#endif

  vec3 sheet=vec3(vBent.x,vBent.y+bendDrop(vBent.xz),vBent.z);
  vec3 view=normalize(sheet-eye);
  vec3 wave=nativeSurface(sheet.xz,rippleT,abs(fwidth(sheet.xz)));
  vec3 surf=vec3(sheet.x,sheet.y+(wave.x-.5)*waveHeight,sheet.z);
  vec3 hit=surf;
  vec3 n=normalize(vec3(-wave.y*waveSlope,1.0,-wave.z*waveSlope));
  // Keep source alpha coverage, including cutouts. RGB is never sampled as
  // material: white/blue sprite-wave bands cannot bleed into this surface.
  if (Texel(tex,tc).a<.5)discard;
  vec3 material=vec3(.025,.225,.280);
  vec3 regional=clamp(nativePalette.rgb*vec3(.28,.48,.58),vec3(.018,.10,.14),vec3(.065,.25,.31));
  material=mix(material,regional,nativePalette.a*.25);
  float sun= sunlight(vSun);
  vec3 base=material*(.94+.12*wave.x)*sun*dayTint;
  vec3 r=reflect(view,n);
  vec3 refl=base;
  if(skyOn>.5){
    refl=bodyAt(r,skyAt(r,0.0),0.0);
    vec4 cloud=cloudAt(r);refl=mix(refl,cloud.rgb,cloud.a);
  }
#ifndef SKY_ONLY
  if(rays>.5&&r.y>.01){
    vec4 scene=march(surf,r);refl=mix(refl,scene.rgb,scene.a);
  }
#endif
  float ct=clamp(dot(-view,n),0.0,1.0);
  float grazing=1.0-ct;float grazing2=grazing*grazing;
  float f=fresnelFloor+(fresnelCeil-fresnelFloor)*grazing2*grazing2*grazing;
#ifndef SKY_ONLY
  if(underOn>.5&&transmissionOn>.5){
    vec2 tuv=sc/love_ScreenSize.xy;
    vec3 packedDepth=floor(Texel(underDepth,tuv).rgb*255.0+.5);
    float bd=dot(packedDepth,vec3(65536.0,256.0,1.0))/16777215.0;
    vec4 bw=inverseVP*vec4(tuv*2.0-1.0,bd*2.0-1.0,1.0);
    if(abs(bw.w)>.000001&&bd<.999999){
      vec3 bentBed=bw.xyz/bw.w;
      float depth=sheet.y-(bentBed.y+bendDrop(bentBed.xz));
      if(depth>.10&&depth<64.0){
#ifdef NATIVE_WATER
        vec3 bedColor=Texel(reflectTex,tuv).rgb;
#else
        vec3 bedColor=Texel(underColor,tuv).rgb;
#endif
        // RGB absorption makes deeper water bluer without a tiled color map.
        vec3 transmission=exp(-depth*vec3(.18,.075,.045));
        base=mix(base,bedColor*vec3(.72,.93,.96)*dayTint,transmission*.62);
      }
    }
  }
#endif
  vec3 rgb = mix(base, refl, clamp(f,0.0,1.0));
  // Small filtered variations, with no quantized color or crest staircases.
  rgb+=vec3(.008,.018,.023)*(wave.x-.5)*max(dayTint,vec3(.25));
  if(bodyOn>.5){
    // A broad, restrained microfacet lobe responds to the same normal. No
    // noise/octaves, extra texture lookups or time-dependent sparkle hash.
    vec3 halfLight=normalize(bodyDir-view);
    float spec=max(dot(n,halfLight),0.0);float s2=spec*spec;float s4=s2*s2;
    float s8=s4*s4;float s16=s8*s8;
    rgb+=bodyMain*(s16*s8)*sun*(bodyMoon>.5?.035:.16);
  }

  // THE CAST, mirrored in this plane (see CAST_ALPHA). Read at this
  // fragment's own place on the screen, because that is where the mirrored
  // camera has already put it -- nothing here has to work out where a
  // reflection belongs, which is the whole reason this is drawn with a
  // camera rather than by nudging sprites about.
  //
  // The uv is LOVE's own screen size for the same reason the depth test
  // above uses it: `sc` arrives in canvas pixels, and on a highdpi surface
  // that is not the same count as `screen`, which is measured in units.
  //
  // Dragged by the wave normal so a figure ripples with the surface holding
  // it rather than lying flat on top of it, and the canvas's ALPHA decides
  // where there is anything to composite at all.
  if (castOn > 0.5) {
    vec2 cuv = sc / love_ScreenSize.xy + n.xz * castWobble;
    vec4 person = Texel(castTex, cuv);
    rgb = mix(rgb, person.rgb, clamp(person.a * castAlpha, 0.0, 1.0));
  }

#ifdef VOXEL_GRID
  // Smooth water deliberately does not inherit terrain voxel-grid seams.
#endif
  if (fogInfo.x > 0.0) {
    float distance = fogInfo.w > 0.5 ? length(hit.xz - fogOrigin.xz) : length(hit - eye);
    if (fogInfo.w > 1.5) {
      vec2 side = mix(fogOrigin.xz - fogBounds.xy,fogBounds.zw - fogOrigin.xz,step(fogOrigin.xz,hit.xz));
      vec2 progress = abs(hit.xz - fogOrigin.xz) / max(side,vec2(1.0));
      distance = max(progress.x,progress.y);
    }
    float haze = (1.0 - exp(-fogInfo.x * max(0.0, distance - fogInfo.y)))
                 * exp(-max(hit.y, 0.0) * fogInfo.z);
    rgb = mix(rgb, fogColor, haze);
  }
  return vec4(rgb, 1.0) * color;
}
#endif
]]

-- The crater list is Sky's (Sky.MOON_CRATERS), pasted in as source rather
-- than sent as a uniform array: GLSL ES has no array constructors worth
-- relying on, and the driver bug that cost the sky its bands is exactly
-- what a uniform array of vectors buys. Built from the one list, so the
-- moon on the water can never grow craters the moon in the sky has not.
local function craterSource()
  local out = {}
  for _, c in ipairs(Sky.MOON_CRATERS) do
    out[#out + 1] = ("    k += crater(dc, vec2(%.4f, %.4f), %.4f);")
      :format(c[1], c[2], Sky.CRATER_FRAC)
  end
  return table.concat(out, "\n")
end

Water._craterSource = craterSource     -- named for the suite

-- and the wave trains, pasted in for the same reason: the rate is derived
-- from this table (Water.waveRate), so the field the shader sums has to be
-- the one that table describes rather than a copy of it kept in step by hand.
--
-- The dominant train carries the swell and the bend (see WAVE_SWELL): its
-- phase wobbles by the bend field and its amplitude breathes with the swell
-- envelope, both off the same tables the constants above document. One
-- statement per train either way, which is what the suite counts.
local function trainSource()
  local out = {}
  for i, t in ipairs(Water.WAVE_TRAINS) do
    if i == 1 then
      local s = Water.WAVE_SWELL
      local b = Water.WAVE_BEND
      out[#out + 1] = (
        "  h += sin(dot(q, vec2(%.4f, %.4f)) + waveT * %.4f\n"
        .. "           + %.4f * sin(dot(q, vec2(%.4f, %.4f)) + waveT * %.4f))\n"
        .. "       * %.4f * (1.0 - %.4f * (0.5 + 0.5 *\n"
        .. "           sin(dot(q, vec2(%.4f, %.4f)) + waveT * %.4f)));")
        :format(t[1], t[2], t[3],
                b[4], b[1], b[2], b[3],
                t[4], s[4], s[1], s[2], s[3])
    else
      out[#out + 1] = ("  h += sin(dot(q, vec2(%.4f, %.4f)) + waveT * %.4f)"
                       .. " * %.4f;"):format(t[1], t[2], t[3], t[4])
    end
  end
  return table.concat(out, "\n")
end

Water._trainSource = trainSource       -- named for the suite

local function source(grid, skyOnly, bare, native)
  local src = (bare and "#define EFFECT_PREC\n" or "#define EFFECT_PREC mediump\n") .. SHADER_SRC
  src = src:gsub("//@CRATERS", (craterSource():gsub("%%", "%%%%")))
  src = src:gsub("//@CELESTIAL", function()return Celestial.surface end)
  src = src:gsub("//@NATIVE_SURFACE",function()return V.require("NativeWaterSurface").glsl end)
  local clouds
  if native or skyOnly then local ok,result=pcall(V.require,'Clouds');if ok then clouds=result end end
  src=src:gsub("//@CLOUDS",function()return clouds and clouds.glsl or 'vec4 cloudAt(vec3 d){return vec4(0.0);}'end)
  local head = ("#define RAY_STEPS %d\n#define RAY_REFINE %d\n"
                .. "#define WAVE_STEPS %d\n#define WAVE_STRIDE %.1f\n")
    :format(Water.RAY_STEPS, Water.RAY_REFINE, Water.WAVE_STEPS,
            Water.WAVE_STRIDE)
  if native then head=head.."#define NATIVE_WATER 1\n" end
  if grid then head = head .. "#define VOXEL_GRID 1\n" end
  if skyOnly then head = head .. "#define SKY_ONLY 1\n" end
  return head .. src
end

Water._source = source                 -- named for the suite

-- Four programs: FULL/SKY and packed/native source-depth variants. Grid
-- requests reuse them because smooth water has no voxel seam program.
-- nil = untried, false = unavailable.
local shaders = {
  full = { [false] = nil, [true] = nil },
  sky = { [false] = nil, [true] = nil },
  nativeFull = { [false] = nil, [true] = nil },
  nativeSky = { [false] = nil, [true] = nil },
}

function Water.shader(grid, skyOnly, native)
  -- Terrain grid does not add seams to smooth water; share its program.
  grid = false
  local family = native and (skyOnly and shaders.nativeSky or shaders.nativeFull) or (skyOnly and shaders.sky or shaders.full)
  if family[grid] == nil then
    if not (love.graphics and love.graphics.newShader) then
      family[grid] = false
    else
      local ok, sh = pcall(love.graphics.newShader, source(grid, skyOnly, false, native))
      if not ok then ok, sh = pcall(love.graphics.newShader, source(grid, skyOnly, true, native)) end
      if not ok and V and V.mod and V.mod.log then
        -- once, where it can be read: the fallback is flat water, which is
        -- easy to look at and impossible to diagnose without this line
        V.mod.log:warn("water shader did not compile: %s -- lakes draw flat",
                       tostring(sh))
      end
      family[grid] = (ok and sh) or false
    end
  end
  return family[grid] or nil
end

-- ------- the pass

local active = nil        -- the shader this pass bound, or nil
local activeNative = false
local noPalette={0,0,0,0}
local identity=Mat4.identity()
local drawUniforms=V.require('WaterDrawUniforms').new()

-- The ripple phase. Driven by the ENGINE's tile-animation clock, the same
-- 60Hz counter the water tiles rotate on, so the ripple and the art it
-- ripples move off one number rather than drifting against each other.
local function waveTime()
  -- lazily, and through the mod namespace: TerrainAtlas reaches into the
  -- engine's renderer at load time, and nothing about a settings row should
  -- depend on that having happened yet
  local ok, frame = pcall(function()
    return V.require("TerrainAtlas")._animFrame()
  end)
  if not (ok and type(frame) == "number") then return 0 end
  -- floored to the wave beat (see WAVE_FPS). The engine's counter runs at
  -- 60, so this is the frame that step began on.
  local period = 60 / math.max(1, Water.WAVE_FPS)
  return (math.floor(frame / period) * period / 60) * Water.waveRate()
end

Water._waveTime = waveTime
local function rippleTime()
  if love.timer and love.timer.getTime then return love.timer.getTime() % (40 * math.pi) end
  return waveTime()
end
Water._rippleTime = rippleTime

-- Begin the reflective pass.
--
-- `ctx` is everything the pass cannot work out for itself, all of it already
-- computed by whoever set the camera up this frame:
--
--   reflect   the frame so far, as a texture (Voxel3D.beginWater)
--   depth     its depth, likewise
--   vp, eye, curve, screen, cell   the camera, as beginScene sent it
--   skyEdge   where the sky's bottom is, or nil indoors / with no bands
--   grid      whether the voxel wireframe is compiled into this frame
--
-- Returns false when the pass cannot run, in which case the caller draws the
-- water mesh through the ordinary scene shader instead.
function Water.begin(ctx, skyOnly)
  if not ctx then return false end
  skyOnly = skyOnly and true or false
  if not skyOnly and not (ctx.reflect and ctx.depth) then return false end
  if skyOnly then
    local ramp, count = Sky.ramp()
    local edge = ctx.skyEdge
    if not (ramp and count and edge and edge > 0) then return false end
  end
  local level = Water.level()
  if level <= 0 then return false end
  -- A separate opaque-color snapshot is required for planted/curved GB
  -- transmission. Its FULL program omits cloudAtlas to stay within eight
  -- samplers. Ordinary water shares the compact FULL program and clouds.
  local native=ctx.nativeWater==true or not ctx.underColor
  local sh = ctx.grid and Water.shader(true, skyOnly, native) or nil
  if not sh then sh = Water.shader(false, skyOnly, native) end
  if not sh then return false end

  love.graphics.setShader(sh)
  love.graphics.setColor(1, 1, 1, 1)
  local function send(name, ...)
    pcall(sh.send, sh, name, ...)
  end

  activeNative=native
  send("gardenWater", 0)
  send("reserveWater", 0)
  send("vp", "row", ctx.vp)
  send("eye", ctx.eye)
  send("curve", ctx.curve)
  if not skyOnly then
    send("reflectTex", ctx.reflect)
    send("depthTex", ctx.depth)
    local inverse=ctx.underDepth and (ctx.nativeWater or ctx.underColor) and V.require('WaterBackdrop').inverse(ctx.vp)
    send('underOn',inverse and 1 or 0)
    send('transmissionOn',native and ctx.curve and (ctx.curve[3]or 0)>0 and 0 or 1)
    send('underColor',ctx.underColor or ctx.reflect)
    send('underDepth',ctx.underDepth or ctx.reflect)
    send('inverseVP','row',inverse or Mat4.identity())
  end

  -- the sun's pass, sent the same way and for the same reason the scene
  -- shader sends it: the sampler is declared either way, and leaving one
  -- unbound is a driver-dependent crash rather than a fallback
  local map = ShadowMap.active()
  send("sunVP", "row", map and ShadowMap.uvVP or Mat4.identity())
  local tex = ShadowMap.texture()
  if not tex then
    -- GLES drivers are allowed to reject a draw with an unbound sampler even
    -- when sunDark makes its result irrelevant. Bind an existing harmless
    -- texture: the frame copy in FULL, or the sky ramp in SKY-only mode.
    tex = ctx.reflect or Sky.ramp()
  end
  if tex then send("sunMap", tex) end
  local Voxel3D = V.require("Voxel3D")
  send("sunDark", map and Voxel3D.SHADOW_ALPHA or 0)
  send("sunBias", ShadowMap.bias)
  local texel = 1 / ShadowMap.res
  send("sunTexel", { texel, texel })
  send("dayTint", Voxel3D.tint or { 1, 1, 1 })
  local fog=Voxel3D.fog
  send("fogColor", fog and fog.color or {0,0,0})
  send("fogBounds", fog and fog.bounds or {0,0,0,0})
  send("fogOrigin", fog and fog.origin or {0,0,0})
  send("fogInfo", fog and {fog.density or 0,fog.start or 0,fog.heightK or 0,fog.bounds and 2 or fog.origin and 1 or 0} or {0,0,0,0})

  -- the cast's planar reflection. The sampler is bound whatever happens --
  -- an unbound one is a driver-dependent crash, not a fallback -- so where
  -- there is no cast canvas this frame it borrows a texture that certainly
  -- exists and castOn switches the lookup off. Same shape as sunMap above.
  local castTex = ctx.cast
  send("castOn", castTex and 1 or 0)
  send("castAlpha", Water.CAST_ALPHA)
  send("castWobble", Water.CAST_WOBBLE)
  local castBound = castTex or ctx.reflect or Sky.ramp()
  if castBound then send("castTex", castBound) end

  if not skyOnly then send("rays", level >= 2 and 1 or 0) end
  send("waveHeight",V.require("NativeWaterSurface").HEIGHT)
  send("waveSlope",V.require("NativeWaterSurface").SLOPE)
  send("rippleT", rippleTime())
  send("fresnelFloor", Water.FRESNEL_FLOOR)
  send("fresnelCeil", Water.FRESNEL_CEIL)
  send("rayStep", Water.RAY_STEP)
  send("rayGrow", Water.RAY_GROW)
  send("rayThick", Water.RAY_THICK)
  send("edgeFade", Water.EDGE_FADE)

  if native or skyOnly then
    local ok,clouds=pcall(V.require,'Clouds')
    local reflected=ok and clouds.reflection and clouds.reflection()
    send('cloudAtlas',reflected and reflected.image or ctx.reflect or Sky.ramp())
    send('cloudOpacity',reflected and reflected.opacity or 0)
    if reflected then
      send('cloudSunlight',reflected.sunlight);send('cloudAmbient',reflected.ambient)
      send('cloudDirection',reflected.direction);send('cloudOvercast',reflected.overcast)
      send('cloudDrift',reflected.drift)
    end
  end
  Water.sendSky(sh, ctx)
  active = sh
  drawUniforms:begin(sh)
  return true
end

-- The sky half of the uniforms: the band ramp, and whatever hangs in it.
--
-- Split out because it is the part with a "there is none" answer -- indoors,
-- and on any frame whose ramp could not be built -- and that answer has to
-- leave every sampler bound anyway. skyOn 0 reflects the water's own colour
-- back at itself, which is what a pond in a cave does.
function Water.sendSky(sh, ctx)
  local function send(name, ...)
    pcall(sh.send, sh, name, ...)
  end
  local ramp, count = Sky.ramp()
  local edge = ctx.skyEdge
  if not (ramp and count and edge and edge > 0) then
    -- the sampler still has to hold something; the ramp is the only image
    -- this shader has for the job, so bind the frame copy and switch it off
    send("skyRamp", ctx.reflect)
    send("skyCount", 1)
    send("skyEdge", 1)
    send("skyOn", 0)
    send("bodyOn", 0)
    send("glowAmt", 0)
    return
  end
  send("skyRamp", ramp)
  send("skyCount", count)
  send("skyEdge", edge)
  send("skyOn", 1)

  local replaced = V.companion and V.companion.celestialWasReplaced and V.companion:celestialWasReplaced()
  local body = not replaced and DayNight.body() or nil
  if not body then
    send("bodyOn", 0)
    send("glowAmt", 0)
    return
  end
  local amt, glowColor = DayNight.glow()
  local h = ctx.screen[2]
  local cell = math.max(1, ctx.cell or 1)
  -- Sky sizes the disc in canvas pixels; out here the reflected body is
  -- usually off the top of the frame, where a pixel is not a unit any more
  -- -- so it is converted to the ANGLE it subtends through this camera's
  -- own field of view, which is the same number wherever it is looked at.
  local perRadian = h / math.max(1e-4, ctx.fov or 1)
  local rpx = Sky.discRadius(h, cell,
                             { moon = body.moon, glowAmt = amt })
  local shades = Sky.discShades(body.moon)
  local function shade(i)
    local c = shades[i] or shades[#shades] or { 255, 255, 255 }
    return { c[1] / 255, c[2] / 255, c[3] / 255 }
  end
  local twilight = (amt or 0) > 0.25 and not body.moon
  send("bodyOn", 1)
  send("bodyMoon", body.moon and 1 or 0)
  send("bodyDir", { body.dx, body.dy, body.dz })
  send("bodyAng", rpx / perRadian)
  send("bodyCore", shade(1))
  send("bodyMain", shade(twilight and 3 or 2))
  send("bodyDark", shade(3))
  send("glowAmt", (not body.moon) and (amt or 0) or 0)
  send("glowColor", glowColor
       and { glowColor[1] / 255, glowColor[2] / 255, glowColor[3] / 255 }
       or { 1, 0.88, 0.66 })
  send("glowReach", (ctx.screen[1] * Sky.GLOW_REACH) / perRadian)
end

-- Draw one water mesh with `model` applied. Mirrors Voxel3D.draw, minus the
-- camera-ward pull (a flat sheet has nothing to lean over) and the separate
-- sun transform (water is terrain: the sun saw the same matrix).
function Water.draw(mesh, texture, model, nativePalette)
  if not (active and mesh) then return end
  if texture then mesh:setTexture(texture) end
  drawUniforms:send('nativePalette',nativePalette or noPalette)
  local safariScale=V.require("SafariMaterials").texelScale(texture)
  local atlasScale=safariScale or V.require("DecorAtlas").texelScale(texture)
  local garden = atlasScale>1 and V.require("CommunityVisuals").customRoads()
  drawUniforms:send("reserveWater",safariScale and 1 or 0)
  -- Keep the existing tiny plant/pad clearance; normals remain full strength.
  drawUniforms:send("waveHeight",safariScale and .22 or garden and .12 or V.require("NativeWaterSurface").HEIGHT)
  drawUniforms:send("waveSlope",V.require("NativeWaterSurface").SLOPE)
  drawUniforms:send("gardenWater",(safariScale or garden) and 1 or 0)
  drawUniforms:send("model",model or identity,true)
  love.graphics.draw(mesh)
end

function Water.finish()
  activeNative=false
  active = nil
end

-- Drop the compiled shaders (window resize, hot reload): they are GPU
-- objects on a context that may not exist any more.
function Water.invalidate()
  for _, family in pairs(shaders) do
    for k, sh in pairs(family) do
      if sh and sh.release then pcall(sh.release, sh) end
      family[k] = nil
    end
  end
  activeNative=false
  active = nil
end

return Water
