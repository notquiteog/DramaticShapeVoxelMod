-- Compose independently rendered native slots. The caller only enters this
-- path outside move scripts, whose public BG state still has side-wide keys.
-- Persistent dolls, faint clocks and visibility belong to each original slot.
local M={}
function M.texture(game,side,screen,render,canvasFor,drawn)
 local other=side..'2'
 local ok,partner=pcall(screen.activeMon,screen,other)
 if not ok then return nil end
 local faint=screen.faintSlide
 if not partner or((partner.hp or 0)<=0 and not(faint and faint.side==other))then
  return render(game,side,true)
 end
 local lead=render(game,side,true)
 local leadMon=drawn[side]
 local pair=render(game,other,true)
 local pairMon=drawn[other]
 drawn[side],drawn[other],drawn[other..'2']=nil,nil,nil
 if not(lead and pair and leadMon and pairMon)then return nil end
 if leadMon==pairMon then return render(game,side,true)end
 local w,h=lead.contentWidth+pair.contentWidth,math.max(lead.contentHeight,pair.contentHeight)
 local cw,ch=math.max(160,w+2),math.max(144,h+2)
 local canvas=canvasFor(side,cw,ch)
 if not canvas then return nil end
 local ax,ay=cw/2,ch-1
 local lx,rx=ax-lead.contentWidth/2,ax+pair.contentWidth/2
 local g=love.graphics
 local prev=g.getCanvas();local r,green,b,a=g.getColor()
 local blend,alpha
 if g.getBlendMode and g.setBlendMode then blend,alpha=g.getBlendMode()end
 local clip
 if g.getScissor and g.setScissor then clip={g.getScissor()}end
 local painted=pcall(function()
  if clip then g.setScissor()end
  g.setCanvas(canvas);g.clear(0,0,0,0);g.setColor(1,1,1,1)
  -- Actor canvases already contain premultiplied pixels.
  if blend then g.setBlendMode('alpha','premultiplied')end
  g.draw(lead.canvas,lx-lead.ax,ay-lead.ay)
  g.draw(pair.canvas,rx-pair.ax,ay-pair.ay)
 end)
 if blend then g.setBlendMode(blend,alpha)end
 if clip then g.setScissor(unpack(clip))end
 g.setCanvas(prev);g.setColor(r,green,b,a)
 if not painted then return nil end
 drawn[side],drawn[other]=leadMon,pairMon
 local function anchor(card,slot,x)
  local p=card.hudAnchors and card.hudAnchors[slot]
  return p and{x-card.ax+p[1],ay-card.ay+p[2]}or nil
 end
 return{canvas=canvas,ax=ax,ay=ay,trainer=false,noMirror=lead.noMirror,
  modernFraming=true,contentWidth=w,contentHeight=h,
  hudAnchors={[side]=anchor(lead,side,lx),[other]=anchor(pair,other,rx)}}
end
return M
