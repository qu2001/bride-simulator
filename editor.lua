
local color = require("color")
local truss = require("truss")

local editor = {}


local canvas = {}
local gridPoints = {}
local lines = {}
local bearings = {}
local forces = {}

local festlager     = {}
local loslager      = {}

local winW, winH = love.graphics.getDimensions()

local nodes = {}
local members = {}
local bears = {}
local frcs = {}

local E     = 2.1e5
local A     = 50

function editor.init(fcanvas)
    canvas = fcanvas
    
    festlager.img   = love.graphics.newImage("img/festlager.png")
    loslager.img    = love.graphics.newImage("img/loslager.png")
    
    festlager.w     = festlager.img:getWidth()
	festlager.h     = festlager.img:getHeight()
    
    loslager.w      = loslager.img:getWidth()
	loslager.h      = loslager.img:getHeight()
end

function editor.addForce(fx, fy)
    if #gridPoints ~= 1 then
        print("WARNING: Number of marked points must be one.")
        return
    end
    
    local i, j = gridPoints[1].i, gridPoints[1].j
    local force = {}
    force.i = i
    force.j = j
    force.fx = fx
    force.fy = fy
    
    forces[#forces+1] = force
end

function editor.drawForces()
love.graphics.push('all')

    local SCALE = 100

    love.graphics.setColor(color.RED)
    love.graphics.setLineWidth(2)
    
    local dx,dy = canvas.getDXY()
    local x,y
    
    for i,force in ipairs(forces) do
        local vx, vy    = force.fx, force.fy
        x = force.i*dx
        y = force.j*dy
        x, y = canvas.toGlobal(x, y)
    
        local x0 = x
        local y0 = y
        
        local vx = vx/SCALE
        local vy = -vy/SCALE
        
        local x1 = x0-vx
        local y1 = y0-vy
        
        local x2 = x1 + 0.85*vx
        local y2 = y1 + 0.85*vy
        
        local nx = -0.05*vy
        local ny = 0.05*vx
        
        local x3 = x2+nx
        local y3 = y2+ny
        
        local x4 = x2-nx
        local y4 = y2-ny
        
        love.graphics.line(x1, y1, x0, y0)
        love.graphics.line(x4, y4, x3, y3)
        love.graphics.line(x3, y3, x0, y0)
        love.graphics.line(x0, y0, x4, y4)
    end

love.graphics.pop()
end

function editor.deleteForce()
    if #gridPoints ~= 1 then
        print("WARNING: Number of marked points must be one.")
        return
    end
    
    local i, j = gridPoints[1].i, gridPoints[1].j
    local index = nil
    for k,force in ipairs(forces) do
        if i == force.i and j == force.j then
            index = k
            break
        end
    end
    if index ~= nil then
        table.remove(forces, index)
    end
end

function editor.addBearing(typ)
    if #gridPoints ~= 1 then
        error("Number of marked points must be one.")
    end
    
    local i, j = gridPoints[1].i, gridPoints[1].j
    
    local bearing = {}
    bearing.type    = typ
    bearing.i       = i
    bearing.j       = j
    
    bearings[#bearings+1] = bearing
end

function editor.drawBearings()
love.graphics.push('all')

    local dx,dy = canvas.getDXY()
    local x,y
    local rotation = 0
    for i,bearing in ipairs(bearings) do
        x = bearing.i*dx
        y = bearing.j*dy
        
        x,y = canvas.toGlobal(x,y)
        
        if bearing.type == truss.PINNED then
            love.graphics.draw(festlager.img, x,y, rotation, 0.2,0.2, festlager.w/2, 0)
        elseif bearing.type == truss.ROLLER then
            love.graphics.draw(loslager.img, x,y, rotation, 0.2,0.2, loslager.w/2, 0)
        end
        
        love.graphics.setColor(color.GREEN)
        love.graphics.circle("fill", x, y, 5)
    end

love.graphics.pop()    
end

function editor.deleteBearing()
    if #gridPoints ~= 1 then
        print("WARNING: Number of marked points must be one.")
        return
    end
    
    local i, j = gridPoints[1].i, gridPoints[1].j
    local index = nil
    for k,bear in ipairs(bearings) do
        if i == bear.i and j == bear.j then
            index = k
            break
        end
    end
    if index ~= nil then
        table.remove(bearings, index)
    end
    
end

function editor.gridPoint(x, y)

    local dx, dy = canvas.getDXY()

    x = math.floor(x/dx+0.5)
    y = math.floor(y/dy+0.5)
    return x, y
end

function editor.addPoint(i, j)

    local l = #gridPoints
    local gridPoint = {}
    gridPoint.i = i
    gridPoint.j = j
    gridPoints[l+1] = gridPoint

end

function editor.drawPoints()
love.graphics.push("all")

    love.graphics.setColor(color.RED)
    local dx, dy = canvas.getDXY()

    local gridPoint = {}
    local x,y
    for i = 1,#gridPoints do
    
        gridPoint = gridPoints[i]
        x = gridPoint.i * dx
        y = gridPoint.j * dy
        
        x,y = canvas.toGlobal(x, y)
        love.graphics.circle("fill", x, y, 5)
    
    end
    
love.graphics.pop()
end

function editor.addLine()

    if #gridPoints ~= 2 then
        print("WARNING: Number of marked points must be two.")
        return
    end
    
    local i1, i2, j1, j2
    i1, j1 = gridPoints[1].i, gridPoints[1].j
    i2, j2 = gridPoints[2].i, gridPoints[2].j


    local line = {}
    line.i1 = i1
    line.i2 = i2
    line.j1 = j1
    line.j2 = j2
    
    lines[#lines+1] = line

end

function editor.clearMarks()
    gridPoints = {}
end

function editor.drawLines()
love.graphics.push("all")

    love.graphics.setColor(color.WHITE)
    local dx, dy = canvas.getDXY()
    
    local x1, x2, y1, y2
    
    for i,line in ipairs(lines) do
    
        x1 = line.i1*dx
        x2 = line.i2*dx
        
        y1 = line.j1*dy
        y2 = line.j2*dy
        
        x1,y1 = canvas.toGlobal(x1, y1)
        x2,y2 = canvas.toGlobal(x2, y2)
        
        love.graphics.line(x1,y1, x2,y2)
        
        love.graphics.circle("fill", x1, y1, 3)
        love.graphics.circle("fill", x2, y2, 3)
    end    

love.graphics.pop()
end

function editor.deleteLine()
    if #gridPoints ~= 1 then
        print("WARNING: Number of marked points must be one.")
        return
    end
    
    local i, j = gridPoints[1].i, gridPoints[1].j
    local index = nil
    for k,line in ipairs(lines) do
        if (i == line.i1 and j == line.j1) or (i == line.i2 and j == line.j2) then
            index = k
            break
        end
    end
    if index ~= nil then
        table.remove(lines, index)
    end
    
end

function editor.find(node, nodes)

    local index
    
    for i,n in ipairs(nodes) do
    
        if n.i == node.i and n.j == node.j then
            index = i
            break
        end
    end
    
    return index

end

function editor.extractNodes()

    local node = {}
    nodes = {}
    
    for i,line in ipairs(lines) do
        node = {}
        node.i = line.i1
        node.j = line.j1
        
        if editor.find(node, nodes) == nil then
            nodes[#nodes+1] = node
        end
        
        node = {}
        node.i = line.i2
        node.j = line.j2
        
        if editor.find(node, nodes) == nil then
            nodes[#nodes+1] = node
        end
        
    end

end

function editor.extractMembers()

    members = {}
    
    for i,line in ipairs(lines) do
    
        local member = {}
    
        local node = {}
        node.i = line.i1
        node.j = line.j1
        
        member[1] = editor.find(node, nodes)
        
        local node = {}
        node.i = line.i2
        node.j = line.j2
        
        member[2] = editor.find(node, nodes)
        
        member[3] = E*A
        
        members[i] = member
        
    
    end


end

function editor.extractBearings()

    bears = {}
    
    for i,b in ipairs(bearings) do
    
        local bear = {}
        local node = {}
        node.i = b.i
        node.j = b.j
        
        bear[1] = editor.find(node, nodes)
        bear[2] = b.type
        bear[3] = 0
        
        bears[i] = bear
    
    end



end

function editor.extractForces()

    frcs = {}
    
    for i,f in ipairs(forces) do
    
        local frc = {}
        
        local node = {}
        node.i = f.i
        node.j = f.j
        
        frc[1] = editor.find(node, nodes)
        frc[2] = f.fx
        frc[3] = f.fy
        
        frcs[i] = frc
    end
    
end

function editor.getTruss()
    
    local trs = {}
    local dx,dy = canvas.getDXY()
    
    editor.extractNodes()
    editor.extractMembers()
    editor.extractBearings()
    editor.extractForces()
    
    trs.points      = {}
    trs.rods        = {}
    trs.bearings    = {}
    trs.forces      = {}
    
    for i,node in ipairs(nodes) do
    
        trs.points[i] = {node.i*dx, node.j*dy}
    
    end
    
    trs.rods        = members
    trs.bearings    = bears
    trs.forces      = frcs
    
    
    return trs

end


return editor