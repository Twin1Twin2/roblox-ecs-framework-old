
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Table = require("Table")

local SystemUpdateType = require("SystemUpdateTypeEnums")

local TableContains = Table.Contains

local function AttemptRemovalFromTable(t, value)
    if (value == nil) then
        return
    end

	for i, v in pairs(t) do
		if (v == value) then
			table.remove(t, i)
			return true
		end
	end
	
	return false
end

local LOCKMODE_OPEN = 0
local LOCKMODE_LOCKED = 1
local LOCKMODE_ERROR = 2

local RobloxSystem = {
    ClassName = "RobloxSystem";

    UpdateType = SystemUpdateType["Heartbeat"];
    UpdateIndex = 0;

    LOCKMODES = {
        ["Open"] = LOCKMODE_OPEN;
        ["Locked"] = LOCKMODE_LOCKED;
        ["Error"] = LOCKMODE_ERROR;
    };
}

RobloxSystem.__index = RobloxSystem


function RobloxSystem:_AddEntity(entity)
    if (TableContains(self.Entities, entity) == false) then
        table.insert(self.Entities, entity)

        entity:RegisterSystem(self)

        self:EntityAdded(entity)
    end
end


function RobloxSystem:_RemoveEntity(entity)
    local wasRemoved = AttemptRemovalFromTable(self.Entities, entity)
    if (wasRemoved == true) then
        entity:UnregisterSystem(self)

        self:EntityRemoved(entity)
    end
end


function RobloxSystem:SetLockMode(newLockMode)
    self.LockMode = newLockMode

    if (#self._EntitiesToAdd > 0) then
        for _, entity in pairs(self._EntitiesToAdd) do
            self:_AddEntity(entity)
        end

        self._EntitiesToAdd = {}
    end

    if (#self._EntitiesToRemove > 0) then
        for _, entity in pairs(self._EntitiesToRemove) do
            self:_RemoveEntity(entity)
        end

        self._EntitiesToRemove = {}
    end
end


function RobloxSystem:AddEntity(entity)
    local lockMode = self.LockMode

    if (lockMode == LOCKMODE_OPEN) then
        self:_AddEntity(entity)
    elseif (lockMode == LOCKMODE_LOCKED) then
        if (TableContains(self.Entities, entity) == false and TableContains(self._EntitiesToAdd, entity) == false) then
            table.insert(self._EntitiesToAdd, entity)
        end
    elseif (lockMode == LOCKMODE_LOCKED) then
        error("Cannot add or remove entities at this time!", 2)
    end
end


function RobloxSystem:RemoveEntity(entity)
    local lockMode = self.LockMode

    if (lockMode == LOCKMODE_OPEN) then
        self:_RemoveEntity(entity)
    elseif (lockMode == LOCKMODE_LOCKED) then
        if (TableContains(self.Entities, entity) == true and TableContains(self._EntitiesToRemove, entity) == false) then
            table.insert(self._EntitiesToRemove, entity)
        end
    elseif (lockMode == LOCKMODE_LOCKED) then
        error("Cannot add or remove entities at this time!", 2)
    end
end


function RobloxSystem:Initialize()

end


function RobloxSystem:EntityAdded(entity)

end


function RobloxSystem:EntityRemoved(entity)

end


function RobloxSystem:Update(stepped)

end


function RobloxSystem.new()
    local this = setmetatable({}, RobloxSystem)

    this.LockMode = LOCKMODE_OPEN

    this._EntitiesToAdd = {}
    this._EntitiesToRemove = {}

    this.World = nil
    this.Components = {}    --the names of the components this system needs
    this.Entities = {}

    return this
end


return RobloxSystem