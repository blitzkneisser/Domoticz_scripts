package.path    = package.path .. ";/home/pi/domoticz/scripts/lua/?.lua"
local MiscClass = require("func_misc")
local sch_path  = "/home/pi/domoticz/scripts/lua/"

-- hysteresis function for temperature control
function hyst (temp_m, temp_s, hyst)
   if temp_m <= (temp_s - (hyst / 3 * 2)) then -- 2/3 below
      bo_heatup = true
   end
   if temp_m >= (temp_s + (hyst / 3)) then -- 1/3 overshoot
      bo_heatup = false
   end
   return bo_heatup
end


local or_anheben   = 'Tagmodus Override'
local or_absenken  = 'Nachtmodus Override'
local sw_nightmode = 'Heizung Nachtmodus'
local sw_summer    = 'Heizung Sommer'

local m_ess    = 'Esszimmer'
local s_ess    = 'Esszimmer S'
local m_arbeit = 'Arbeitszimmer'
local s_arbeit = 'Arbeitszimmer S'
local m_schlaf = 'Schlafzimmer'
local s_schlaf = 'Schlafzimmer S'
local m_kinder = 'Kinderzimmer'
local s_kinder = 'Kinderzimmer S'
local m_bad    = 'Badezimmer'
local s_bad    = 'Badezimmer S'
local m_dusche = 'Dusche'
local s_dusche = 'Dusche S'
--local m_wohn   = 'Wohnzimmer (BWM2)'
local m_wohn   = 'Esszimmer (Schrank)'
local s_wohn   = 'Hausthermostat'
local m_wohn1  = 'Wohnzimmer Stiege'
local s_wohn1  = 'Wohnzimmer Stiege S'
local m_wohn2  = 'Wohnzimmer Vorne'
local s_wohn2  = 'Wohnzimmer Vorne S'
local m_wohn3  = 'Wohnzimmer Terrasse'
local s_wohn3  = 'Wohnzimmer Terrasse S'

local newtemp = 0.0
local oldtemp = 0.0
local difftemp_user = "0.0"
local diffroom_user = "keiner..."

room_cold = uservariables["room_cold"]
room_diff = uservariables["room_diff"]

temp_tt   = uservariables["Tagestemperatur"]
temp_ts   = uservariables["Sommertemperatur"]
temp_n    = uservariables["Nachttemperatur"]
t_rise    = uservariables["wz_anheben"]

os_schlaf = uservariables["offset_schlafzimmer"]
os_wohn   = uservariables["offset_wohnzimmer"]
os_kinder = uservariables["offset_kinderzimmer"]
os_dusche = uservariables["offset_dusche"]
os_bad    = uservariables["offset_bad"]
os_arbeit = uservariables["offset_arbeit"]
os_ess    = uservariables["offset_esszimmer"]

hy_arbeit = uservariables["hyst_arbeit"]
hy_bad    = uservariables["hyst_bad"]
hy_dusche = uservariables["hyst_dusche"]
hy_ess    = uservariables["hyst_esszimmer"]
hy_kinder = uservariables["hyst_kinderzimmer"]
hy_schlaf = uservariables["hyst_schlafzimmer"]
hy_wohn   = uservariables["hyst_wohnzimmer"]

local min   = tonumber(os.date("%M"))

-- temperature override switches active?
local bo_heat = otherdevices[or_anheben]  == 'On' -- anheben on?
local bo_cool = otherdevices[or_absenken] == 'On' -- absenken on?

-- measure temperature with hysteresis
local bo_schlaf = hyst(otherdevices_temperature[m_schlaf], tonumber(otherdevices_svalues[s_schlaf]) + os_schlaf, hy_schlaf)
local bo_kinder = hyst(otherdevices_temperature[m_kinder], tonumber(otherdevices_svalues[s_kinder]) + os_kinder, hy_kinder)
local bo_bad    = hyst(otherdevices_temperature[m_bad],    tonumber(otherdevices_svalues[s_bad])    + os_bad,    hy_bad)
local bo_dusche = hyst(otherdevices_temperature[m_dusche], tonumber(otherdevices_svalues[s_dusche]) + os_dusche, hy_dusche)
local bo_arbeit = hyst(otherdevices_temperature[m_arbeit], tonumber(otherdevices_svalues[s_arbeit]) + os_arbeit, hy_arbeit)
local bo_ess    = hyst(otherdevices_temperature[m_ess],    tonumber(otherdevices_svalues[s_ess])    + os_ess,    hy_ess)
local bo_wohn1  = hyst(otherdevices_temperature[m_wohn1],  tonumber(otherdevices_svalues[s_wohn1])  + os_wohn,   hy_wohn)
local bo_wohn2  = hyst(otherdevices_temperature[m_wohn2],  tonumber(otherdevices_svalues[s_wohn2])  + os_wohn,   hy_wohn)
local bo_wohn3  = hyst(otherdevices_temperature[m_wohn3],  tonumber(otherdevices_svalues[s_wohn3])  + os_wohn,   hy_wohn)

-- temperature differences:

