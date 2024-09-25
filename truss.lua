
local roman     = require("roman")
local fea       = require("fea")
local color     = require("color")
local canvas    = require("canvas")

local truss = {}

local SCALE = 30

truss.PINNED = 1
truss.ROLLER = 2

local festlager     = {}
local loslager      = {}

local FMax = 0
local FMin = 0

local winW, winH = love.graphics.getDimensions()

function truss.init(axials)
    festlager.img   = love.graphics.newImage("img/festlager.png")
    loslager.img    = love.graphics.newImage("img/loslager.png")
    
    festlager.w     = festlager.img:getWidth()
	festlager.h     = festlager.img:getHeight()
    
    loslager.w      = loslager.img:getWidth()
	loslager.h      = loslager.img:getHeight()
    
    FMax = math.max(unpack(axials))
    FMin = math.min(unpack(axials))
end

function truss.getConstraints(forces, bearings)
    local consts = {}
    local index = 1
    
    for i = 1,#forces do
        local force = forces[i]
        local nodeTag = force[1]
        local fx      = force[2]
        local fy      = force[3]
        consts[index] = {nodeTag, fea.FORCE, fea.XCOORD, fx}
        index = index+1
        consts[index] = {nodeTag, fea.FORCE, fea.YCOORD, fy}
        index = index+1
    end
    
    for i = 1,#bearings do
        local bearing   = bearings[i]
        local nodeTag   = bearing[1]
        local typ       = bearing[2]
        
        if      typ == truss.PINNED then
            consts[index] = {nodeTag, fea.DISP, fea.XCOORD, 0}
            index = index+1
            consts[index] = {nodeTag, fea.DISP, fea.YCOORD, 0}
            index = index+1
        elseif  typ == truss.ROLLER then
            consts[index] = {nodeTag, fea.DISP, fea.YCOORD, 0}
            index = index+1
        end
        
    end

    return consts
end

function truss.drawText(text, x, y, fg, bg)
    love.graphics.push("all")

	local font  = love.graphics.getFont()
	local tw    = font:getWidth(text)
	local th    = font:getHeight()
    
    love.graphics.setColor(bg)
    love.graphics.rectangle("fill", x-tw/2,y-th/2, tw,th)
    
    love.graphics.setColor(fg)
	love.graphics.print(text, x, y, 0, 1, 1, tw/2, th/2)
    
    love.graphics.pop()
end


function truss.drawNodes(nodes)

    local s = 3
    for i = 1,#nodes do
        local node = nodes[i]
        local xl, yl = node[1], node[2]
        local xg, yg = canvas.toGlobal(xl, yl)
        love.graphics.circle("fill", xg, yg, s)
        local text = roman.num2roman(i)
        xg, yg = canvas.toGlobal(xl-100, yl+100)
        truss.drawText(text, xg, yg, color.WHITE, color.BLACK)
    end
    
end

function truss.drawMembers(members, nodes, colors)
love.graphics.push("all")

    for i = 1,#members do
        local member  = members[i]
        local rgb   = colors[i]
        
        local nodeTag1, nodeTag2 = member[1], member[2]
        local node1, node2 = nodes[nodeTag1], nodes[nodeTag2]
        
        local x1, y1 = canvas.toGlobal(node1[1], node1[2])
        local x2, y2 = canvas.toGlobal(node2[1], node2[2])
        
        love.graphics.setColor(rgb)
        love.graphics.line(x1,y1, x2,y2)
        truss.drawText(tostring(i), (x1+x2)/2, (y1+y2)/2, rgb, color.BLACK)
    end
    
love.graphics.pop()
end

function truss.drawBearings(bearings, nodes)

    for i = 1,#bearings do
        local bearing   = bearings[i]
        local nodeTag   = bearing[1]
        local typ       = bearing[2]
        local rotation  = bearing[3]
        local node      = nodes[nodeTag]
        local x, y      = node[1], node[2]
        x, y            = canvas.toGlobal(x, y)
        
        if typ == truss.PINNED then
            love.graphics.draw(festlager.img, x,y, rotation, 0.2,0.2, festlager.w/2, 0)
        elseif typ == truss.ROLLER then
            love.graphics.draw(loslager.img, x,y, rotation, 0.2,0.2, loslager.w/2, 0)
        end
        
        love.graphics.push('all')
        love.graphics.setColor(color.GREEN)
        love.graphics.circle("fill", x, y, 5)
        love.graphics.pop()
    
    end

end

function truss.drawVectors(forces, nodes)
love.graphics.push('all')

    local SCALE = 100
    
    for i = 1, #forces do
        local force     = forces[i]
        local nodeTag   = force[1]
        local vx, vy    = force[2], force[3]
        local node      = nodes[nodeTag]
        local x, y      = canvas.toGlobal(node[1], node[2])
    
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
        
        love.graphics.setColor(color.RED)
        love.graphics.setLineWidth(2)
        
        love.graphics.line(x1, y1, x0, y0)
        love.graphics.line(x4, y4, x3, y3)
        love.graphics.line(x3, y3, x0, y0)
        love.graphics.line(x0, y0, x4, y4)
    end
        


love.graphics.pop()
end

function truss.heatmapColor(F)
    local R, G, B = 0, 0, 0
    if F < 0 then
        G = 1 - F / FMin
        R = 1-G
    elseif F > 0 then
        G = 1 - F / FMax
        B = 1-G
    else
        G = 1
    end
    
    local color = {R, G, B}
    return color
end

function truss.drawHeatmap()
love.graphics.push('all')

    local n = 100
    local span = math.abs(FMin) + math.abs(FMax)
    local deltaF = span/n
    local F = FMin
    
    for i = 1,n do
        local color = truss.heatmapColor(F)
        F = F + deltaF
        love.graphics.setColor(color)
        love.graphics.line(winW-120, 100+2*i, winW-110, 100+2*i)
        
        if (i-1)%10 == 0 then
            local str = string.format("%.f", F)
            love.graphics.print(str, winW-105, 100+2*i, 0, 1, 1, 0, 0)
        end
    end

love.graphics.pop()
end

function truss.drawTruss(nodes, members, bearings, axials, nodeDisps, forces)
    local colors = {}
    for i = 1,#axials do
        colors[i] = truss.heatmapColor(axials[i])
    end
    
    local newNodes = {}
    for i = 1,#nodes do
        local sx = nodeDisps[(i-1)*2+1]
        local sy = nodeDisps[i*2]
        local node = nodes[i]
        newNodes[i]  = {node[1]+sx*SCALE, node[2]+sy*SCALE}
    end
    
    
    truss.drawMembers(members, newNodes, colors)
    truss.drawNodes(newNodes)
    truss.drawBearings(bearings, newNodes)
    truss.drawVectors(forces, newNodes)
    
    truss.drawHeatmap()
end

return truss
