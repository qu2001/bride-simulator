
local Object = {}

function Object:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.init(o)
    return o
    
end

function Object:init()
end

return Object