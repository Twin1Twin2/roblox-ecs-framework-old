
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local RobloxECSCompiler = require("RobloxECSCompiler")

local RobloxEntityListResource = {
    ClassName = "RobloxEntityListResource";
}

RobloxEntityListResource.__index = RobloxEntityListResource


function RobloxEntityListResource:Create()
    assert(self.Instance ~= nil, "")

    local entityList = RobloxECSCompiler:CompileEntitiesCloned(self.Instance)

    if (#self.ComponentList > 0) then
        for _, entity in pairs(entityList) do
            for _, componentName in pairs(self.ComponentList) do
                
            end
        end
    end

    return entityList
end


function RobloxEntityListResource.new(instance, componentList)
    local this = setmetatable({}, RobloxEntityListResource)

    this.Instance = instance
    this.ComponentList = componentList or {}

    return this
end


return RobloxEntityListResource