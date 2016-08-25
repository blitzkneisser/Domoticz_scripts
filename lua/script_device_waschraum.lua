commandArray = {}

local sw_waku = 'Waschraum Licht'
local motion1 = 'BWM4 - Waschraum'

-- switch on via PIM
if devicechanged[motion1] == 'On' then
   commandArray[sw_waku]='On'
end

return commandArray
