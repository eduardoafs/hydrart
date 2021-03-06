----------------------
-- Core of HydraRT  --
-- @Author Cleonice --
-- -------------------


local _G = _G
local pairs = pairs

HydraRT = CreateFrame("FRAME", "HydraFrame");
HydraRT:RegisterEvent("ZONE_CHANGED_NEW_AREA");
HydraRT:RegisterEvent("GROUP_ROSTER_UPDATE");

HydraRT.debugActive = true;

HydraRT.options = HydraRT.options or {}

function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

-- Init the options, for the first time run
if table.empty(HydraRT.options) then 
	HydraRT.options.combatLog = {}
end

function HydraEventHandler(self, event, ...) 
	if event=="ZONE_CHANGED_NEW_AREA" then 
		HydraRT:LoadZone()
	elseif event=="GROUP_ROSTER_UPDATE" then
		HydraRT.groups, HydraRT.tank, HydraRT.heal, HydraRT.dps = HydraRT:RaidGroups()
	end
end

function HydraRT:LoadZone()
	-- Unload All Loaded Zones
	-- TODO
	
	-- Load new zone addon
	

	_name, _type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapId = GetInstanceInfo()
	
    local currentZone = gsub(_name,"%s+", "") -- Removing empty spaces

	if _type ~= "raid" then 
		HydraRT:DisplayDebugMessage("info", "LoadZone", currentZone .. " is not a raid.")
		-- Start combat log
		if (HydraRT.options.combatLog[instanceMapID]) then
			if HydraRT.options.combatLog[instanceMapID][difficultyIndex] then 
				LoggingCombat(true)
				HydraRT:DisplayDebugMessage("info","CombatLog","CombatLog enabled")
			else
				HydraRT:DisplayDebugMessage("info","CombatLog","CombatLog is not enabled for this zone, check options to enable it.")			
			end
		end
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

function HydraRT:enableCombatLogCurrentZone()
	_name, _type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapId = GetInstanceInfo()
	HydraRT.options.combatLog[instanceMapID][difficultyIndex] = true
	HydraRT:DisplayDebugMessage("info","CombatLog","Enabled for this zone")
	LoggingCombat(true)
end

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


--------------------------------------
-- Support functions for weak auras --
--------------------------------------

-- Raid groups
-- @returns groups - array with the groups
-- @returns tank - tank list, ordened
-- @returns heal - healer list, ordened
-- @returns dps - dps list, ordened
function HydraRT:RaidGroups()
	local raid_groups = { }
	local tank = {}
	local heal = {}
	local dps = {}
	for i=1,GetNumGroupMembers() do
		local unit = "raid"..i
		local name, _, g = GetRaidRosterInfo(i)
		if raid_groups[g] == nil then raid_groups[g] = { } end
		raid_groups[g][#raid_groups[g]+1] = name
		local role = UnitGroupRolesAssigned(unit)
		
		if (role=="TANK") then 
			tank[#tank+1] = name
		elseif (role=="HEALER") then 
			heal[#heal+1] = name
		elseif (role=="DAMAGER") then 
			dps[#dps+1] = name
		end
	end
	return raid_groups, tank, heal, dps
end

HydraRT:SetScript("OnEvent", HydraEventHandler);
