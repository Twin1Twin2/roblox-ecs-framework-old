
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local RobloxEntity = require("RobloxEntity")

local RobloxClassWrapperComponents = require("RobloxClassWrapperComponents")

local RobloxECSCompiler = {
    ClassName = "RobloxECSCompiler";
}


function RobloxECSCompiler:_CompileComponentFromInstance(name, instance)
    local componentClass = nil

    local success, _ = pcall(function()
        componentClass = require(name)
    end)

    if (success == false or componentClass == nil) then
        componentClass = RobloxClassWrapperComponents[instance.ClassName]
    end

    assert(componentClass ~= nil, "")
    assert(componentClass.new ~= nil, "")
    assert(type(componentClass.new) == "function", "")

    return componentClass.new(instance)
end


function RobloxECSCompiler:CompileComponent(instance)
    assert(instance ~= nil, "")
    assert(typeof(instance) == "Instance", "")

    local componentData = nil

    if (instance:IsA("ModuleScript") == true) then
        componentData = require(instance)   --old code from when i assumed components would be regular tables

        if (type(componentData) == "function") then
            componentData = componentData(instance)
        elseif (type(componentData) == "table" and componentData.new ~= nil and type(componentData.new) == "function") then
            componentData = componentData.new(instance)
        end
    else
        local componentName = instance.Name
        componentData = RobloxECSCompiler:_CompileComponentFromInstance(componentName, instance)
    end

    return componentData
end


function RobloxECSCompiler:_CompileComponentsToEntity(entity, componentInstances)
    for _, child in pairs(componentInstances) do
        if (child:IsA("Folder") == true) then
            RobloxECSCompiler:_CompileComponentsToEntity(entity, child:GetChildren())
        else
            local component = RobloxECSCompiler:CompileComponent(child)
            entity:AddComponent(component)
        end
    end
end


function RobloxECSCompiler:CompileEntity(instance)
    assert(instance ~= nil, "")
    assert(typeof(instance) == "Instance", "")

    local newEntity = RobloxEntity.new(instance)

    RobloxECSCompiler:_CompileComponentsToEntity(newEntity, instance:GetChildren())

    return newEntity
end


function RobloxECSCompiler:CompileEntityCloned(instance)
    assert(instance ~= nil, "")
    assert(typeof(instance) == "Instance", "")

    local newInstance = instance:Clone()
    newInstance.Parent = nil

    local entity = RobloxECSCompiler:CompileEntity(newInstance)
    
    return entity
end


function RobloxECSCompiler:_CompileEntitiesToTable(t, entityInstances)
    for _, child in pairs(entityInstances) do
        if (child:IsA("Folder") == true) then
            RobloxECSCompiler:_CompileEntitiesToTable(t, child:GetChildren())
        else
            local entity = RobloxECSCompiler:CompileEntity(child)
            table.insert(t, entity)
        end
    end
end


function RobloxECSCompiler:CompileEntities(instance)
    assert(instance ~= nil, "")
    assert(typeof(instance) == "Instance")

    local entityList = {}

    RobloxECSCompiler:_CompileEntitiesToTable(entityList, instance:GetChildren())

    return entityList
end


function RobloxECSCompiler:_CompileEntitiesToTableCloned(t, entityInstances)
    for _, child in pairs(entityInstances) do
        if (child:IsA("Folder") == true) then
            RobloxECSCompiler:_CompileEntitiesToTable(t, child:GetChildren())
        else
            local newInstance = child:Clone()
            newInstance.Parent = nil

            local entity = RobloxECSCompiler:CompileEntity(newInstance)
            table.insert(t, entity)
        end
    end
end


function RobloxECSCompiler:CompileEntitiesCloned(instance)
    assert(instance ~= nil, "")
    assert(typeof(instance) == "Instance")

    local entityList = {}

    RobloxECSCompiler:_CompileEntitiesToTableCloned(entityList, instance:GetChildren())

    return entityList
end

--[[
function RobloxECSCompiler:_CompileEntitiesToScene(scene, entityInstances)
    for _, child in pairs(entityInstances) do
        if (child:IsA("Folder") == true) then
            RobloxECSCompiler:_CompileEntitiesToScene(scene, child:GetChildren())
        else
            local entity = RobloxECSCompiler:CompileEntity(child)
            scene:Add(entity)
        end
    end
end


function RobloxECSCompiler:CompileScene(instance)
    assert(instance ~= nil, "")
    assert(typeof(instance) == "Instance")

    local newScene = RobloxScene.new(instance)

    RobloxECSCompiler:_CompileEntitiesToScene(newScene, instance:GetChildren())

    return newScene
end
--]]

return RobloxECSCompiler