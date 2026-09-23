-- The same look preference feeds the native and GB camera adapters.
local V=...
return {invertY=V.require('ModSetting').new('invertY','Y-CONTROL INVERT',
 {false,true},{'OFF','ON'})}
