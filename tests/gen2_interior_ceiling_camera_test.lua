-- A hidden player alone is not proof that a third-person boom collapsed.
local fp,selected,shows,broken=false,false,false,false
local draws=0
love={image={newImageData=function()return {setPixel=function()end,release=function()end}end},
 graphics={newImage=function()return {setFilter=function()end}end}}
local V={require=function(n)
 if n=='FirstPerson' then return {engaged=function()return fp end}end
 if n=='ThirdPerson' then return {
  selected=function()if broken then error('no camera')end;return selected end,
  showsPlayer=function()return shows end}end
 if n=='Structures' then return {forMap=function()return {furniture={}}end}end
 if n=='Voxel3D' then return {newMesh=function()return {}end,draw=function()draws=draws+1 end}end
 error(n)
end}
local Shell=assert(loadfile('lib/Gen2InteriorShell.lua'))(V)
local map={def={environment='DUNGEON',width=15,height=18}}
Shell.draw(map);assert(draws==0,'static overview hidden behind enclosure lid')
fp=true;Shell.draw(map);assert(draws==1,'first person lost its ceiling')
fp=false;selected=true;shows=true;Shell.draw(map);assert(draws==1,'extended orbit hidden by lid')
shows=false;Shell.draw(map);assert(draws==2,'collapsed third person lost its ceiling')
selected=false;Shell.draw(map);assert(draws==2,'return to overview left ceiling enabled')
broken=true;Shell.draw(map);assert(draws==2,'unavailable camera should not add enclosure')
print('PASS Gen2 ceiling: open overview/orbit, enclosed first-person/collapsed boom')
