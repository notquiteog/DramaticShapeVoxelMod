-- Shared release material on the original GBA twelve-frame reveal. Native
-- transforms already live in the cards: never grow/deform that picture twice.
local V=...
local M={}
local held
function M.clear()
 if held and held.mesh then pcall(held.mesh.release,held.mesh) end
 held=nil
end
function M.prepare(frame)
 frame.releasePose=nil
 local st=frame.st
 if not st or st.double or st.legendaryModelRelease
  or not V.require('Gen3Battle').enabled() or not V.require('PokeballSettings').active()
  or require('src.core.game3.battle.catch_seq').busy() then M.clear();return end
 local Anim=require('src.core.game3.battle.anim')
 local selected,shell
 for _,card in ipairs(frame.cards or{})do
  if card.ball then
   local ok,s,b=pcall(V.require('NativeGen3SendoutShell').shell,st,card)
   if ok and s and b and (b.battler==0 or b.battler==1)
    and Anim.stage().balls and Anim.stage().balls[b.battler]==b then
    if selected then M.clear();return end
    selected,shell=b,s
   end
  end
 end
 local id=selected and selected.battler
 local p=id and Anim.present(id)
 local point=id and frame.points[id]
 local anchor=id and frame.native[id]
 local card=id and frame.byId[id]
 local scale=p and tonumber(p.scale)
 if not(selected and selected.frame>0 and p and p.visible and scale and scale>=.16 and scale<1
  and point and anchor and card)then M.clear();return end
 if not held or held.owner~=st or held.native~=selected then
  M.clear();held={owner=st,native=selected}
 end
 local Release=V.require('q57/Release')
 local source={point[1],point[2]+(anchor.foot-anchor.y)*frame.PIXEL,point[3]}
 local pose=Release.pose((scale-.16)/.84*Release.DURATION,source,{shell:mouth()},16,16,shell.yaw,'battle')
 if not pose then M.clear();return end
 held.pose,held.id=pose,id;frame.releasePose=held
end
function M.draw(frame)
 local e=frame.releasePose;local p=e and e.pose
 if not p or p.pull>=.995 or p.fade<=.001 then return false end
 local Plasma=V.require('q57/Plasma')
 if not e.vertices then e.vertices,e.indices=Plasma.newGeometry()end
 Plasma.update(e.vertices,p)
 local R=V.require('Voxel3D')
 local ok=pcall(function()
  if not e.mesh then e.mesh=R.newMesh(e.vertices,e.indices)else e.mesh:setVertices(e.vertices)end
 end)
 if not ok or not e.mesh then return false end
 return V.require('q57/Material').draw(R,e.mesh,nil,nil,0,p,false)
end
function M.subject(frame,card,mesh)
 local e=frame.releasePose
 if not e or card.id~=e.id or e.pose.pull>=.995 then return false end
 return V.require('q57/Material').draw(V.require('Voxel3D'),mesh,card.tex,card.model,0,e.pose,true)
end
return M
