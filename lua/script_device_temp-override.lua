
local or_anheben = 'Tagmodus Override'
local or_absenken = 'Nachtmodus Override'

commandArray = {}

if (devicechanged[or_absenken] == 'On') then
   if (otherdevices[or_anheben] == 'On') then
      commandArray[or_anheben]='Off'
      print('anheben -> absenken')
   end
elseif (devicechanged[or_anheben] == 'On') then
   if (otherdevices[or_absenken] == 'On') then
      commandArray[or_absenken]='Off'
      print('absenken -> anheben')
   end
end

return commandArray
