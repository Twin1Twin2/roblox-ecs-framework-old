
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Table = require("Table")

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

local RobloxEntity = {
    ClassName = "RobloxEntity";
}

RobloxEntity.__index = RobloxEntity


function RobloxEntity:HasComponents(...)
    local components = {...}
    local hasValidComponents = true

    if (type(components[1]) == "table") then
        components = components[1]
    end

    for _, componentName in pairs(components) do
        if (self.Components[componentName] == nil) then
            hasValidComponents = false
        end
    end

    return hasValidComponents
end


function RobloxEntity:ContainsInstance(instance)
    return self.Instance:IsAncestorOf(instance)
end


function RobloxEntity:_ComponentsChanged()
    if (self.World ~= nil) then
        self.World:EntityComponentsChanged(self)
    end
end


function RobloxEntity:GetNumberOfRegisteredSystems()
    return #self.RegisteredSystems
end


function RobloxEntity:GetComponent(componentName)
    return self.Components[componentName]
end


function RobloxEntity:_AddComponent(componentName, component)
    local comp = self.Components[componentName]

    if (comp ~= nil) then
        self:_RemoveComponent(componentName, comp)
    end

    self.Components[componentName] = component

    if (component.Instance ~= nil) then
        component.Instance.Parent = self.Instance
    end
end


function RobloxEntity:AddComponent(component)
    assert(component ~= nil)

    local componentName = component.ClassName

    assert(componentName ~= nil)

    self:_AddComponent(componentName, component)

    self:_ComponentsChanged()
end


function RobloxEntity:AddComponents(...)
    local components = {...}

    self:AddComponentsFromList(components)
end


function RobloxEntity:AddComponentsFromList(components)
    for _, component in pairs(components) do
        local componentName = component.ClassName

        assert(componentName ~= nil, "")

        self:_AddComponent(componentName, component)
    end

    self:_ComponentsChanged()
end


function RobloxEntity:_RemoveComponent(componentName, component)
    self.Components[componentName] = nil

    if (component.Instance ~= nil) then
        component.Instance.Parent = nil
    end

    component:Destroy()
end


function RobloxEntity:RemoveComponent(componentName)
    local component = self:GetComponent(componentName)

    if (component == nil) then
        return
    end

    self:_RemoveComponent(componentName, component)

    self:_ComponentsChanged()
end


function RobloxEntity:RemoveComponents(...)
    local components = {...}

    self:RemoveComponentsFromList(components)
end


function RobloxEntity:RemoveComponentsFromList(components)
    for _, componentName in pairs(components) do
        local component = self:GetComponent(componentName)

        if (component ~= nil) then
            self:_RemoveComponent(componentName, component)
        end
    end

    self:_ComponentsChanged()
end


function RobloxEntity:ClearComponents()
    for componentName, _ in pairs(self.Components) do
        self:_RemoveComponent(componentName)
    end
end


function RobloxEntity:RegisterSystem(system)
    table.insert(self.RegisteredSystems, system.ClassName)
end


function RobloxEntity:UnregisterSystem(system)
    AttemptRemovalFromTable(self.RegisteredSystems, system.ClassName)
end


function RobloxEntity:RemoveSelf()
    if (self.World ~= nil) then
        self.World:RemoveEntity(self)
    end
end


function RobloxEntity:Destroy()
    if (self.Instance ~= nil) then
        self.Instance:Destroy()
    end

    self.World = nil
    self.Components = {}
    self.RegisteredSystems = {}

    setmetatable(self, nil)
end


function RobloxEntity.new(instance)
    local this = setmetatable({}, RobloxEntity)

    if (instance == nil) then
        instance = Instance.new("Model")
    end

    this.Instance = instance

    this.World = nil

    this.Components = {}
    this.RegisteredSystems = {}

    return this
end


return RobloxEntity