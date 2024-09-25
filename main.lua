
local matrix    = require("matrix")
local fea       = require("fea")
local vector    = require("vector")
local truss     = require("truss")
local roman     = require("roman")
local canvas    = require("canvas")

local points    = {}
local rods      = {}
local bearings  = {}
local forces    = {}
local newForces = {}

local consts    = {}
local colors    = {}

local displacements = {}
local newDisps      = {}
local axials        = {}
local newAxials     = {}
local reactions     = {}

local MAX_TIME = 3

function printResults(sVec, FVec, AVec)
    print('Verschiebung')
    for i = 1, sVec.height/2 do
        io.write(string.format('%4s ', roman.num2roman(i)))
        io.write(string.format('%12g %12g\n', sVec[(i-1)*2+1], sVec[i*2]))
    end
    
    print("Stabkraefte")
    for i = 1,#rods do
        io.write(string.format('%4d ', i))
        io.write(string.format('%8g\n', FVec[i]))
    end
    
    print("Reaktionskraefte")
    for i = 1,AVec.height/2 do
        io.write(string.format('%4s ', tostring(i)))
        io.write(string.format('%12g %12g\n', AVec[(i-1)*2+1], AVec[i*2]))
    end
end

function love.load()

    local E     = 2.1e5
    local A     = 50
    local F     = 3000

    -- Punkte
    points[1]   = {-3000, 0}
    points[2]   = {-1500, 0}
    points[3]   = {-1500, -1000}
    points[4]   = {0, 0}
    points[5]   = {1500, -1000}
    points[6]   = {1500, 0}
    points[7]   = {3000, 0}
    
    -- Stabelemente
    rods[1]     = {1, 2, E*A}
    rods[2]     = {1, 3, E*A}
    rods[3]     = {2, 3, E*A}
    rods[4]     = {2, 4, E*A}
    rods[5]     = {3, 4, E*A}
    rods[6]     = {3, 5, E*A}
    rods[7]     = {4, 5, E*A}
    rods[8]     = {4, 6, E*A}
    rods[9]     = {6, 5, E*A}
    rods[10]    = {6, 7, E*A}
    rods[11]    = {5, 7, E*A}
    
    -- Lager
    bearings[1] = {1, truss.PINNED, 0}
    bearings[2] = {7, truss.ROLLER, 0}
    
    -- Kräfte
    forces[1]   = {2, 0, -F}
    forces[2]   = {4, 0, -F}
    forces[3]   = {6, 0, -F}
    
    consts = truss.getConstraints(forces, bearings)    
    
    fea.createStiffness(points, rods)
    fea.modifyStiffness(consts)
    fea.solve()
    
    displacements = fea.getDisplacement()
    axials        = fea.getAxials()
    reactions     = fea.getReactions()
    
    printResults(displacements, axials, reactions)
    
    canvas.init(1000, 650, 50, 50, 8000, 6000)
    truss.init(axials)
    
end

function love.update()
    local ti = love.timer.getTime() % MAX_TIME
    local sc = ti/MAX_TIME
    
    for i = 1,#forces do
        force = forces[i]
        newForces[i] = {force[1], force[2]*sc, force[3]*sc}
    end
    newDisps        = vector.scale(displacements, sc)
    newAxials       = vector.scale(axials, sc)
    
end

function love.draw()
    canvas.drawGrid(12, 16)
    canvas.drawPoints()
    truss.drawTruss(points, rods, bearings, newAxials, newDisps, newForces)
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        x, y = canvas.toLocal(x, y)
        x, y = canvas.gridPoint(x, y)
        canvas.addPoint(x, y)
    end
end