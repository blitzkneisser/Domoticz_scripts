-- set all other thermostats with one button

local dimmer_on   = 'Kinderzimmer StartDim'
local dimmer      = 'Dimmer Kinderzimmer'
--local dimmer      = 'DummyDimmer'
local t_dim_total = tonumber(uservariables["dim_KiZi_t"])
local steps       = tonumber(uservariables["dim_KiZi_steps"])
local t_dim_diff  = t_dim_total / (steps - 1)
local lvl_diff    = 100 / steps
commandArray = {}

if (devicechanged[dimmer_on]) then
   if (otherdevices[dimmer_on] == 'On') then
      print('Dimmer start!!')
      commandArray [ 1] = {[dimmer_on]='Off AFTER 1'}
      for i=1,steps do
	 commandArray [ i ] = {[dimmer]   ='Set Level '  ..  lvl_diff * i .. ' AFTER ' ..t_dim_diff * (i-1)}
      end
      commandArray [ steps + 1] = {[dimmer_on]='Off AFTER ' .. t_dim_total + 1}
      --elseif (devicechanged[dimmer_on] == 'Off') then
      --elseif (otherdevices[dimmer_on] == 'Off') then
   else
      print('Dimmer stop!!')
      local current_dim = tonumber(otherdevices_svalues[dimmer])
      commandArray = {}
      commandArray [ 1 ] = {[dimmer]   ='Set Level '  ..  current_dim}
   end
end

return commandArray
