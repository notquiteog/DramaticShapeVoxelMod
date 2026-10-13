local L=dofile('lib/Gen3NativeLamps.lua')
local function cells(collision,pair)
 return {['2:3']={cx=2,cy=3,pair=pair or 'general__rustboro',mid=0x212,collision=0},
 ['2:4']={cx=2,cy=4,pair=pair or 'general__rustboro',mid=0x21A,collision=collision or 7}}
end
local c=cells();local gs=L.prepare(c);assert(#gs==1 and c['2:3'].nativeLamp==gs[1] and c['2:4'].nativeLamp==gs[1])
assert(#L.prepare(cells(0))==0,'never anchor on walking cell')
assert(#L.prepare(cells(7,'general__slateport'))==0,'secondary IDs are scoped')
local shadow=cells();shadow['2:3'].mid=0x213;shadow['2:4'].mid=0x21B;assert(#L.prepare(shadow)==1 and shadow['2:4'].nativeLampGround==0x2C3,'native shaded paving variant')
local bad=cells();bad['2:4'].mid=0x219;assert(#L.prepare(bad)==0,'partial source rejected')
local n,glass,minY,maxY=0,0,math.huge,-math.huge;local edges={}
local function key(p)return string.format("%.5f/%.5f/%.5f",p[1],p[2],p[3])end
L.append(gs[1],function(v,uv,shade)
 for i,p in ipairs(v)do local a,b=key(p),key(v[i%4+1]);if a~=b then if a>b then a,b=b,a end;local k=a..":"..b;edges[k]=(edges[k]or 0)+1 end end
 n=n+1;if shade>=64 then glass=glass+1 end
 for _,p in ipairs(v)do assert(p[1]>32 and p[1]<48 and p[3]>64 and p[3]<80,'native walking cell intrusion');minY=math.min(minY,p[2]);maxY=math.max(maxY,p[2])end
end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
assert(n>100 and glass==8 and minY==0 and maxY==32,'closed source-height post/glass/cap')
for _,count in pairs(edges)do assert(count==2,'closed manifold surface required')end
local lights=L.lights(gs[1]);assert(#lights==1 and lights[1][5]==0 and lights[1][6]==0,'single omnidirectional native lamp')
gs[1].edition='ruby';local rsGlass=0;L.append(gs[1],function(v,u,s)if s>=64 then rsGlass=rsGlass+1 end end,function()return {{0,0},{1,0},{1,1},{0,1}}end);assert(rsGlass==24,'independently modeled RS globe')
print('PASS native Rustboro source-pair match, blocked-cell geometry, blue glass, closed post/cap and lamp emitter')
