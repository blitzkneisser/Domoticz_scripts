-- set all other thermostats with one button

local pegel_dist  = 'Heizoel Pegel'
local pegel_liter = 'Heizoel Liter'
local pegel_idx   = 239


commandArray = {}

if (devicechanged[pegel_dist]) then
   print('Oil level Set!!')
   local oil_dist = tonumber(otherdevices_svalues[pegel_dist])
   local current_level = 150 - oil_dist + 3
   local current_volume = (current_level * 11.3333 - 83.3333) * 2
   print(string.format("Gemessen: %.1f; Rest: %.1f, Oelmenge: %.0f l", oil_dist, current_level, current_volume))
   commandArray [1] = {['UpdateDevice'] = pegel_idx .. "|0|" .. current_volume}
end

return commandArray
