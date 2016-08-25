--~/domoticz/scripts/lua/script_time_battery.lua
commandArray = {}
 
-- ==============================
-- Check battery level of devices
-- ==============================
 
--Uservariables
BatteryLevelSetPoint=99
EmailTo="alex@gn8.at"
ReportHour=00
ReportMinute=15
DomoticzIP="192.168.0.99"
DomoticzPort="8080"
Message = 'Batteriestatus'
DeviceFileName = "/var/tmp/JsonAllDevData.tmp"
 
-- Time to run?
time = os.date("*t")
if time.hour == ReportHour and time.min == ReportMinute then
 
    -- Update the list of device names and ids to be checked later
    os.execute("curl 'http://" .. DomoticzIP .. ":" .. DomoticzPort .. "/json.htm?type=devices&order=name' 2>/dev/null| /usr/local/bin/jq -r '.result[]|{(.Name): .idx}' >" .. DeviceFileName)
    BattToReplace = false
 
    -- Retrieve the battery device names from the user variable - stored as name one|name 2|name 3|name forty one
    DevicesWithBatteries = uservariables["DevicesWithBatteries"]
    DeviceNames = {}
    for DeviceName in string.gmatch(DevicesWithBatteries, "[^|]+") do
       DeviceNames[#DeviceNames + 1] = DeviceName
    end
 
    -- Loop round each of the devices with batteries
    for i,DeviceName in ipairs(DeviceNames) do
 
       --Determine device id
       local handle = io.popen("/usr/local/bin/jq -r '.\"" .. DeviceName .. "\" | values' " .. DeviceFileName)
       local DeviceIDToCheckBatteryLevel = handle:read("*n")
       handle:close()
 
       --Determine battery level
       local handle = io.popen("curl 'http://" .. DomoticzIP .. ":" .. DomoticzPort .. "/json.htm?type=devices&rid=" .. DeviceIDToCheckBatteryLevel .. "' 2>/dev/null | /usr/local/bin/jq -r .result[].BatteryLevel")
       local BattLevel = string.gsub(handle:read("*a"), "\n", "")
       handle:close()
       print(DeviceName .. ' batterylevel is ' .. BattLevel .. "%")
 
       -- Check batterylevel against setpoint
       if tonumber(BattLevel) < BatteryLevelSetPoint then
          BattToReplace = true
          print("!!!" .. DeviceName .. " batterylevel below " .. BatteryLevelSetPoint .. "%, current " .. BattLevel .. "%")
          Message = Message .. '\n *** ' .. DeviceName .. ' battery level is ' .. BattLevel .. '%'
       end
    end
 
    -- Only send an email if at least one battery fails the test
    if(BattToReplace) then
       commandArray['SendEmail']='Domoticz Battery Levels#'.. Message .. '#' .. EmailTo
    end
end
 
--LUA default
return commandArray
