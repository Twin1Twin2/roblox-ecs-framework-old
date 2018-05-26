
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Table = require("Table")

local RobloxSystem = require("RobloxSystem")
local SystemUpdateType = require("SystemUpdateTypeEnums")

local TableContains = Table.Contains

local SystemLockModes = RobloxSystem.LOCKMODES

local LOCKMODE_OPEN = SystemLockModes["Open"]
local LOCKMODE_LOCKED = SystemLockModes["Locked"]
local LOCKMODE_ERROR = SystemLockModes["Error"]

local function AttemptRemovalFromTable(t, value)
	for i, v in pairs(t) do
		if (v == value) then
			table.remove(t, i)
			return true
		end
	end
	
	return false
end

local RobloxWorld = {
    ClassName = "RobloxWorld";
}

RobloxWorld.__index = RobloxWorld


function RobloxWorld:GetEntityFromInstance(instance)
    for _, entity in pairs(self.Entities) do
        if (entity:ContainsInstance(instance) == true) then
            return entity
        end
    end

    return nil
end


function RobloxWorld:GetSystem(systemName)
    for _, system in pairs(self.Systems) do
        if (system.ClassName == systemName) then
            return system
        end
    end

    return nil
end


function RobloxWorld:AddEntity(entity)
    if (TableContains(self._EntitiesToAdd, entity) == false and TableContains(self.Entities, entity) == false) then
        table.insert(self._EntitiesToAdd, entity)
    end
end


function RobloxWorld:AddEntities(...)
    local entityList = {...}

    self:AddEntitiesFromList(entityList)
end


function RobloxWorld:AddEntitiesFromList(entityList)
    for _, entity in pairs(entityList) do
        self:AddEntity(entity)
    end
end


function RobloxWorld:RemoveEntity(entity)
    if (TableContains(self._EntitiesToRemove, entity) == false and TableContains(self.Entities, entity) == true) then
        table.insert(self._EntitiesToRemove, entity)
    end
end


function RobloxWorld:RemoveEntities(...)
    local entityList = {...}

    self:RemoveEntitiesFromList(entityList)
end


function RobloxWorld:RemoveEntitiesFromList(entityList)
    for _, entity in pairs(entityList) do
        self:RemoveEntity(entity)
    end
end


function RobloxWorld:RemoveEntitiesWithComponents(...)
    local components = {...}

    for _, entity in pairs(self.Entities) do
        if (entity:HasComponents(components) == true) then
            self:RemoveEntity(entity)
        end
    end
end


function RobloxWorld:ClearEntities()
    self:RemoveEntitiesFromList(self.Entities)
end


function RobloxWorld:AddSystem(system)
    local updateType = system.UpdateType
    local updateIndex = system.UpdateIndex

    local function InsertInList(systemList)
        local inserted = false

        for i, systemObject in pairs(systemList) do
            if (systemObject.UpdateIndex > updateIndex) then
                table.insert(systemList, i, system)
                inserted = true
                break
            end
        end

        if (inserted == false) then
            table.insert(systemList, system)
        end
    end

    if (updateType == SystemUpdateType["RenderStepped"]) then
        InsertInList(self._RenderSteppedUpdateSystems)
    elseif (updateType == SystemUpdateType["Stepped"]) then
        InsertInList(self._SteppedUpdateSystems)
    elseif (updateType == SystemUpdateType["Heartbeat"]) then
        InsertInList(self._HeartbeatUpdateSystems)
    end

    system.World = self
    table.insert(self.Systems, system)

    system:Initialize()
end


function RobloxWorld:AddSystems(...)
    local systemList = {...}

    self:AddSystemsFromList(systemList)
end


function RobloxWorld:AddSystemsFromList(systemList)
    for _, system in pairs(systemList) do
        self:AddSystem(system)
    end
end


function RobloxWorld:RemoveSystem(system)
    local updateType = system.UpdateType

    local function RemoveFromList(systemList)
        AttemptRemovalFromTable(systemList, system)
    end

    if (updateType == SystemUpdateType["RenderStepped"]) then
        RemoveFromList(self._RenderSteppedUpdateSystems)
    elseif (updateType == SystemUpdateType["RenderStepped"]) then
        RemoveFromList(self._SteppedUpdateSystems)
    elseif (updateType == SystemUpdateType["Heartbeat"]) then
        RemoveFromList(self._HeartbeatUpdateSystems)
    end

    AttemptRemovalFromTable(self.Systems, system)
end


function RobloxWorld:EntityComponentsChanged(entity)
    table.insert(self._EntitiesToUpdate, entity)
end


