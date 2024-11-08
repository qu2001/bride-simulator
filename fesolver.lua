
local Matrix = require 'matrix2'
local solver = require 'solver'


local Class = Object:new()

local FESolver = Class

FESolver.DISP      = 1
FESolver.FORCE     = 2

FESolver.XCOORD    = 1
FESolver.YCOORD    = 2

function Class:init()

    if self.femodel == nil then
        error('Class needs femodel.')
    end
    
    self.KCreated      = true
    self.KModCreated   = false
    self.isSolved      = false
    
end

function Class:createStiffness()

    self.v      = {}
    self.vLen   = {}
    self:createLinevectors()
    
end

function Class:createLinevectors()
    
    for i = #femodel.lines do
    
        self.v[i] = {}
        local tag1 = femodel.lines[i][1]
        local tag2 = femodel.lines[i][2]
        local x1, x2   = femodel.nodes[tag1][1], femodel.nodes[tag2][1]
        local y1, y2   = femodel.nodes[tag1][2], femodel.nodes[tag2][2]
        self.v[i][1] = x1 - x2
        self.v[i][2] = y1 - y2
        self.v[i].width  = 1
        self.v[i].height = 2
        
        self.vLen[i] = math.sqrt(self.v[i][1]^2 + self.v[i][2]^2)
    
    end
    
    
    
end

function Class:createRotationmatrix()

    -- TODO
end


return Class
