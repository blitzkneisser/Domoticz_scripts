commandArray = {}

local sw_ausbel = 'Aussenbeleuchtung Vorne'
local sw_kugbel = 'Leuchtkugel vorne'
local motion1 = 'BWM1 - Eingang'

if devicechanged[sw_ausbel] == 'On' then
   commandArray[sw_kugbel]='On'
elseif devicechanged[sw_ausbel] == 'Off' then
   commandArray[sw_kugbel]='Off'
end

-- switch on via PIM
if devicechanged[motion1] == 'On' then
   if (timeofday['Nighttime']) then
      commandArray[sw_ausbel]='On'
   end
end

return commandArray
