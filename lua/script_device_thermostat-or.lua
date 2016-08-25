-- set all other thermostats with one button

--local thermos_or = 'Thermostat Global'
local s_virtuell = 'VThermostat gesamt'

local newtemp = tonumber(otherdevices_svalues[s_virtuell])

commandArray = {}

--if (devicechanged[thermos_or] == 'On') then
if (devicechanged[s_virtuell]) then
   print('Global Temperature Set!!')
   commandArray [1] = {['UpdateDevice']= '128|0|' .. newtemp} -- v_wohnzimmer
   commandArray [2] = {['UpdateDevice']= '120|0|' .. newtemp} -- badezimmer
   commandArray [3] = {['UpdateDevice']= '121|0|' .. newtemp} -- schlafzimmer
   commandArray [4] = {['UpdateDevice']= '122|0|' .. newtemp} -- kinderzimmer
   commandArray [5] = {['UpdateDevice']= '123|0|' .. newtemp} -- dusche
   commandArray [6] = {['UpdateDevice']= '145|0|' .. newtemp} -- arbeitszimmer
   commandArray [7] = {['UpdateDevice']= '148|0|' .. newtemp} -- essszimmer
end

return commandArray
