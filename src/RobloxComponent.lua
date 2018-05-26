
local RobloxComponent = {
    ClassName = "RobloxComponent";
}

RobloxComponent.__index = RobloxComponent


function RobloxComponent:IsComponent()
    return true
end


function RobloxComponent:Destroy()
     if (self.Instance ~= nil) then
        self.Instance:Destroy()
     end
     
     setmetatable(self, nil)
end


function RobloxComponent.new(instance, className)
    local this = setmetatable({}, RobloxComponent)

    if (instance == nil) then
        instance = Instance.new("Model")
        instance.Name = RobloxComponent.ClassName
    elseif (typeof(instance) ~= "Instance") then
        error("RobloxComponent :: new() - Argument [1] is not an Instance! TypeOf [1] = " .. typeof(instance), 2)
    end

    this.Instance = instance

    return this
end


return RobloxComponent