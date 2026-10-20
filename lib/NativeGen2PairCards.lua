-- Split only a verified native release into the original two actor canvases.
-- Their pixel-to-world transform is algebraically identical to composition.
local V=...
local Mat4=V.require('Mat4')
local M={}
function M.split(tex,parent)
 local actors=tex and tex.actors
 if not actors then return nil end
 local releasing=false
 for _,actor in ipairs(actors)do releasing=releasing or actor.card.releaseCanvas~=nil end
 if not releasing then return nil end
 local tw,th=tex.canvas:getWidth(),tex.canvas:getHeight()
 local out={}
 for _,actor in ipairs(actors)do
  local card=actor.card;local aw,ah=card.canvas:getWidth(),card.canvas:getHeight()
  local transform=Mat4.mul(Mat4.translate((actor.x+aw/2)/tw-.5,1-(actor.y+ah)/th,0),Mat4.scale(aw/tw,ah/th,1))
  out[#out+1]={tex=card.canvas,side=actor.slot,teamSide=parent.side,model=Mat4.mul(parent.model,transform),
   trainer=false,noDayTint=parent.noDayTint,hudAnchors=card.hudAnchors,
   actorMon=card.actorMon,releaseCanvas=card.releaseCanvas,releaseCue=card.releaseCue,
   anchor={card.ax,card.ay},contentWidth=card.contentWidth,contentHeight=card.contentHeight}
 end
 return out
end
function M.point(card,x,y)
 local tw,th=card.tex:getWidth(),card.tex:getHeight();local m=card.model
 x,y=x/tw-.5,1-y/th
 return{m[1]*x+m[2]*y+m[4],m[5]*x+m[6]*y+m[8],m[9]*x+m[10]*y+m[12]}
end
return M
