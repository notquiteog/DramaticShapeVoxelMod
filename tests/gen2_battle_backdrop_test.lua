-- Native identity/provenance routing, including the unchanged Gen1 path.
local gen, clock, checks = 2, 'day', 0
local function eq(a,b,msg) checks=checks+1;assert(a==b,msg..': '..tostring(a)) end
package.loaded['src.world.Map']={isOutdoor=function(d)return d.outdoor or d.environment=='ROUTE' or d.environment=='TOWN' end}
package.loaded['src.battle.gen2.Battle']={BATTLETYPE_FISH=4}
package.loaded['src.world.gen2.FieldMoves']={isSurfing=function(state)return state=='SURF'or state=='SURF_PIKA'end}
local cache={}
local V={data=function(n)return dofile('data/'..n..'.lua')end}
cache.Generation={isGen2=function()return gen==2 end}
cache.DayNight={time=function()return 12 end,mix=function()return {[clock]=1}end}
cache.BackdropImage={load=function(_,file)return file end}
cache.BattleArt={speciesFor=function(mon)return mon and mon.mon and mon.mon.species end}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local G,B,N=V.require('Gen6Backdrop'),V.require('BossBackdrop'),V.require('Gen2BattleBackdrop')
for _,version in ipairs({'gold','silver','crystal'})do
 local native={wild=false,trainer={classId='BROCK'}}
 eq(B.fileFor('PEWTER_GYM',native),'pewtergym.jpg',version..' native trainer class')
 eq(B.fileFor('PEWTER_GYM',{battle=native}),'pewtergym.jpg',version..' native screen')
 eq(B.fileFor('ROUTE_2',native),nil,version..' trainer outside canonical gym')
 eq(B.fileFor('PEWTER_GYM',{trainer={classId=1}}),nil,version..' unknown numeric class')
 eq(B.fileFor('PEWTER_GYM',{battle=native,link=true}),nil,version..' link identity')
 eq(B.fileFor('VERMILION_GYM',{trainer={classId='LT_SURGE'}}),'vermiliongym.jpg',version..' native underscore class')
 eq(B.fileFor('FUCHSIA_GYM',{trainer={classId='JANINE'}}),nil,version..' new leader cannot borrow Koga art')
 eq(N.surfing({playerState='SURF',player={}}),true,version..' native surf state')
 eq(N.surfing({playerState='SURF_PIKA',player={}}),true,version..' native Pikachu surf state')
 eq(N.surfing({playerState='BIKE',player={}}),false,version..' bike is not surf')
 eq(N.surfing({playerState='NORMAL',player={surfing=true}}),false,version..' stale compatibility field cannot override native state')
 local water={dramaticShapeSurfing=N.surfing({playerState='SURF'})}
 eq(G.setFor({id='ROUTE_40',def={environment='ROUTE'}},water),'shore',version..' native water routing')
 eq(G.setFor({id='ROUTE_20',def={environment='ROUTE'}},water),'ocean',version..' Kanto ocean routing')
 eq(G.setFor({id='UNKNOWN_CAVE',def={environment='CAVE'}},water),nil,version..' indoor surf fallback')
 local fish={wild=true,battleType=4}
 eq(G.setFor({id='ROUTE_32',def={environment='ROUTE'}},fish),'safariwater',version..' native fishing')
 eq(G.setFor({id='ROUTE_32',def={environment='ROUTE'}},{battle=fish}),'safariwater',version..' screen fish')
 eq(G.setFor({id='UNKNOWN_CAVE',def={environment='CAVE'}},fish),nil,version..' indoor fishing fallback')
 eq(G.setFor({id='ROUTE_32',def={environment='ROUTE'}},{wild=true,battleType=0}),'grassy',version..' ordinary outdoor')
 eq(G.setFor({id='ROUTE_19',def={environment='ROUTE'}},fish),'route19',version..' fishing location priority')
 eq(N.species({wild=true,enemy={species=145}}),'ZAPDOS',version..' native numeric species')
 eq(N.species({wild=false,enemy={species=145}}),nil,version..' trainer mon not a static encounter')
 eq(N.species({wild=true,enemy={species=999}}),nil,version..' unsupported species')
 clock='night';eq(G.fileFor({id='ROUTE_32',def={environment='ROUTE'}},nil,native),'grassynight.jpg',version..' frozen clock')
 clock='day';eq(G.fileFor({id='ROUTE_32',def={environment='ROUTE'}},nil,native),'grassynight.jpg',version..' clock remains frozen')
 eq(native.oppClass,nil,version..' no native core mutation')
end
gen=1
eq(N.surfing({playerState='SURF'}),false,'Gen1 native-looking state ignored')
eq(B.fileFor('PEWTER_GYM',{oppClass='OPP_BROCK'}),'pewtergym.jpg','Gen1 boss unchanged')
eq(B.fileFor('POWER_PLANT',{enemy={mon={species='ZAPDOS'}}}),'zapdos.jpg','Gen1 species unchanged')
eq(G.setFor({id='ROUTE_32',def={outdoor=true}},{wild=true,battleType=4}),'grassy','Gen1 native-looking type ignored')
eq(G.setFor({id='ROUTE_32',def={outdoor=true}},{dramaticShapeFishing=true}),'safariwater','Gen1 hook retained')
print('PASS '..checks..' native backdrop routing checks')
