-- set all other thermostats with one button

local th_wz1 = 'Wohnzimmer Stiege S'
local s_virtuell = 'VThermostat Wohnzimmer'

local newtemp = tonumber(otherdevices_svalues[s_virtuell])

commandArray = {}

if (devicechanged[s_virtuell]) then
   print('Wohnzimmer Temperature Set!!')
   commandArray [1] = {['UpdateDevice']= '151|0|' .. newtemp} -- Wohnzimmer Stiege
   commandArray [2] = {['UpdateDevice']= '154|0|' .. newtemp} -- Wohnzimmer vorne
   commandArray [3] = {['UpdateDevice']= '170|0|' .. newtemp} -- Wohnzimmer Terrasse
end

return commandArray
