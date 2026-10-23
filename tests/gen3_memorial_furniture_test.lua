local V={};local modules={};local edition='emerald'
package.loaded['src.core.GameVersion']={get=function()return edition end}
function V.require(name)if not modules[name]then modules[name]=assert(loadfile('lib/'..name..'.lua'))(V)end;return modules[name]end
local F=V.require('Gen3Furniture')
for _,ed in ipairs{'emerald','ruby','sapphire','firered','leafgreen'}do edition=ed
 for _,mid in ipairs{0x2ee,0x326}do
  local function cells(pair,collision,primary)
   return{['2:4']={cx=2,cy=4,mid=mid,collision=collision,primary=primary or'general',pair=pair,secondary='facility',ts={}}}
  end
  local c=cells('general__facility',7);local ps=F.extract(c)
  if ed=='firered'or ed=='leafgreen'then assert(#ps==0,'Hoenn art leaked into Kanto edition')
  else
   assert(#ps==1 and ps[1].cx==2 and ps[1].cy==4)
   local r=ps[1].recipe;assert(r.family=='rse'and r.rows[1][1]==mid and r.ground==(mid==0x326 and 0x2e7 or 0x2e6))
   assert(r.name==(ed=='emerald'and'hoenn_pyre_memorial'or'rs_pyre_memorial')..(mid==0x326 and'_wall_shadow'or''))
   assert(c['2:4'].mid==mid and c['2:4'].collision==7 and c['2:4'].prop==ps[1])
  end
  for _,collision in ipairs{0,43,114}do assert(#F.extract(cells('general__facility',collision))==0,'walkable/native opening claimed')end
  assert(#F.extract(cells('general__inside_ship',7))==0,'numeric alias claimed in another pair')
  assert(#F.extract(cells('general__facility',7,'building'))==0,'unreviewed primary art claimed')
 end
end
print('PASS exact RSE common/shadow grave art, original floor variants, edition isolation and native walking/opening guards')
