-- Shared release material on the original GBA twelve-frame reveal. Native
-- transforms already live in the cards: never grow/deform that picture twice.
local V=...
local M={}
local held={}
local function discard(id)
 local e=held[id]
 if e and e.mesh then pcall(e.mesh.release,e.mesh)end
 held[id]=nil
end
function M.clear()
 for id in pairs(held)do discard(id)end
end
function M.prepare(frame)
 frame.releasePose=nil;frame.releasePoses=nil;frame.releaseById=nil
 local st=frame.st
 if not st or st.legendaryModelRelease
  or not V.require('Gen3Battle').enabled() or not V.require('PokeballSettings').active()
  or require('src.core.game3.battle.catch_seq').busy() then M.clear();return end
 local Anim=require('src.core.game3.battle.anim')
 local selected,ambiguous
 for _,card in ipairs(frame.cards or{})do
  if card.ball then
   local ok,s,b=pcall(V.require('NativeGen3SendoutShell').shell,st,card)
   local id=b and b.battler
   if ok and s and b and type(id)=='number'and id>=0 and id<=3 and id%1==0
    and Anim.stage().balls and Anim.stage().balls[b.battler]==b then
    selected=selected or{}
    if selected[id]then ambiguous=ambiguous or{};ambiguous[id]=true else selected[id]={native=b,shell=s}end
   end
  end
 end
 if not selected then M.clear();return end
 frame.releasePoses={};frame.releaseById={}
 local Release=V.require('q57/Release')
 for id=0,3 do
  local entry=selected[id];local b=entry and entry.native;local p=b and Anim.present(id)
  local point,anchor,card=frame.points[id],frame.native[id],frame.byId[id]
  local scale=p and tonumber(p.scale);local pose
  if b and not(ambiguous and ambiguous[id])and b.frame>0 and p and p.visible and scale and scale>=.16 and scale<1
   and point and anchor and card then
   local shell=entry.shell
   local source={point[1],point[2]+(anchor.foot-anchor.y)*frame.PIXEL,point[3]}
   pose=Release.pose((scale-.16)/.84*Release.DURATION,source,{shell:mouth()},16,16,shell.yaw,'battle')
  end
  if pose then
   if not held[id]or held[id].owner~=st or held[id].native~=b then discard(id);held[id]={owner=st,native=b,id=id}end
   local e=held[id];e.pose=pose;e.failed=false;frame.releaseById[id]=e;frame.releasePoses[#frame.releasePoses+1]=e
  else discard(id)end
 end
 if #frame.releasePoses==1 then frame.releasePose=frame.releasePoses[1]end
end
local function draw(e)
 e.failed=false
 local p=e and e.pose
 if not p or p.pull>=.995 or p.fade<=.001 then return false end
 local Plasma=V.require('q57/Plasma')
 if not e.vertices then e.vertices,e.indices=Plasma.newGeometry()end
 Plasma.update(e.vertices,p)
 local R=V.require('Voxel3D')
 local ok=pcall(function()
  if not e.mesh then e.mesh=R.newMesh(e.vertices,e.indices)else e.mesh:setVertices(e.vertices)end
 end)
 if not ok or not e.mesh then e.failed=true;return false end
 local painted=V.require('q57/Material').draw(R,e.mesh,nil,nil,0,p,false)==true
 e.failed=not painted;return painted
end
function M.draw(frame)
 local any=false
 for _,e in ipairs(frame.releasePoses or{})do if draw(e)then any=true end end
 return any
end
function M.subject(frame,card,mesh)
 local e=frame.releaseById and frame.releaseById[card.id]
 if not e or e.failed or card.id~=e.id or e.pose.pull>=.995 then return false end
 return V.require('q57/Material').draw(V.require('Voxel3D'),mesh,card.tex,card.model,0,e.pose,true)
end
return M
