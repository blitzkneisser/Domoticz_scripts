commandArray = {}

local sw_alarm      = 'Alarmschalter'
local sw_alarm_hot  = 'Alarm scharf'
local sw_alarm_stat = 'Alarm-dummy'
local gr_alarm      = 'Group:Alarmsignal'
local t_blink       = tostring(uservariables["t_alarm_blink"])

if devicechanged[sw_alarm] == 'On' then
   print('Alarm!')
   commandArray[gr_alarm]='On'
   print('Ein!')
elseif devicechanged[sw_alarm] == 'Off' then
   print('Alarm aus!')
   commandArray[gr_alarm]='Off'
   print('Aus!')
elseif devicechanged[sw_alarm_stat] == 'On' then
   if otherdevices[sw_alarm] == 'On' then
      commandArray={[gr_alarm]='Off AFTER '..t_blink}
      print('Aus!')
   end
elseif devicechanged[sw_alarm_stat] == 'Off' then      
   if otherdevices[sw_alarm] == 'On' then
      commandArray={[gr_alarm]='On AFTER '..t_blink}
      print('Ein!')
   end
end

return commandArray
