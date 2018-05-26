
local RunService = game:GetService("RunService")

local RobloxECSEngine = {
    ClassName = "RobloxECSEngine";
}

RobloxECSEngine.__index = RobloxECSEngine


function RobloxECSEngine:SetWorld(newWorld)
    self.World = newWorld
    self.World.RootInstance.Parent = workspace
end


function RobloxECSEngine:RenderSteppedUpdate(stepped)
    if (self.World == nil) then
        return
    end

    self.World:RenderSteppedUpdate(stepped)
end


function RobloxECSEngine:SteppedUpdate(t, stepped)
    if (self.World == nil) then
        return
    end

    self.World:SteppedUpdate(t, stepped)
end


function RobloxECSEngine:HeartbeatUpdate(stepped)
    if (self.World == nil) then
        return
    end

    self.World:HeartbeatUpdate(stepped)
end


function RobloxECSEngine.new(world)
    local this = setmetatable({}, RobloxECSEngine)

    this.World = world or nil

    RunService.RenderStepped:Connect(function(stepped)
        this:RenderSteppedUpdate(stepped)
    end)

    RunService.Stepped:Connect(function(t, stepped)
        this:SteppedUpdate(t, stepped)
    end)

    RunService.Heartbeat:Connect(function(stepped)
        this:HeartbeatUpdate(stepped)
    end)

    return this
end


return RobloxECSEngine