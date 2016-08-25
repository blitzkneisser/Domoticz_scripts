-- set all other thermostats with one button

local dimmer_on   = 'Kinderzimmer StartDim'
local dimmer      = 'Dimmer Kinderzimmer'
--local dimmer      = 'DummyDimmer'

commandArray = {}

if (devicechanged[dimmer]) then
   if ((tonumber(otherdevices_svalues[dimmer]) == 0)) then --or (tonumber(otherdevices_svalues[dimmer]) == 100)) then
      commandArray[1] = {[dimmer_on]='Off'}
      --commandArray [ 2 ] = {[dimmer]   ='Set Level '  ..  current_dim}
   end
end

return commandArray
