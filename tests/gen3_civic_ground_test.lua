local edition='emerald'
package.loaded['src.core.GameVersion']={get=function()return edition end}
local modules={BuildBudget={tick=function()end,check=function()end}}
local V={data=function(n)return dofile('data/'..n..'.lua')end}
function V.require(n)
 if modules[n]then return modules[n]end
 if n=='SceneryModels'then return{}end
 local m=assert(loadfile('lib/'..n..'.lua'))(V);modules[n]=m;return m
end
local H=V.require('Gen3Hoenn');local Civic=V.require('Gen3Civic')
local nativeRecipes=H.exteriorRecipes
H.exteriorRecipes=function()local r,seen={},{};for _,a in ipairs(nativeRecipes())do r[#r+1]=a;seen[a.name]=true end;for _,a in ipairs(V.require('Gen3ImportedHoenn').recipes)do if not seen[a.name]then r[#r+1]=a end end;return r end
local rural={littleroot_player_house=true,littleroot_rival_house=true,birch_lab=true,oldale_house=true,oldale_mart=true,oldale_center=true,petalburg_city_mart=true,petalburg_city_center=true,petalburg_city_gym=true,petalburg_city_wide_home=true,petalburg_city_home=true,route104_briney_house=true,route104_pretty_petal_shop=true}
local urban={rustboro_small_tan=true,rustboro_wide_tan=true,rustboro_east_tan=true,rustboro_south_tan=true,rustboro_white_small=true,rustboro_white_tall=true,rustboro_white_thin=true,rustboro_devon_corporation=true,rustboro_city_center=true,rustboro_city_mart=true,rustboro_city_gym=true}
local coastal={dewford_town_home=true,dewford_town_south_home=true,dewford_town_hall=true,dewford_town_center=true}
local cleanHeaders={oldale_center=4,oldale_mart=3,petalburg_city_center=4,rustboro_city_center=4,rustboro_city_mart=4,dewford_town_home=2,dewford_town_south_home=4,dewford_town_center=4}
local function fixture(r)
 local cells={};local h,w=#r.rows,#r.rows[1]
 local door=1;for _,o in ipairs(r.openings or{})do if o.door then door=math.floor((o[1]+o[3])/32);break end end
 for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  local coll=r.permissions and r.permissions[y][x]or(y==1 and 0 or y==h and x==door+1 and 0x71 or 7)
  if r.blockedStart and y>r.blockedStart and not(y==h and mid==r.nativeDoorMid)then coll=7 end
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,pair=r.pair,primary='general',mid=mid,collision=coll,base=0,shape={kind='flat'},ts={layered=true}}
 end end
 -- Actual failure categories: grass/path edges and Rustboro lamp artwork all
 -- have flat, walkable copies. They cannot define a complete building's floor.
 for y=-2,h+1 do for x=-2,w+1 do local key=x..':'..y
  if not cells[key]then cells[key]={cx=x,cy=y,pair=r.pair,primary='general',mid=(x%2==0 and 0x212 or 0x119),collision=0,shape={kind='flat',reviewedSurface=true}}end
 end end
 return cells
