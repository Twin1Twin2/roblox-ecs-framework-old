
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local RobloxECSCompiler = require("RobloxECSCompiler")


local RobloxEntityResource = {
    ClassName = "RobloxEntityResource";
}

RobloxEntityResource.__index = RobloxEntityResource


function RobloxEntityResource:Create(...)  --returns an entity using the resource
    local components = {...}

    assert(self.Instance ~= nil, "")

    local entity = RobloxECSCompiler:CompileEntityCloned(self.Instance)

    return entity
end


function RobloxEntityResource.new(instance)
    local this = setmetatable({}, RobloxEntityResource)

    this.Instance = instance

    return this
end


return RobloxEntityResource