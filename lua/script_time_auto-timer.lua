package.path    = package.path .. ";/home/pi/domoticz/scripts/lua/?.lua"
local MiscClass = require("func_misc")
local sch_path  = "/home/pi/domoticz/scripts/lua/"

commandArray = {}

local t_waku    = tonumber(uservariables["t_wasch"])
local sw_waku   = 'Waschraum Licht'
local t_aussen  = tonumber(uservariables["t_aussenbeleuchtung"])
local sw_ausbel = 'Aussenbeleuchtung Vorne'
local sw_alarm  = 'Alarmschalter'
local t_alarm   = tonumber(uservariables["t_alarm"])
local motion1   = 'BWM4 - Waschraum'
local motion2   = 'BWM1 - Eingang'

--print('Waku?')
--if otherdevices[sw_waku] == 'On' then
--   print('Waku on')
--   if ((MiscClass.timedifference(otherdevices_lastupdate[sw_waku]) > t_waku) and (otherdevices[motion1] == 'Off' )) then
--      print('Waku Waku!')
--   end
--end

if otherdevices[sw_waku] == 'On' then
--   print('Waku is ein!')
   if ((MiscClass.timedifference(otherdevices_lastupdate[sw_waku]) > t_waku) and (otherdevices[motion1] == 'Off' )) then
      commandArray[sw_waku]='Off'     
   end
end

if otherdevices[sw_ausbel] == 'On' then
   if ((MiscClass.timedifference(otherdevices_lastupdate[sw_ausbel]) > t_aussen) and (otherdevices[motion2] == 'Off' )) then
      commandArray[sw_ausbel]='Off'
   end
end

if otherdevices[sw_alarm] == 'On' then
   if (MiscClass.timedifference(otherdevices_lastupdate[sw_alarm]) > t_alarm) then
      commandArray[sw_alarm]='Off'
   end
end

return commandArray