end
local checked=0
for _,ed in ipairs{'emerald','ruby','sapphire'}do
 edition=ed;local families=H.exteriorRecipes();local seen={}
 for _,r in ipairs(families)do if rural[r.name]or urban[r.name]or coastal[r.name]then
  seen[r.name]=true;local cells=fixture(r);local before={};for k,c in pairs(cells)do before[k]={c.mid,c.collision,c.base,c.shape}end
  local out=Civic.prepare(cells,{},{});assert(#out==1,r.name..' native drawing did not match')
  local g=out[1];local expected=rural[r.name]and 1 or coastal[r.name]and 0x124 or 0x2bb
  assert(g.sourceGround==expected,r.name..' source family fell back to proximity')
  for _,c in pairs(cells)do
   if c.civic then local clean=c.cy==0 and c.cx<(cleanHeaders[r.name]or 0);local want=(clean or g.custom.preserveWalkableFloor and c.collision==0)and c.mid or expected;assert(Civic.ground(c)==want,r.name..' lost clean source underlay or copied decorative/body artwork');assert(Civic.underOnly(c)==clean,r.name..' roof-header floor must draw under atlas exactly once')end
  end
  -- Existing explicit overrides and preserved native floor cells retain priority.
  local c=cells['0:0'];local custom=g.custom;local savedGround=custom.ground
  custom.ground=0x170;assert(Civic.ground(c)==0x170 and not Civic.underOnly(c),'explicit water/underlay override lost');custom.ground=savedGround
  local savedPreserve=custom.groundPreserve;custom.groundPreserve={{0,0}};assert(Civic.ground(c)==c.mid,'source-preserved cell repainted');custom.groundPreserve=savedPreserve
  local preserve=custom.preserveWalkableFloor;custom.preserveWalkableFloor=true;custom.ground=nil;c.collision=0;assert(Civic.ground(c)==c.mid,'walkable source floor lost');custom.preserveWalkableFloor=preserve;custom.ground=savedGround;c.collision=before['0:0'][2]
  for k,c in pairs(cells)do local b=before[k];assert(c.mid==b[1]and c.collision==b[2]and c.base==b[3]and c.shape==b[4],'native terrain/permission/shape changed')end
  checked=checked+1
 end end
 for name in pairs(rural)do assert(seen[name],ed..' missing rural family '..name)end
 for name in pairs(urban)do assert(seen[name],ed..' missing urban family '..name)end
 -- Oldale's light path wraps behind its Center; the original building lawn is
 -- still dark General001 even when every available neighbor is path artwork.
 for _,r in ipairs(families)do if r.name=='oldale_center'then
  local cells=fixture(r);local path={0x1d0,0x1d8,0x1d9,0x1e0,0x1e1};local n=0
  for _,c in pairs(cells)do if c.cx<0 or c.cy<0 or c.cx>=#r.rows[1]or c.cy>=#r.rows then n=n+1;c.mid=path[n%#path+1]end end
  assert(#Civic.prepare(cells,{},{})==1)
  for _,c in pairs(cells)do if c.civic then assert(Civic.ground(c)==(c.cy==0 and c.mid or 1),'Oldale source overhang/background or native body lawn lost')end end
  assert(Civic.ground(cells['2:0'])==0x282 and Civic.ground(cells['3:0'])==0x283,'original light path beneath roof overhang lost')
  -- A flat composite atlas includes the roof itself, so source MID reuse must
  -- stand down when the public native under/over split is unavailable.
  cells=fixture(r);for _,c in pairs(cells)do c.ts={layered=false}end
  assert(#Civic.prepare(cells,{},{})==1)
  assert(Civic.ground(cells['2:0'])==1,'flat roof artwork projected onto floor')
  assert(not Civic.underOnly(cells['2:0']),'flat atlas accepted as clean source under layer')
  -- Reusing a known label/corner with different header art is not source proof.
  local changed={};for k,v in pairs(r)do changed[k]=v end;changed.rows={};for y,row in ipairs(r.rows)do changed.rows[y]={unpack(row)}end;changed.rows[1][3]=0x61
  local altered=fixture(changed);local Plain=assert(loadfile('lib/Gen3Civic.lua'))()
  local out=Plain.prepare(altered,{}, {changed});assert(#out==1 and Civic.ground(altered['2:0'])==1,'body pixels accepted as clean header')
 end end
end
assert(not Civic.underOnly(nil)and not Civic.underOnly({}),'unknown cells entered under-only batch')
-- Unknown/cross-edition/falsely named drawings keep their previous fallback.
local Plain=assert(loadfile('lib/Gen3Civic.lua'))()
local function unknown(name,pair,family,rows)
 local r={name=name,pair=pair,family=family,centerRoof=true,kind='center',header=#rows,rows=rows};local cells=fixture(r)
 local out=Plain.prepare(cells,{}, {r});assert(#out==1 and not out[1].sourceGround)
 assert(Civic.ground(cells['0:0'])==0x212,'unknown fallback changed')
end
unknown('unknown_center','general__petalburg','rse',{{900,901},{902,903}})
unknown('oldale_center','general__other','rse',{{900,901},{902,903}})
unknown('oldale_center','general__petalburg','frlg',{{900,901},{902,903}})
unknown('oldale_center','general__petalburg','rse',{{900,901},{902,903}})
local g={cx=0,cy=0,variant='saffron',custom={}};assert(Plain.ground({cx=0,cy=0,civic=g,mid=999})==0x2e5)
g.variant=nil;assert(Plain.ground({cx=0,cy=0,civic=g,mid=999})==1)
-- The corridor's routes/woods without Civic drawings must remain untouched.
local terrain={};for y=0,3 do for x=0,3 do terrain[x..':'..y]={cx=x,cy=y,pair='general__petalburg',primary='general',mid=1,collision=0,shape={kind='flat'}}end end
assert(#Civic.prepare(terrain,{},{})==0);for _,c in pairs(terrain)do assert(not c.civic and c.mid==1 and c.collision==0)end
print('PASS '..checked..' R/S/E corridor source-family underlays, shared-pair Route104 lawn/Rustboro paving, native overrides/warp permissions and unknown/art-identity fallback')
