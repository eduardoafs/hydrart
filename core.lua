------------------------------
-- Core of HydraRT
-- @Author Cleonice 
-- 
-- [Functions]
-- LoadZone - Callback for ZONE_CHANGED_NEW_AREA, automatically loads addon for each zone
-- DisplayDebugMessage - Debug messages
-- DisplayUserMessage - User messages


local _G = _G
local pairs = pairs

HydraRT = CreateFrame("FRAME", "HydraFrame");
HydraRT:RegisterEvent("ZONE_CHANGED_NEW_AREA");

HydraRT.debugActive = true;

function LoadZone(self, zoneChangedEvent, ...)
	-- Unload All Loaded Zones
	-- TODO
	
	-- Load new zone addon
	

	_name, _type = GetInstanceInfo()
	
    local currentZone = gsub(_name,"%s+", "") -- Removing empty spaces

	if _type ~= "raid" then 
		HydraRT:DisplayDebugMessage("info", "LoadZone", currentZone .. " is not a raid.")
		return
	end
	
	HydraRT:DisplayDebugMessage("info", "LoadZone", "HydraRaidTools_"..currentZone .. " called.")
	local loaded, reason = LoadAddOn("HydraRaidTools_"..currentZone)
	
	if not loaded then
		if reason == "MISSING" then
		    HydraRT:DisplayDebugMessage("error", "LoadZone", "Addon for ".. currentZone.. " not found.")
		else HydraRT:DisplayDebugMessage("error", "LoadZone", GetZoneText() ..  " " .. reason)
		end 
		--else HydraRT:DisplayUserMessage("error", "LoadZone", currentZone, reason)
	else HydraRT:AddLoadedModule("HydraRaidTools_"..currentZone) 	-- Add addon to the loaded list
	end
end

HydraRT:SetScript("OnEvent", LoadZone);

function HydraRT:DisplayDebugMessage(kind, fun, arg1, arg2, arg3)
	if not HydraRT.debugActive then return end -- If debuf is off, do nothing
	
	local prefix = ""
	if kind=="error" then prefix = "[ERROR] fuction %s" 
	else if kind == "info" then prefix = "[INFO] function %s" end
	end
	
	print(format(prefix,fun).. ": " ..arg1)
end

function HydraRT:AddLoadedModule() 
	HydraRT:DisplayDebugMessage("info", "AddLoadedModule","called")
end

-- testing
function HydraRT:aura_test()
	local raid_groups = { {}, {}, {}, {} }
	
    local playerGUIDs = {
        {},
        {}
    }
	for i=1,20 do
		local name, _, g = GetRaidRosterInfo(i)
		if g == 3 or g == 4 then 
			playerGUIDs[g-2][#playerGUIDs[g-2]+1] = name --UnitGUID(unit)
		end
		raid_groups[g][#raid_groups[g]+1] = name -- UnitGUID(name)
	end
	-- additional last 2 of g2 
	playerGUIDs[1][6] = raid_groups[2][4]
	playerGUIDs[2][6] = raid_groups[2][5]

	print(format("G1: %s %s %s %s %s %s", playerGUIDs[1][1], playerGUIDs[1][2],playerGUIDs[1][3],playerGUIDs[1][4],playerGUIDs[1][5],playerGUIDs[1][6]))
	print(format("G2: %s %s %s %s %s %s", playerGUIDs[2][1], playerGUIDs[2][2],playerGUIDs[2][3],playerGUIDs[2][4],playerGUIDs[2][5],playerGUIDs[2][6]))
end

print("[HydraRT] Load Complete")

