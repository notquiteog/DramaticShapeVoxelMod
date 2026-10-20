-- Soft, normal-lit cumulus. One immutable atlas and one batch replace the
-- embedded sky's three stippled decks. No scene depth, actors or RNG ownership.
local V=...
local M={revision=1,status='not drawn',stats={draws=0,vertices=0,textureBytes=0}}
local R=V.require('Voxel3D')
local Day=V.require('DayNight')
local Weather=V.require('Weather')
local image,mesh,shader,failed
local FORMAT={{'VertexPosition','float',3}}
-- Shared verbatim with the water sky reflection: one material, direction,
-- palette and wind phase rather than a second procedural cloud simulation.
M.glsl=[[
uniform Image cloudAtlas;
uniform vec3 cloudSunlight;
uniform vec3 cloudAmbient;
uniform vec3 cloudDirection;
uniform float cloudOpacity;
uniform float cloudOvercast;
uniform float cloudDrift;
vec4 cloudAt(vec3 direction){
 if(cloudOpacity<.001||direction.y<=0.)return vec4(0.);
 vec3 d=normalize(direction);
 vec2 uv=vec2(fract(atan(d.x,d.z)/6.28318530718+.5-cloudDrift/6.28318530718),
              (1.-asin(clamp(d.y,0.,1.))/.5/3.14159265359)*.5);
 vec4 tex=Texel(cloudAtlas,uv);
 if(cloudOvercast>.001){
  vec4 extra=Texel(cloudAtlas,uv+vec2(0.,.5))*cloudOvercast;
  tex=extra+tex*(1.-extra.a);
 }
 float a=tex.a*cloudOpacity;
 if(a<.002)return vec4(0.);
 vec3 n=normalize(tex.rgb/max(tex.a,.00001)*2.-1.);
 float c=cos(cloudDrift),s=sin(cloudDrift);
 n=vec3(c*n.x+s*n.z,n.y,-s*n.x+c*n.z);
 float diffuse=clamp(dot(n,cloudDirection)*.65+.35,0.,1.);
 return vec4(mix(cloudAmbient,cloudSunlight,.25+.75*diffuse),a);
}
]]
M.source=[[
uniform mat4 vp;
uniform vec3 origin;
varying LOVE_HIGHP_OR_MEDIUMP vec3 cloudRay;
#ifdef VERTEX
vec4 position(mat4 unused,vec4 p){
 cloudRay=p.xyz;vec4 clip=vp*vec4(p.xyz+origin,1.);
 if(clip.w>0.)clip.z=min(clip.z,clip.w*.99999);
 return clip;
}
#endif
#ifdef PIXEL
]]..M.glsl..[[
vec4 effect(vec4 color,Image tex,vec2 uv,vec2 px){
 vec4 cloud=cloudAt(cloudRay);if(cloud.a<.002)discard;return cloud*color;
}
#endif
]]
local function smooth(a,b,x)local t=math.max(0,math.min(1,(x-a)/(b-a)));return t*t*(3-2*t)end
local lobes={
 {0,.20,.94,.33,.35},{-.31,-.08,.43,.62,.72},{.24,-.15,.43,.68,.78},
 {-.62,.16,.30,.39,.46},{.62,.18,.30,.40,.43},{-.04,-.43,.31,.39,.62},
}
-- Pure deterministic material seam. Varied silhouettes retain round crowns with
-- gently eroded edges; RGBA holds a normal and smooth optical coverage.
function M.texel(x,y,variant)
 local sum,gx,gy,edge=0,0,0,-1
 local phase=(variant or 0)*1.73
 for i,l in ipairs(lobes)do
  local cx=l[1]+math.sin(phase+i*2.3)*.09;local cy=l[2]+math.cos(phase+i)*.07
  local sx=l[3]*(.86+.20*math.sin(phase+i*1.9));local sy=l[4]*(.90+.17*math.cos(phase+i*2.7))
  local dx,dy=(x-cx)/sx,(y-cy)/sy;local q=1-dx*dx-dy*dy
  edge=math.max(edge,q)
  if q>0 then
   local h=math.sqrt(q)*l[5];local h3=h*h*h
   sum=sum+h3*h
   gx=gx-h3*l[5]*dx/(sx*math.sqrt(q))
   gy=gy-h3*l[5]*dy/(sy*math.sqrt(q))
  end
 end
 if sum<1e-9 then return .5,.5,1,0 end
 local h=sum^.25;local denom=math.max(.02,h*h*h)
 local nx,ny=-gx/denom*.45,gy/denom*.45
 local length=math.sqrt(nx*nx+ny*ny+1)
 local erosion=(math.sin(x*43+math.sin(y*23+phase))*math.cos(y*37+phase))*.014
 local alpha=smooth(0,.105,edge+erosion)*math.min(1,h*3.4)
 return nx/length*.5+.5,ny/length*.5+.5,1/length*.5+.5,alpha*.94
