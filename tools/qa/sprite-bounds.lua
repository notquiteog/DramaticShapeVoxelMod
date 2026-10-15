-- Compare the CPU bounds cache to actual GPU rasterization; isolated QA only.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Art=V.require('BattleArt');local Native=V.require('NativeBattleArt')
 local Bounds=V.require('SpriteHeadBounds');local checks=0
 for _,dims in ipairs({{12,10},{56,56},{96,96},{83,69}})do
  local w,h=unpack(dims);local data=love.image.newImageData(w,h)
  data:mapPixel(function(x,y)
   return .3,.6,.9,(x>=2 and x<w-3 and y>=3 and y<h-2 and (x+y)%7~=0)and 1 or 0
  end)
  local image=assert(Art.prepareData(data,'color'))
  for _,size in ipairs({56,64,80})do for _,mirror in ipairs({false,true})do
   for _,scale in ipairs({.5,2/3,1,1.5})do
    local fit=Native.fit(image,size,mirror,scale)
    local cpu=Bounds.get(fit);local rendered=fit:newImageData()
    local gpu=Bounds.fromData(rendered,size,size);rendered:release()
    for i=1,4 do assert(cpu[i]==gpu[i],table.concat({w,h,size,tostring(mirror),scale,i,cpu[i],gpu[i]},':'))end
    checks=checks+1
   end
  end end
 end
 assert(Bounds.stats.fit>0 and Bounds.stats.gpu>0)
 print('[sprite bounds GPU parity]',checks,'fits',Bounds.stats.fit,'CPU fits',Bounds.stats.gpu,'fallback readbacks')
 love.event.quit()
end
