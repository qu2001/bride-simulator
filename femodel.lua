
local Class = Object:new()
local FEModel = Class

function Class:init()
    self.nodes          = self.nodes or {}
    self.lines          = self.lines or {}
    self.materials      = self.materials or {}
    self.constraints    = self.constraints or {}
end

function Class:addNode(x, y)
    self.nodes[#self.nodes+1] = {x, y}
end

function Class:addLine(tag1, tag2)
    self.lines[#self.lines] = {tag1, tag2}
end

function Class:addMaterial(E, A)
    self.materials[#self.materials+1] = {E, A}
end

function Class:addConstraint(nodeTag, foru, xory, value)
    self.constraints[#self.constraints+1] = {nodeTag, foru, xory, value} 
end


return Class