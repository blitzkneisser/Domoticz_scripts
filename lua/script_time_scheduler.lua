package.path    = package.path .. ";/home/pi/domoticz/scripts/lua/?.lua"
local SchClass  = require("func_scheduler")
local MiscClass = require("func_misc")
local sch_path  = "/home/pi/domoticz/scripts/lua/"

local sw_summer = 'Heizung Sommer'

if (commandArray == nil) then -- for console run
   commandArray = {}
end

local schedules = {}

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
schedules [63]  = 'switch_hwasser.txt' -- Heißwasserbereitung

print("Table")
local ERR = {}
local cnt = 1
for idx, sched in pairs( schedules ) do
   local device = MiscClass.idx2dev(idx)
   print(cnt .. ": Schedule " .. sched .. " for device id " .. idx .. " -> " .. device)
   ERR [idx] = SchClass.schedule(sch_path .. sched, idx, cnt)
   cnt = cnt + 1
end

return commandArray
