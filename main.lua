
Object          = require 'object'

local Matrix    = require 'matrix2'
local solver    = require 'solver'

local matrix    = require("matrix")
local fea       = require("fea")
local vector    = require("vector")
local truss     = require("truss")
local roman     = require("roman")
local canvas    = require("canvas")
local editor    = require("editor")

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

local SIM = false
local EDIT = true
local trs = {}

local winW, winH = love.graphics.getDimensions()

function drawHelp()
    txt = [[
        c: connect to line
        d: delete marked point
        l: delete line
        p: add pinned bearing
        r: add roller bearing
        b: delete bearing
        f: add force vector
        v: delete force vector
        
        s: simulate
        e: edit
    ]]
    
    love.graphics.print(txt, winW-175, winH-400)
end

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

function calc()
    consts = truss.getConstraints(forces, bearings)    
    
    fea.createStiffness(points, rods)
    fea.modifyStiffness(consts)
    print("SOLVING")
    fea.solve()
    
    displacements = fea.getDisplacement()
    axials        = fea.getAxials()
    reactions     = fea.getReactions()
    
    printResults(displacements, axials, reactions)
    
    truss.init(axials)
end

function love.load()

    local L = Matrix:new{
        elements    = {
          0.04,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,
          0.45,  0.67,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,
          0.88,  0.34,  0.77,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,
          0.33,  0.02,  0.88,  0.11,  0.00,  0.00,  0.00,  0.00,  0.00,
          0.20,  0.41,  0.51,  0.85,  0.86,  0.00,  0.00,  0.00,  0.00,
          0.90,  0.28,  0.12,  0.09,  0.56,  0.44,  0.00,  0.00,  0.00,
          0.69,  0.73,  0.35,  0.85,  0.00,  0.50,  0.19,  0.00,  0.00,
          0.47,  0.43,  0.36,  0.64,  0.94,  0.48,  0.93,  0.19,  0.00,
          0.57,  0.20,  0.73,  0.91,  0.14,  0.71,  0.51,  0.90,  0.66,
        },
        width       = 9,
        height      = 9,
    }
    
    local x = Matrix:new{
        elements    = {32, 5, -7, 5, 1, 32, 21, 3, -34},
        width       = 1,
        height      = 9
    }
    
    local A = L * L:T()
    local b = A*x
    
    t0 = os.clock()
    x = solver(A, b, 'cholesky')
    print(os.clock() - t0)
    
    t0 = os.clock()
    x = solver(A, b, 'cramer')
    print(os.clock() - t0)


    -- local E     = 2.1e5
    -- local A     = 50
    -- local F     = 3000

    -- -- Punkte
    -- points[1]   = {-3000, 0}
    -- points[2]   = {-1500, 0}
    -- points[3]   = {-1500, -1000}
    -- points[4]   = {0, 0}
    -- points[5]   = {1500, -1000}
    -- points[6]   = {1500, 0}
    -- points[7]   = {3000, 0}
    
    -- -- Stabelemente
    -- rods[1]     = {1, 2, E*A}
    -- rods[2]     = {1, 3, E*A}
    -- rods[3]     = {2, 3, E*A}
    -- rods[4]     = {2, 4, E*A}
    -- rods[5]     = {3, 4, E*A}
    -- rods[6]     = {3, 5, E*A}
    -- rods[7]     = {4, 5, E*A}
    -- rods[8]     = {4, 6, E*A}
    -- rods[9]     = {6, 5, E*A}
    -- rods[10]    = {6, 7, E*A}
    -- rods[11]    = {5, 7, E*A}
    
    -- -- Lager
    -- bearings[1] = {1, truss.PINNED, 0}
    -- bearings[2] = {7, truss.ROLLER, 0}
    
    -- -- Kräfte
    -- forces[1]   = {2, 0, -F}
    -- forces[2]   = {4, 0, -F}
    -- forces[3]   = {6, 0, -F}
    
    -- consts = truss.getConstraints(forces, bearings)    
    
    -- fea.createStiffness(points, rods)
    -- fea.modifyStiffness(consts)
    -- fea.solve()
    
    -- displacements = fea.getDisplacement()
    -- axials        = fea.getAxials()
    -- reactions     = fea.getReactions()
    
    -- printResults(displacements, axials, reactions)
    
    canvas.init(1000, 650, 50, 50, 8000, 6000)
    editor.init(canvas)
    
end

function love.update()

    if SIM then
        local ti = love.timer.getTime() % MAX_TIME
        local sc = ti/MAX_TIME
        
        for i = 1,#forces do
            force = forces[i]
            newForces[i] = {force[1], force[2]*sc, force[3]*sc}
        end
        newDisps        = vector.scale(displacements, sc)
        newAxials       = vector.scale(axials, sc)
        
    end
    
end

function love.draw()

    canvas.drawGrid(12, 16)

    if SIM then
        truss.drawTruss(points, rods, bearings, newAxials, newDisps, newForces)
    end
    
    if EDIT then
        editor.drawLines()
        editor.drawBearings()
        editor.drawForces()
        editor.drawPoints()
    end
    drawHelp()
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 and EDIT then
        x, y = canvas.toLocal(x, y)
        x, y = editor.gridPoint(x, y)
        editor.addPoint(x, y)
    end
end

function love.keypressed(key, scancode, isrepeat)

    if key == 'c' and EDIT then
        editor.addLine()
        editor.clearMarks()
    elseif key == 'd' and EDIT then
        editor.clearMarks()
    elseif key == 'l' and EDIT then
        editor.deleteLine()
        editor.clearMarks()
    elseif key == 'p' and EDIT then
        editor.addBearing(truss.PINNED)
        editor.clearMarks()
    elseif key == 'r' and EDIT then
        editor.addBearing(truss.ROLLER)
        editor.clearMarks()
    elseif key == 'b' and EDIT then
        editor.deleteBearing()
        editor.clearMarks()
    elseif key == 'f' and EDIT then
        local fx, fy
        print("Input FX FY:")
        fx,fy = io.read("*n","*n")
        editor.addForce(fx, fy)
        editor.clearMarks()
    elseif key == 'v' and EDIT then
        editor.deleteForce()
        editor.clearMarks()
    elseif key == 'e' then
        SIM = false
        EDIT = true
    elseif key == 's' then
        trs = editor.getTruss()
        
        points      = trs.points
        rods        = trs.rods
        bearings    = trs.bearings
        forces      = trs.forces
        calc()
        
        SIM = true
        EDIT = false
    end
    

end