function RobloxWorld:_EntityBelongsInSystem(system, entity)
    local systemComponents = system.Components

    local hasValidComponents = entity:HasComponents(systemComponents)

    return hasValidComponents
end


function RobloxWorld:_UpdateEntity(entity)  --update after it's components have changed or it was just added
    for _, systemName in pairs(entity.RegisteredSystems) do
        local system = self:GetSystem(systemName)
        
        if (system ~= nil and self:_EntityBelongsInSystem(system, entity) == false) then
            system:RemoveEntity(entity)
        end
    end

    for _, system in pairs(self.Systems) do
        if (self:_EntityBelongsInSystem(system, entity) == true) then
            system:AddEntity(entity)
        end
    end
end


function RobloxWorld:_UpdateEntities()
    if (#self._EntitiesToAdd > 0) then
        for _, entity in pairs(self._EntitiesToAdd) do
            if (TableContains(self.Entities, entity) == false) then
                table.insert(self.Entities, entity)
                table.insert(self._EntitiesToUpdate, entity)

                if (entity.Instance ~= nil) then
                    entity.Instance.Parent = self.RootInstance
                end
            end
        end

        self._EntitiesToAdd = {}
    end

    if (#self._EntitiesToRemove > 0) then
        for _, entity in pairs(self._EntitiesToRemove) do
            if (TableContains(self.Entities, entity) == true) then
                local registeredSystems = {}

                for _, systemName in pairs(entity.RegisteredSystems) do --i'm not sure why this works
                    table.insert(registeredSystems, systemName)
                end

                for _, systemName in pairs(registeredSystems) do
                    local system = self:GetSystem(systemName)
                    if (system ~= nil) then
                        system:RemoveEntity(entity)
                    end
                end

                AttemptRemovalFromTable(self.Entities, entity)
                table.insert(self._EntitiesToUpdateRemoval, entity)
            end
        end

        self._EntitiesToRemove = {}
    end

    if (#self._EntitiesToUpdate > 0) then
        for _, entity in pairs(self._EntitiesToUpdate) do
            if (TableContains(self.Entities, entity) == true and TableContains(self._EntitiesToUpdateRemoval, entity) == false) then
                self:_UpdateEntity(entity)
            end
        end
    end
end


function RobloxWorld:_RemoveEntity(entity)  --remove from root instance and destroy components
    if (entity.Instance ~= nil) then
        entity.Instance.Parent = nil
    end

    entity:Destroy()
end


function RobloxWorld:_UpdateRemovedEntities()   --check if all of the systems have unregistered from the entity before removing instance
    if (#self._EntitiesToUpdateRemoval > 0) then
        for _, entity in pairs(self._EntitiesToUpdateRemoval) do
            local numSystems = entity:GetNumberOfRegisteredSystems()
            if (numSystems == 0) then
                AttemptRemovalFromTable(self._EntitiesToUpdateRemoval, entity)
                self:_RemoveEntity(entity)
            end
        end
    end
end


function RobloxWorld:RenderSteppedUpdate(stepped)
    for _, system in pairs(self._RenderSteppedUpdateSystems) do
        system:SetLockMode(LOCKMODE_ERROR)
        system:Update(stepped)
        system:SetLockMode(LOCKMODE_OPEN)
    end
end


function RobloxWorld:SteppedUpdate(t, stepped)
    self.T = t  --idk

    for _, system in pairs(self._SteppedUpdateSystems) do
        system:SetLockMode(LOCKMODE_ERROR)
        system:Update(stepped)
        system:SetLockMode(LOCKMODE_OPEN)
    end
end


function RobloxWorld:HeartbeatUpdate(stepped)
    self:_UpdateEntities()
    self:_UpdateRemovedEntities()

    for _, system in pairs(self._HeartbeatUpdateSystems) do 
        system:SetLockMode(LOCKMODE_LOCKED)
        system:Update(stepped)
        system:SetLockMode(LOCKMODE_OPEN)
    end
end


function RobloxWorld.new(name)
    local this = setmetatable({}, RobloxWorld)

    this.Name = name or "ECS_WORLD"

    local rootInstance = Instance.new("Folder")
    rootInstance.Name = name
    this.RootInstance = rootInstance

    this.T = 0.0    --idk

    this.Entities = {}

    this._EntitiesToAdd = {}
    this._EntitiesToRemove = {}
    this._EntitiesToUpdate = {}
    this._EntitiesToUpdateRemoval = {}

    this.Systems = {}

    this._RenderSteppedUpdateSystems = {}
    this._SteppedUpdateSystems = {}
    this._HeartbeatUpdateSystems = {}

    return this
end


return RobloxWorld