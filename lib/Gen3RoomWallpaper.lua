-- Runtime-only native wallpaper: compose BG1/BG2 once instead of drawing two
-- coplanar paint layers. No imported pixels are stored in the mod package.
local M={}
local cache=setmetatable({},{__mode='k'})
function M.sources(id,custom)
 if custom~=nil then
  local function integer(n,max)return type(n)=='number'and n>=0 and n<=max and n%1==0 end
  if type(custom)=='table'and integer(custom[1],1023)and integer(custom[2],1023)and(custom.column==nil or integer(custom.column,15))and(custom.single==nil or type(custom.single)=='boolean')and(custom.singleHeight==nil or integer(custom.singleHeight,16)and custom.singleHeight>=1 and custom.single==true)then
   return custom[1],custom[2],custom.column,custom.single,custom.singleHeight
  end
  return -- Invalid extensions stand down instead of reading outside the atlas.
 end
 if id:find('LILYCOVE_MUSEUM',1,true)then
  if id:find('_2F',1,true)then return 0x281,0x289 end
  return 0x20b,0x213
 elseif id:find('OCEANIC_MUSEUM',1,true)then return 0x204,0x20c
 elseif id:find('DEVON_CORP',1,true)then return 0x388,0x390
 elseif id:find('SPACE_CENTER',1,true)then
  -- Only the original frame/paint column repeats on other walls. The
  -- source windows remain north-facing fixtures, never invented windows.
  return 0x2f8,0x300,0
 end
end
function M.pixels(ts,upper,lower,column,put,single,singleHeight)
 if not(ts and ts.imageData and ts.midToSlot and ts.cols)then return false end
 local a,b=ts.midToSlot[upper],ts.midToSlot[lower]
 if not(a and b)then return false end
 for y=0,31 do for x=0,15 do
  local slot=(single or y<16)and a or b;local px=slot%ts.cols*16+(column or x);local py=math.floor(slot/ts.cols)*16+(single and math.floor(y*(singleHeight or 16)/32)or y%16)
  local r,g,bb,alpha=ts.imageData:getPixel(px,py)
  if ts.overImageData then
   local rr,gg,bbb,aa=ts.overImageData:getPixel(px,py)
   r,g,bb,alpha=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bbb*aa+bb*(1-aa),aa+alpha*(1-aa)
  end
  put(x,y,r,g,bb,alpha)
 end end
 return true
end
function M.material(def,ts)
 local a,b,col,single,singleHeight=M.sources(def.id or'',def.voxelWallpaper);if not a then return end
 local key=table.concat({a,b,col or'all',single and'single'or'double',singleHeight or 16},':');local entries=cache[ts]
 if entries and entries[key]and entries[key].under==ts.imageData and entries[key].over==ts.overImageData then return entries[key].image end
 local pixels=love.image.newImageData(16,32)
 if not M.pixels(ts,a,b,col,function(...)pixels:setPixel(...)end,single,singleHeight)then pixels:release();return end
 local image=love.graphics.newImage(pixels);pixels:release();image:setFilter('nearest','nearest');image:setWrap('repeat','repeat')
 entries=entries or{};cache[ts]=entries
 if entries[key]then entries[key].image:release()end
 entries[key]={under=ts.imageData,over=ts.overImageData,image=image}
 return image
end
function M.invalidate(ts)
 local entries=cache[ts];if entries then for _,e in pairs(entries)do e.image:release()end end;cache[ts]=nil
end
return M
