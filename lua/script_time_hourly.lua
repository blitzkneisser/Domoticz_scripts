
commandArray = {}

local year  = tonumber(os.date("%Y"))
local month = tonumber(os.date("%m"))
local day   = tonumber(os.date("%d"))
local std   = tonumber(os.date("%H"))
local min   = tonumber(os.date("%M"))

local testmode = 0 -- set 1 for immediate actions!

-- Ölstand Messung-------------------
local pegel_dist  = 'Heizoel Distanz'
local pegel_liter = 'Heizoel Liter'
local pegel_pegel = 'Heizoel Pegel'
local pegel_idx   = 239
local pegel2_idx  = 306
local tank_liter  = 317
-------------------------------------

if ((min == 00) or (testmode == 1)) then -- beginning of every hour
   -------------------------------------
   print('Oil level Measurement in progress...')
   local oil_dist   = tonumber(otherdevices_svalues[pegel_dist])
   local prev_level = tonumber(otherdevices_svalues[pegel_pegel])
   if (oil_dist > 7) then
      local current_level = 150 - oil_dist + 3
      if ((current_level >= prev_level-5) and (current_level <= prev_level+5)) then
	 local current_volume = (current_level * 11.3333 - 83.3333) * 2
	 print(string.format("Gemessen: %.1f; Rest: %.1f, Oelmenge: %d l", oil_dist, current_level, current_volume))
	 commandArray [1] = {['UpdateDevice'] = pegel_idx  .. "|0|" .. current_volume}
	 commandArray [2] = {['UpdateDevice'] = tank_liter .. "|0|" .. current_volume}
	 commandArray [3] = {['UpdateDevice'] = pegel2_idx .. "|0|" .. current_level}
      else
	 current_level  = prev_level
	 current_volume = tonumber(otherdevices_svalues[pegel_liter])
print(current_volume)
      end
      if ((std == 6) or (testmode == 1)) then -- jeden Tag um 6
	 local file = io.open("/home/pi/domoticz/oil_log.txt", "a")
	 file:write(string.format("%04d-%02d-%02d - %02d:%02d \tPegel: %3.1f cm \tRest: %4d l\n", year, month, day, std, min, current_level, current_volume))
	 file:close()
	 os.execute("chmod 666 /home/pi/domoticz/oil_log.txt")
	 -- ifttt mail
	 mail = io.popen("mail -s " .. current_volume .. " -r alex@gn8.at trigger@recipe.ifttt.com", "w")
	 mail:write(string.format("#domoticz_oil\n%04d-%02d-%02d - %02d:%02d \tPegel: %3.1f cm \tRest: %4d l\n", year, month, day, std, min, current_level, current_volume))
	 -- gn8 mail
	 mail = io.popen(string.format("mail -s \'Domoticz Tank Statusmeldung (%04.1d Liter)\' -r alex@gn8.at alex@gn8.at", "w"),current_volume)
	 mail:write(string.format("Tank Ölstand\n%04d-%02d-%02d - %02d:%02d \tPegel: %3.1f cm \tRest: %4d l\n", year, month, day, std, min, current_level, current_volume))
      end
   end
   -------------------------------------
end

return commandArray