end
function M.field(width,height,set,get)
 -- Rasterize only the small spherical rectangles occupied by each cluster.
 -- Texture U repeats over the longitude seam; both latitude rims are clear.
 for i=0,35 do
  local extra=i>=24
  local ring=math.floor(i/12);local az=(i%12)*math.pi/6+ring*.39+math.sin(i*2.399)*.16
  local elevation=math.rad(18+ring*17+math.sin(i*1.713)*7)
  local radius=1750+math.sin(i*3.17)*210
  local fx,fy,fz=-math.sin(az)*math.cos(elevation),-math.sin(elevation),-math.cos(az)*math.cos(elevation)
  local rx,rz=math.cos(az),-math.sin(az)
  local ux,uy,uz=-fy*rz,fx*rz-fz*rx,fy*rx
  local w=275+math.sin(i*1.97)*95;local h=145+math.cos(i*2.31)*44
  local cx=(az/(math.pi*2)+.5)*width;local cy=(1-elevation/(math.pi/2))*height
  local sx=math.atan(w/radius)/math.cos(elevation)/(math.pi*2)*width
  local sy=math.atan(h/radius)/(math.pi/2)*height
  local offset=extra and height or 0
  for y=math.max(0,math.floor(cy-sy)),math.min(height-1,math.ceil(cy+sy))do
   for x=math.floor(cx-sx),math.ceil(cx+sx)do
    local nr,ng,nb,a=M.texel((x+.5-cx)/sx,(y+.5-cy)/sy,i%11)
    if a>0 then
     local nx,ny,nz=nr*2-1,ng*2-1,nb*2-1
     local r,g,b=(rx*nx+ux*ny+fx*nz)*.5+.5,(uy*ny+fy*nz)*.5+.5,(rz*nx+uz*ny+fz*nz)*.5+.5
     local xx,yy=x%width,y+offset;local pr,pg,pb,pa=get(xx,yy);local alpha=a+pa*(1-a)
     -- Premultiplied encoded normals keep bilinear silhouettes free of a
     -- dark fringe from the clear texels around each cloud.
     set(xx,yy,r*a+pr*(1-a),g*a+pg*(1-a),b*a+pb*(1-a),alpha)
    end
   end
  end
 end
