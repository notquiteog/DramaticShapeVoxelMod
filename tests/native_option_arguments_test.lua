-- Native RS/RSE option pages supply cartridge-owned rows to avoid FRLG text.
package.loaded['src.core.GameVersion']={generation=function()return 3 end}
package.loaded['src.mods.Runtime']={emit=function()end}
local native={textSpeed={id='textSpeed',label='NATIVE TEXT SPEED'}}
local marker={};local calls=0
local Rows={build=function(ctx,skip,extra)
 assert(skip==native and extra==marker,'adapter discarded native page arguments')
 calls=calls+1;return{skip.textSpeed}
end,group=function(rows)return rows end}
package.loaded['src.ui.game3.option_rows']=Rows
local callbacks={};local mod={id='TEST',options={get=function()end},hooks={wrap=function(_,key,fn)callbacks[key]=fn end}}
local Adapter=dofile('lib/InGameOptions.lua');Adapter.install(mod,{},'TEST')
local ctx={game={options={modOptions={}},mods={modOptions={}}}}
assert(Rows.build(ctx,native,marker)[1]==native.textSpeed)
callbacks['core.quit_to_launcher'](function()end)
assert(Rows.build(ctx,native,marker)[1]==native.textSpeed and calls==2)
print('PASS native cartridge option rows and future arguments survive active/inactive wrappers')
