package.path    = package.path .. ";/home/pi/domoticz/scripts/lua/?.lua"
local SchClass  = require("func_scheduler")
local MiscClass = require("func_misc")
local sch_path  = "/home/pi/domoticz/scripts/lua/"

local sw_summer = 'Heizung Sommer'

if (commandArray == nil) then -- for console run
   commandArray = {}
end

local schedules = {}
local overrides = {}

if otherdevices[sw_summer] == 'On' then
--   schedules [666] = 'temp_sommer.txt'
   schedules [145] = 'temp_sommer.txt'   -- Arbeitszimmer
   schedules [120] = 'temp_sommer.txt'   -- Badezimmer
   schedules [123] = 'temp_sommer.txt'   -- Dusche
   schedules [148] = 'temp_sommer.txt'   -- Esszimmer
   schedules [128] = 'temp_sommer.txt'   -- VT Wohnzimmer
   schedules [122] = 'temp_sommer.txt'   -- Kinderzimmer
   schedules [121] = 'temp_sommer.txt'   -- Schlafzimmer
else
   --schedules [666] = 'temp_debug.txt'
   --schedules [157] = 'switch_Stecker2.txt'
   schedules [145] = 'temp_arbeitszimmer.txt' -- Arbeitszimmer
   schedules [120] = 'temp_badezimmer.txt'    -- Badezimmer
   schedules [123] = 'temp_dusche.txt'        -- Dusche
   schedules [148] = 'temp_ess.txt'           -- Esszimmer
   schedules [128] = 'temp_vtwohn.txt'        -- VT Wohnzimmer
   schedules [122] = 'temp_kinder.txt'        -- Kinderzimmer
   schedules [121] = 'temp_schlaf.txt'        -- Schlafzimmer
end

-- Jahreszeit-Unabhängig:
schedules [63]  = 'switch_hwasser.txt'    -- Heißwasserbereitung
schedules [372] = 'switch_xmas.txt'       -- Weihnachtsbeleuchtung
schedules [373] = 'switch_xmas.txt'       -- Weihnachtsbeleuchtung
schedules [376] = 'switch_override.txt'   -- Reset Temp overrides

-- Override-switches
overrides [145] = 375 -- Arbeitszimmer
overrides [123] = 378 -- Dusche
overrides [121] = 379 -- Schlafzimmer

-- Override-handling
local or_off = MiscClass.idx2dev(376)
local or_on  = MiscClass.idx2dev(377)
-- is override-reset active?
if (otherdevices[or_off] == 'On') then
   -- all overrides enabled? switch them off!
   commandArray[9998] = {[or_on]='Off'}
   for idx, switch in pairs( overrides ) do
      -- get index of override-switch
      local device = MiscClass.idx2dev(switch)
      -- and switch it off!
      commandArray[idx] = {[device]='Off'}
   end
   commandArray[9999] = {[or_off]='Off'}
   print("All Temp overrides off!")
elseif (otherdevices[or_on] == 'On') then
   for idx, switch in pairs( overrides ) do
      -- get index of override-switch
      local device = MiscClass.idx2dev(switch)
      -- and switch it on!
      commandArray[idx] = {[device]='On'}
      -- or on switch is no longer needed
      commandArray[9998] = {[or_on]='Off'}
      print("All Temp overrides on!")
   end
end


print("Table")
local ERR = {}
local cnt = 1
for idx, sched in pairs( schedules ) do
   local device = MiscClass.idx2dev(idx)
   local or_switch = MiscClass.idx2dev(overrides[idx])
   
   if (otherdevices[or_switch] == 'On') then
        print(cnt .. ": Override-switch for " .. device .. " (" .. or_switch .. ") is active. Temp will not change")
   else
	print(cnt .. ": Schedule " .. sched .. " for device id " .. idx .. " -> " .. device)
	ERR [idx] = SchClass.schedule(sch_path .. sched, idx, cnt)
   end
   cnt = cnt + 1
end

return commandArray