end
function M.geometry()
 local vertices={};local function point(a,e)return{math.sin(a)*math.cos(e)*3200,math.sin(e)*3200,math.cos(a)*math.cos(e)*3200}end
 for row=0,7 do for col=0,23 do
  local a,b=col*math.pi/12,(col+1)*math.pi/12;local e,f=row*math.pi/16,(row+1)*math.pi/16
  local p,q,r,s=point(a,e),point(b,e),point(b,f),point(a,f)
  for _,v in ipairs{p,q,r,p,r,s}do vertices[#vertices+1]=v end
 end end
 return vertices
end
function M.parameters(map)
 local mix=Day.mix(Day.time());local night=math.min(1,(mix.night or 0)+(mix.violet or 0)*.8)
 local warm=math.min(1,(mix.dusk or 0)+(mix.dawn or 0)+(mix.golden or 0)*.35)
 local mode=Weather.mode(map);local storm=mode=='storm'and 1 or mode=='rain'and .65 or mode=='snow'and .4 or 0
 local light,ambient={1,.985,.95},{.56,.65,.78}
 for i,v in ipairs{{1,.67,.43},{.37,.34,.49}}do local dst=i==1 and light or ambient;for ch=1,3 do dst[ch]=dst[ch]*(1-warm)+v[ch]*warm end end
 for i,v in ipairs{{.43,.49,.66},{.08,.12,.22}}do local dst=i==1 and light or ambient;for ch=1,3 do dst[ch]=dst[ch]*(1-night)+v[ch]*night end end
 for ch=1,3 do light[ch]=light[ch]*(1-storm*.48);ambient[ch]=ambient[ch]*(1-storm*.36)end
 local body=Day.body();local direction=body and{body.dx,body.dy,body.dz}or{.3,.6,-.7}
 return{light=light,ambient=ambient,direction=direction,opacity=(.88-night*.36)*(mode=='fog'and .5 or 1),overcast=storm,
  drift=(Weather.clock or 0)*.0008,mode=mode}
end
local function resources()
 if failed then return false end
 if image and mesh and shader then return true end
 local data
 local ok,err=pcall(function()
  shader=love.graphics.newShader(M.source)
  local width,height=1024,256
  local okPlatform,Platform=pcall(require,'src.core.Platform');local caps=okPlatform and Platform.detect and Platform.detect()or{}
  if caps.mobile or caps.console or caps.nx then width,height=512,128 end
  data=love.image.newImageData(width,height*2)
  M.field(width,height,function(...)data:setPixel(...)end,function(...)return data:getPixel(...)end)
  image=love.graphics.newImage(data,{linear=true});image:setFilter('linear','linear');image:setWrap('repeat','clamp')
  mesh=love.graphics.newMesh(FORMAT,M.geometry(),'triangles','static');mesh:setTexture(image)
  M.stats.textureBytes=width*height*8
 end)
 if data then data:release()end
 if not ok then M.invalidate();failed=true;M.status='unavailable: '..tostring(err);return false end
 M.stats.vertices=1152;return true
end
function M.draw(state)
 M.stats.draws=0
 local map=state and state.map
 if not map or not Weather.isOutdoor(map)or not R.vp then return false end
 if not resources()then return false end
 local g=love.graphics;local p=state.player or{};local values=M.parameters(map)
 local pushed=false
 local ok,err=pcall(function()
  g.push('all');pushed=true;g.setShader(shader);g.setColor(1,1,1,1)
  g.setBlendMode('alpha','alphamultiply');g.setDepthMode('lequal',false)
  shader:send('vp','row',R.vp);shader:send('origin',{(p.px or 0)+8,0,(p.py or 0)+8})
  shader:send('cloudAtlas',image);shader:send('cloudDrift',values.drift);shader:send('cloudSunlight',values.light);shader:send('cloudAmbient',values.ambient)
  shader:send('cloudDirection',values.direction);shader:send('cloudOpacity',values.opacity);shader:send('cloudOvercast',values.overcast)
  g.draw(mesh);M.stats.draws=1
 end)
 if pushed then g.pop()end
 M.status=ok and('cumulus: one batch, '..values.mode)or('draw unavailable: '..tostring(err))
 if ok then M.activeVP=R.vp;M.last=values end
 return ok
end
function M.reflection()
 if not(image and M.activeVP==R.vp and M.last)then return nil end
 local p=M.last
 return{image=image,sunlight=p.light,ambient=p.ambient,direction=p.direction,opacity=p.opacity,overcast=p.overcast,drift=p.drift}
end
function M.clear()M.activeVP=nil;M.last=nil;M.stats.draws=0 end
function M.invalidate()
 for _,v in pairs{image,mesh,shader}do if v and v.release then pcall(v.release,v)end end
 image,mesh,shader,failed=nil,nil,nil,nil;M.activeVP=nil;M.last=nil;M.stats.draws=0;M.stats.vertices=0;M.stats.textureBytes=0
end
return M
