package.path    = package.path .. ";/home/pi/domoticz/scripts/lua/?.lua"
local MiscClass = require("func_misc")

commandArray = {}

local motion1  = MiscClass.idx2dev(325) -- WZ (5)
local motion2  = MiscClass.idx2dev(108) -- Keller (2)
local motion3  = MiscClass.idx2dev(180) -- Waschraum (4)
local motion4  = MiscClass.idx2dev(172) -- AZ (4)
local sw_alarm = 'Alarmschalter'
local sw_alarm_hot = 'Alarm scharf'

-- switch on via PIM
if (devicechanged[motion1] == 'On') or
   (devicechanged[motion2] == 'On') or
   (devicechanged[motion3] == 'On') or
   (devicechanged[motion4] == 'On') then
      print("------------------------> Movement detected!")
   if otherdevices[sw_alarm_hot] == 'On' then
      if otherdevices[sw_alarm] == 'Off' then
	 commandArray[sw_alarm]='On'
      end
   end
elseif devicechanged[sw_alarm_hot] == 'Off' then   
   commandArray[sw_alarm]='Off'
end

return commandArray
