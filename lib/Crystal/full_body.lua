local V = ...
-- Public staged-art provider. Normal UI retains the Crystal sprite hooks.
return function(mod, dexFor, isShiny)
 local Assets=require('src.render.Assets')
 local ok,index=pcall(V.data,'crystal_full_body')
 if not ok then index={} end
 local loaded={}
 Assets.register({release=function()
  for _,entry in pairs(loaded) do if entry then
   for _,q in ipairs(entry.quads) do if q.release then q:release() end end
  end end
  loaded={}
 end})
 local clock=0
 mod.hooks:wrap('core.update',function(next,game,dt)
  local result=next(game,dt)
  clock=clock+math.min(math.max(tonumber(dt) or 0,0),.25)
  return result
 end)
 mod.options:define({{key='full_body_backs',type='toggle',label='FULL-BODY BATTLE BACKS',
  default=true,help='Animated full-body backs on compatible 2.5D battle stages.'}})
 local function resolve(mon,back)
  if not back or not mon or mod.options:get('full_body_backs')~=true then return nil end
  local dex=dexFor(mon.species);if not dex then return nil end
  local key=(isShiny(mon) and 'shiny/' or 'normal/')..dex
  local row=index[key];if not row then return nil end
  local entry=loaded[key]
  if entry==nil then
   local good,img=pcall(Assets.image,mod.path..'/assets/crystal/full_body/'..key..'.png')
   if not good or not img then loaded[key]=false;return nil end
   img:setFilter('nearest','nearest')
   entry={image=img,quads={},total=0}
   for i,duration in ipairs(row.durations) do
    entry.total=entry.total+duration
    entry.quads[i]=love.graphics.newQuad(((i-1)%row.columns)*row.w,
     math.floor((i-1)/row.columns)*row.h,row.w,row.h,img:getDimensions())
   end
   loaded[key]=entry
  end
  if not entry then return nil end
  local t=clock%entry.total;local frame=#row.durations
  for i,d in ipairs(row.durations) do if t<d then frame=i;break end;t=t-d end
  return {image=entry.image,quad=entry.quads[frame],width=row.w,height=row.h,
   fullBody=true,frame=frame,source='gen5',variant=isShiny(mon) and 'shiny' or 'normal'}
 end
 return resolve
end
