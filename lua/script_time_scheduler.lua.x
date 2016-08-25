local function timediff (hour1, minutes1, hour2, minutes2)
   t1 = os.time{year=2016, month=1, day=1, hour=hour1, min=minutes1}
   t2 = os.time{year=2016, month=1, day=1, hour=hour2, min=minutes2}
   difference = os.difftime (t1, t2)
   return difference
end

local function day_current(day_s, day_curr)
   if (string.sub(day_s,day_curr,day_curr) == '1') then
      return 1
   else
      return 0
   end
end

if (1) then
--if otherdevices['Debug output'] == "On" then
   debugmode = 1
else
   debugmode = 0
end

local function schedule(path, dev_id, idx)
   -- get current time and date
   local year  = tonumber(os.date("%Y"))
   local month = tonumber(os.date("%m"))
   local day   = tonumber(os.date("%d"))
   local wday  = tonumber(os.date("%w"))
   local hour  = tonumber(os.date("%H"))
   local min   = tonumber(os.date("%M"))
   if (wday==0) then wday  = 7; end -- Mon=1, Sun=7
   if (wday==1) then pwday = 7; else pwday = wday - 1; end -- previous weekday
   ----------------------------
   local sethour = 0
   local setmin  = 0
   local newtemp = 99
   local maxhour = 0
   local maxmin  = 0
   local maxtemp = 0
   local tdiffm  = 0
   local tdiff   = 86400
   fh,err = io.open(path)
   if err then print("OOps"); return; end
   -- line by line
   while true do
      line = fh:read()
      if line == nil then break end
      if ((string.sub(line,1,1) == '@') and (string.len(line) >= 20)) then
	 days_s  = string.sub(line,2,8)
	 timeh   = tonumber(string.sub(line,10,11))
	 timem   = tonumber(string.sub(line,13,14))
	 act     = tonumber(string.sub(line,16,19))
	 tdiffx  = timediff(hour, min, timeh, timem)
	 tdiffy  = timediff(0, 0, timeh, timem)
	 if (debugmode == 1) then print(string.format("Tage: %s @%02d:%02d -> %02.1f (%d/%d) [TD: %d]",days_s ,timeh, timem, tonumber(act), day_current(days_s, wday),wday, tdiffx));end
	 -- check if current schedule line is most recent one
	 if ((day_current(days_s, wday) == 1) and (tdiffx >= 0)) then -- ignore future setpoints
	    if (tdiffx <= tdiff) then
	       tdiff   = tdiffx
	       sethour = timeh
	       setmin  = timem
	       newtemp = act -- save last valid temperature
	    end
	 end
	 -- find latest schedule item of previous day
	 if ((day_current(days_s, pwday) == 1) and (tdiffy <= 0)) then
	    if (tdiffy <= tdiffm) then
	       tdiffm  = tdiffy
	       maxhour = timeh
	       maxmin  = timem
	       maxtemp = act -- save last valid temperature
	    end
	 end
      end
   end
   if (newtemp == 99) then -- no valid setpoint today, getting last one from yesterday!
      newtemp = maxtemp
   end
   if (debugmode == 1) then print(string.format("Last Temp (%02d:%02d): %02.1f", sethour, setmin, newtemp));end
   commandArray [idx] = {['UpdateDevice']= dev_id .. '|0|' .. newtemp}
   fh:close()
end

commandArray = {}

local ERR  = schedule('/home/pi/domoticz/scripts/lua/sch01.txt', 666 ,10)
local ERR  = schedule('/home/pi/domoticz/scripts/lua/sch_arbeitszimmer.txt', 145 ,1)
local ERR  = schedule('/home/pi/domoticz/scripts/lua/sch_badezimmer.txt', 120 ,2)

print(commandArray [1])
print(commandArray [2])
print(commandArray [3])

return commandArray
