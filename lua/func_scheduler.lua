package.path    = package.path .. ";/home/pi/domoticz/scripts/lua/?.lua"
local MiscClass = require("func_misc")


---------------------------------------
local headers = {}

-- b64 encoding
local function _b64enc( data )
    -- character table string
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

    return ( (data:gsub( '.', function( x ) 
        local r,b='', x:byte()
        for i=8,1,-1 do r=r .. ( b % 2 ^ i - b % 2 ^ ( i - 1 ) > 0 and '1' or '0' ) end
        return r;
    end ) ..'0000' ):gsub( '%d%d%d?%d?%d?%d?', function( x )
        if ( #x < 6 ) then return '' end
        local c = 0
        for i = 1, 6 do c = c + ( x:sub( i, i ) == '1' and 2 ^ ( 6 - i ) or 0 ) end
        return b:sub( c+1, c+1 )
    end) .. ( { '', '==', '=' } )[ #data %3 + 1] )
end
-- authentication header creation
local function _createBasicAuthHeader( username, password )
	-- the header format is "Basic <base64 encoded username:password>"
	local header = "Basic "
	local authDetails = _b64enc( username .. ":" .. password )
	header = header .. authDetails
	return header
end
local authHeader = _createBasicAuthHeader( 'majordomus', 'domoticz' )
-- set the auth header
headers["Authorization"] = authHeader
----------------------------------------

local url="http://192.168.0.99:8080"

local publicClass={}
debugmode = 1

-- calculate difference in seconds between two times
function publicClass.timediff (hour1, minutes1, hour2, minutes2)
   t1 = os.time{year=2016, month=1, day=1, hour=hour1, min=minutes1}
   t2 = os.time{year=2016, month=1, day=1, hour=hour2, min=minutes2}
   difference = os.difftime (t1, t2)
   return difference
end

-- determine from a string and a day number if day is valid
function publicClass.day_current(day_s, day_curr)
   if (string.sub(day_s,day_curr,day_curr) == '1') then
      return 1
   else
      return 0
   end
end

-- do the heavy lifting
function publicClass.schedule(path, dev_id, idx)
   -- get current time and date
   local debugmode  = 0
   local switchmode = 1 --default value
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
   local newact  = 99
   local maxhour = 0
   local maxmin  = 0
   local maxact
   local lastact = ""
   local tdiffm  = 0
   local tdiff   = 86400
   local fh,err = io.open(path)
   if err then print("OOps"); return; end
   -- line by line
   while true do
      local line = fh:read()
      if line == nil then break end
      if ((string.sub(line,1,1) == '@') and (string.len(line) >= 18)) then
	 days_s  = string.sub(line,2,8)
	 timeh   = tonumber(string.sub(line,10,11))
	 timem   = tonumber(string.sub(line,13,14))
	 -- switch or temperature mode?
	 if (string.sub(line,16,17) == "on") then
	    act = "On"
	    switchmode = 1
	 elseif (string.sub(line,16,18) == "off") then
	    act = "Off"   
	    switchmode = 1
	 else
	    act = tonumber(string.sub(line,16,19))
	    switchmode = 0
	 end
	 -- calculate time differences
	 tdiffx  = publicClass.timediff(hour, min, timeh, timem)
	 tdiffy  = publicClass.timediff(0, 0, timeh, timem)
	 if ((debugmode == 1) and (switchmode == 0)) then
	    print(string.format("Days: %s @%02d:%02d -> %2.1f (%d/%d) [TD: %d]",days_s ,timeh, timem, act, publicClass.day_current(days_s, wday),wday, tdiffx))
	 elseif ((debugmode == 1) and (switchmode == 1)) then
	    print(string.format("Days: %s @%02d:%02d -> %3s (%d/%d) [TD: %d]",days_s ,timeh, timem, act, publicClass.day_current(days_s, wday),wday, tdiffx))
	 end
	 -- check if current schedule line is most recent one
	 if ((publicClass.day_current(days_s, wday) == 1) and (tdiffx >= 0)) then -- ignore future setpoints
	    if (tdiffx <= tdiff) then
	       tdiff   = tdiffx
	       sethour = timeh
	       setmin  = timem
	       newact  = act -- save last valid temperature
	    end
	 end
	 -- find latest schedule item of previous day
	 if ((publicClass.day_current(days_s, pwday) == 1) and (tdiffy <= 0)) then
	    if (tdiffy <= tdiffm) then
	       tdiffm  = tdiffy
	       maxhour = timeh
	       maxmin  = timem
	       maxact  = act -- save last valid temperature
	    end
	 end
      end
   end
   if (newact == 99) then -- no valid setpoint today, getting last one from yesterday!
      newact  = maxact
      sethour = maxhour
      setmin  = maxmin
   end
   -- print(string.format("Switchmode: %d, Debugmode: %d", switchmode, debugmode))
   local devicename = MiscClass.idx2dev(dev_id)
   local timediff = 0
   local timemod  = ""
   local timeovr  = 10*60
--   local uv_ormode = uservariables[string.format("OR_IDX%04d",dev_id)]
   local uv_ormode = string.format("OR_IDX%04d",dev_id)
   
   if (switchmode == 0) then -- Temperature mode (temp)
      local currtemp = tonumber(otherdevices_svalues[devicename])
      if (currtemp == newact) then
	 --print("Nothing to set here!")
      else
	 if (devicename ~= 0) then
	    timemod  = otherdevices_lastupdate[devicename]
	    timediff = MiscClass.timedifference(otherdevices_lastupdate[devicename])
--	    commandArray [666] = {['Variable:uv_ormode'] = "on"}
	 end
	 if( timediff >= 60 ) then -- "normal" temperature change
	    print(string.format("Setting new Temperature %02.1f on %s!", newact, devicename))
	    commandArray [idx] = {['UpdateDevice']= dev_id .. '|0|' .. newact}
	 else -- manual temperature change
	    print(string.format("Modified Device: %s, Modified Device Time: %s , Time Diff: %03d", devicename, timemod, timediff))
	    if not uservariables[uv_ormode] then
	       print(string.format('User Variable %s doesnt exist.',uv_ormode))
	       commandArray['OpenURL']=url..'/json.htm?type=command&param=saveuservariable&vname='..MiscClass.url_encode(uv_ormode)..'&vtype=2&vvalue=1'
	       --	       commandArray['OpenURL']=url..'/json.htm?type=command&param=saveuservariable&vname='..uv_ormode..'&vtype=0&vvalue=1'
	       commandArray['OpenURL']=url..'/json.htm?type=command&param=deleteuservariable&idx='..uservariables_idx[uv_ormode]
	    end   	    
	    print(string.format("Setting new Temperature %02.1f on %s!", newact, devicename)) --XXXXX remove, when done!
	 end
      end
      if (debugmode == 1) then
	 print(string.format("Selected Temperature: (@%02d:%02d): %02.1f", sethour, setmin, newact))
      end
      
   elseif (switchmode == 1) then -- Switch mode (on/off)
      local currmode = otherdevices[devicename]
      if (currmode == newact) then
	 --print("Nothing to switch here!")
      else
	 print(string.format("Switching device \'%s\' %s!",devicename, newact))
	 commandArray[idx]={[devicename]=newact}
--         commandArray[devicename]=newact
      end
      if (debugmode == 1) then
	 print(string.format("Selected Switchmode: (@%02d:%02d): %s", sethour, setmin, newact))	 
      end
   end
   fh:close()
end

--print('iPairs')
--for lu,na,ty,val,idx in ipairs( uservariables ) do
--   print(string.format("%s %s %s %s %s", lu,na,ty,val,idx))
--end
--print('Pairs')
--for lu,na,ty,val,idx in pairs( uservariables ) do
--   print(string.format("%s %s %s %s %s", lu,na,ty,val,idx))
--end



return publicClass