local tempdiffs = {
   ["schlaf"] = tonumber(otherdevices_svalues[s_schlaf]) - otherdevices_temperature[m_schlaf],
   ["kinder"] = tonumber(otherdevices_svalues[s_kinder]) - otherdevices_temperature[m_kinder],
   ["bad"]    = tonumber(otherdevices_svalues[s_bad])    - otherdevices_temperature[m_bad],
   ["dusche"] = tonumber(otherdevices_svalues[s_dusche]) - otherdevices_temperature[m_dusche],
   ["arbeit"] = tonumber(otherdevices_svalues[s_arbeit]) - otherdevices_temperature[m_arbeit],
   ["ess"]    = tonumber(otherdevices_svalues[s_ess])    - otherdevices_temperature[m_ess],
   ["wohn1"]  = tonumber(otherdevices_svalues[s_wohn1])  - otherdevices_temperature[m_wohn1],
   ["wohn2"]  = tonumber(otherdevices_svalues[s_wohn2])  - otherdevices_temperature[m_wohn2],
   ["wohn3"]  = tonumber(otherdevices_svalues[s_wohn3])  - otherdevices_temperature[m_wohn3]
}
  
-- chose the maximum temperature difference
local max_val, key = -math.huge
for k, v in pairs(tempdiffs) do
   if v > max_val then
      max_val, key = v, k
   end
end

if max_val > 0 then
   print("wo: " .. key .. " - wieviel: " .. max_val)
else
   print("Alle Zimmer haben Zieltemperatur, kein Heizen notwendig.")
end

-- is it too cold somewhere?
local bo_toocold = bo_ess or bo_arbeit or bo_schlaf or bo_kinder or bo_bad or bo_dusche or bo_wohn1 or bo_wohn2
print('E:' .. tostring(bo_ess) .. ' A:' .. tostring(bo_arbeit) .. ' S:' .. tostring(bo_schlaf) .. ' K:' .. tostring(bo_kinder) .. ' B:' .. tostring(bo_bad) .. ' D:' .. tostring(bo_dusche) .. ' W1S:' .. tostring(bo_wohn1) .. ' W2V:' .. tostring(bo_wohn2) .. ' W3T:' .. tostring(bo_wohn3) .. ' = ' .. tostring(bo_toocold))


local tag = tostring(os.date("%a"));
local std = tonumber(os.date("%H"));
local min = tonumber(os.date("%M"));

commandArray = {}

-- default values
if (bo_toocold) then
   commandArray[3] = {['Variable:room_cold'] = key}
   commandArray[4] = {['Variable:room_diff'] = tostring(max_val)}
else
   commandArray[3] = {['Variable:room_cold'] = "keiner..."}
   commandArray[4] = {['Variable:room_diff'] = "0.0"}
end


print('Temp check in progress...')
local bo_daymode = false -- default value
-- daily program
if (tag == 'Mon' or tag == 'Tue') then
   if (std >= 22) then
      bo_daymode = false
   elseif (std >= 16) then
      bo_daymode = true
   elseif (std >= 7) then
      bo_daymode = false
   elseif ((std >= 4 and min >= 30) or std > 5) then
      bo_daymode = true
   end
elseif (tag == 'Wed') then
   if (std >= 22) then
      bo_daymode = false
   elseif (std >= 12) then
      bo_daymode = true
   elseif (std >= 7) then
      bo_daymode = false
   elseif ((std >= 4 and min >= 30) or std > 5) then
      bo_daymode = true
   end
elseif (tag == 'Thu' or tag == 'Fri') then
   if (std >= 22) then
      bo_daymode = false
   elseif (std >= 5) then
      bo_daymode = true
   end
elseif (tag == 'Sat' or tag == 'Sun' ) then
   if (std >= 23) then
      bo_daymode = false
   elseif ((std >= 5 and min >= 30) or std > 6) then
      bo_daymode = true
   end
end

-- override day/night settings according to switches!
if (bo_heat) then
   bo_daymode = true
elseif (bo_cool) then
   bo_daymode = false
elseif (bo_toocold) then
   bo_daymode = true
end

-- control the digital input of thermostat via relais
if (bo_daymode) then
   if (otherdevices[sw_nightmode] == 'On') then
      commandArray[1] = {[sw_nightmode]='Off'}
   end
else
   if (otherdevices[sw_nightmode] == 'Off') then
      commandArray[1] = {[sw_nightmode]='On'}
   end
end

if otherdevices[sw_summer] == 'On' then
   commandArray[2] = {['UpdateDevice']= '75|0|' .. temp_ts}
-- too cold? set OpenTherm thermostat value higher for heating (max tempdiff + fixed)
else
   local chg_temp = false
   if (bo_toocold) then
      oldtemp =  math.ceil(otherdevices[s_wohn])
      newtemp = math.ceil(otherdevices_temperature[m_wohn] + max_val + t_rise)
      if (newtemp % 2 ~= 0) then
         newtemp = newtemp + 1 -- always even values
      end
      -- temperature is rising or last update is longer ago than 15 minutes
      if ((oldtemp < newtemp) or (MiscClass.timedifference(otherdevices_lastupdate[s_wohn]) > 15) ) then
         chg_temp = true
      end      
      print('Temperature check finished, analyzing... Status: ' .. tostring(chg_temp))
      local diff = math.floor(otherdevices[s_wohn] - newtemp)
      --print('Diff: ' .. diff)
      if (chg_temp) then -- only if temp higher or temp drop every ten minutes
         if (diff == 0) then
	       print('Heating required, but thermostat value already correct: ' .. math.floor(otherdevices[s_wohn]) .. '/' .. newtemp)
         else
               print('New thermostat value: ' .. newtemp .. ' Old: ' .. otherdevices[s_wohn])
               commandArray[2] = {['UpdateDevice']= '75|0|' .. newtemp}
	       print('Heating required: ' .. newtemp)
         end
      end
   elseif bo_daymode then
      commandArray[2] = {['UpdateDevice']= '75|0|' .. temp_tt}
   else
      commandArray[2] = {['UpdateDevice']= '75|0|' .. temp_n}
   end
end


return commandArray
