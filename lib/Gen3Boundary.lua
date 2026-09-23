-- Extend each FireRed perimeter from its own native scenery. Connected maps
-- remain authoritative; this adapter only receives the engine's void fallback.
local V=...
local Select=V.require('BoundaryScenery')
local Shapes=V.require('Gen3TileShape')
local Pairs=V.require('Gen3Tilesets')
local Versions=require('src.import.gba.versions')
local Collision=require('src.core.game3.collision')
local M={}
local key,regions
function M.regions(def,world)
 local parts={tostring(def),tostring(def.midLayout)}
 for _,e in ipairs(world or {})do parts[#parts+1]=table.concat({e.id or '',e.ox,e.oy,tostring(e.def.midLayout)},':')end
 local nextKey=table.concat(parts,';')
 if nextKey==key then return regions end
 key=nextKey;regions={}
 local function add(d,x,y)
  local L=d.midLayout
  if L then regions[#regions+1]={def=d,x=x,y=y,w=L.width,h=L.height}end
 end
 add(def,0,0)
 for _,e in ipairs(world or {})do add(e.def,e.ox,e.oy)end
 return regions
end
local function sample(r,x,y)
 local L=r.def.midLayout;local mid=L:midAt(x,y);local pair=L.pair
 local spec=Pairs.resolve(pair,Versions.TILESET_PAIRS)
 if not spec then return end
 local shape=Shapes.of(spec.primary,spec.secondary,mid)
 local kind=shape.kind
 local biome=kind=='tree' and 'forest' or kind=='cliff' and 'mountain'
 if Collision.isSurfable(Collision.behaviorOn(r.def,x,y))then biome='water'end
 return {mid=mid,pair=pair,biome=biome,primary=spec.primary,secondary=spec.secondary,shape=shape}
end
function M.resolve(rs,x,y)
 local donor,real=Select.resolve(rs,x,y,sample)
 if real or not donor or donor.primary~='general' then return end
 if donor.biome=='forest' then
  local source=donor.shape;local spacing=source.spacing or 2
  return donor.mid,donor.pair,{kind='tree',ground=source.ground or 1,root=x%spacing==0 and y%spacing==0,
   spacing=source.spacing,anchorX=source.anchorX,anchorZ=source.anchorZ,treeScale=source.treeScale},'forest'
 elseif donor.biome=='mountain' then
  return 113,donor.pair,{kind='cliff',height=32,ground=1},'mountain'
 elseif donor.biome=='water' then
  return donor.mid,donor.pair,{kind='water',reviewedSurface=true},'water'
 end
 -- Never propagate a facade, decoration or door into the void.
 return 1,donor.pair,{kind='flat',reviewedSurface=true},'ground'
end
function M.clear()key,regions=nil,nil end
return M
