local M=dofile('lib/Gen3RoomWallpaper.lua')
local ts={cols=2,midToSlot={[1]=0,[2]=1},imageData={getPixel=function(_,x,y)return x/32,y/16,.25,1 end},
 overImageData={getPixel=function(_,x,y)return 1,.5,0,x%2==0 and .5 or 0 end}}
local pixels={};local function put(x,y,...)pixels[y*16+x]={...}end
assert(M.pixels(ts,1,2,nil,put))
assert(#pixels[0]==4 and #pixels[511]==4)
assert(pixels[0][1]==.5 and pixels[0][2]==.25 and pixels[0][3]==.125 and pixels[0][4]==1,'BG2 was not composited over native BG1')
assert(pixels[1][1]==1/32,'transparent overlay replaced original source')
assert(pixels[256][1]==.75,'lower native tile used the wrong atlas slot')
assert(pixels[511][2]==15/16,'lower wall drawing lost its last row')
local columns={};assert(M.pixels(ts,1,2,0,function(x,y,...)columns[y*16+x]={...}end))
for y=0,31 do for x=1,15 do for c=1,4 do assert(columns[y*16][c]==columns[y*16+x][c],'wall frame column invented a repeated window')end end end
assert(not M.pixels(ts,999,2,nil,function()error('unavailable native art was substituted')end))
local a,b,col=M.sources('RU_MOSSDEEP_CITY_SPACE_CENTER_1F');assert(a==0x2f8 and b==0x300 and col==0)
a,b=M.sources('SA_LILYCOVE_CITY_LILYCOVE_MUSEUM_2F');assert(a==0x281 and b==0x289)
a,b=M.sources('CUSTOM_REGION_ROOM',{1,2});assert(a==1 and b==2,'third-party native wallpaper extension rejected')
for _,invalid in ipairs{{-1,2},{1.5,2},{1,1024},{1,2,column=16},{1,2,column=-1},{1,2,column=.5}}do
 assert(not M.sources('RU_LILYCOVE_MUSEUM',invalid),'invalid custom wallpaper did not stand down')
end
assert(not M.sources('UNRELATED_ROOM'),'unrelated source acquired institution paint')
print('PASS native wallpaper BG composition, full rows, source isolation, window-free frame repeat and optional map metadata')
