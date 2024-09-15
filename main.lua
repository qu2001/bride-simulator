
local matrix    = require("matrix")
local fea       = require("fea")
local roman     = require("roman")
local vector    = require("vector")
local truss     = require("truss")

local points    = {}
local rods      = {}
local bearings  = {}
local forces    = {}

function love.load()

    local E     = 2.1e5
    local A     = 50
    local F     = 3000

    -- Punkte
    points[1]   = {0, 0}
    points[2]   = {1500, 0}
    points[3]   = {1500, -1000}
    points[4]   = {3000, 0}
    points[5]   = {4500, -1000}
    points[6]   = {4500, 0}
    points[7]   = {6000, 0}
    
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
    
end

function love.update()
end

function love.draw()
    love.graphics.line(0,0, 2000,200)
    truss.drawGrid()
end

-- local ww, wh = love.graphics.getDimensions()
-- local points = {}
-- local rods = {}
-- local sPoints = {}
-- local sVec = {}
-- local FVec = {}
-- local AVec = {}

-- local currentSVec = {}
-- local currentFVec = {}
-- local currentAVec = {}

-- local SSCALE = 30
-- local reactions = {}

-- local rodColors = {}

-- local festlager = {}
-- local loslager = {}

-- local PINNED = 1
-- local ROLLER = 2

-- local MAX_TIME = 3

-- local FMax = 0
-- local FMin = 0

-- function setReactions(AVec)
    -- local j=1
    -- for i = 1, AVec.height/2 do
        -- local ax = AVec[(i-1)*2+1]
        -- local ay = AVec[2*i]
        
        -- if not (math.abs(ax) < 0.1 and math.abs(ay) < 0.1) then
            -- local x = sPoints[i][1]/1000
            -- local y = sPoints[i][2]/1000
            
            -- reactions[j] = {x, y, ax, ay, {1,0,0}}
            -- j = j+1
        -- end
            
    -- end
-- end

-- function setSPoints(sVec)
    -- for i = 1,#points do
        -- local sx = sVec[(i-1)*2+1]
        -- local sy = sVec[i*2]
        
        -- local point = points[i]
        -- sPoints[i]  = {point[1]+sx*SSCALE, point[2]+sy*SSCALE}
    -- end
-- end

-- function setRodColor(FVec)

    -- for i = 1, #rods do
        -- local Fi = FVec[i]
        
        -- local R, G, B = 0, 0, 0
        -- if Fi < 0 then
            -- G = 1 - Fi / FMin
            -- R = 1-G
        -- elseif Fi > 0 then
            -- G = 1 - Fi / FMax
            -- B = 1-G
        -- else
            -- G = 1
        -- end
        
        -- rodColors[i] = {R, G, B}
            
    -- end
-- end

-- function toGlobal(xl, yl)
    -- local xg = (xl + 0.5)*100
    -- local yg = wh/2 - yl*100
    
    -- return xg, yg
-- end

-- function love.load()

    -- local E     = 2.1e5
    -- local A     = 50
    -- local F     = 3000
    
    -- -- Punkte
    -- points[1]   = {0, 0}
    -- points[2]   = {1500, 0}
    -- points[3]   = {1500, -1000}
    -- points[4]   = {3000, 0}
    -- points[5]   = {4500, -1000}
    -- points[6]   = {4500, 0}
    -- points[7]   = {6000, 0}
    
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
    
    -- -- Randbedingung
    -- local consts = {}
    -- --      KNR, U/F, X/Y, Wert
    -- consts[1] = {1, 1, 1, 0}
    -- consts[2] = {1, 1, 2, 0}
    -- consts[3] = {2, 2, 2, -F}
    -- consts[4] = {4, 2, 2, -F}
    -- consts[5] = {6, 2, 2, -F}
    -- consts[6] = {7, 1, 2, 0}
    
    -- fea.createStiffness(points, rods)
    -- fea.modifyStiffness(consts)
    -- fea.solve()
    
    -- sVec = fea.getDisplacement()
    -- print('Verschiebung')
    -- for i = 1, sVec.height/2 do
        -- io.write(string.format('%4s ', roman.num2roman(i)))
        -- io.write(string.format('%12g %12g\n', sVec[(i-1)*2+1], sVec[i*2]))
    -- end
    
    -- FVec = fea.getAxials()
    -- print("Stabkraefte")
    -- for i = 1,#rods do
        -- io.write(string.format('%4d ', i))
        -- io.write(string.format('%8g\n', FVec[i]))
    -- end
    
    -- AVec = fea.getReactions()
    -- print("Reaktionskraefte")
    -- for i = 1,AVec.height/2 do
        -- io.write(string.format('%4s ', tostring(i)))
        -- io.write(string.format('%12g %12g\n', AVec[(i-1)*2+1], AVec[i*2]))
    -- end
    
    -- setSPoints(sVec)
    
    -- FMax = math.max(unpack(FVec))
    -- FMin = math.min(unpack(FVec))
    -- setRodColor(FVec)
    
    -- setReactions(AVec)


    -- festlager.img   = love.graphics.newImage("festlager.png")
    -- loslager.img    = love.graphics.newImage("loslager.png")
    
    -- festlager.w     = festlager.img:getWidth()
	-- festlager.h     = festlager.img:getHeight()
    
    -- loslager.w      = loslager.img:getWidth()
	-- loslager.h      = loslager.img:getHeight()
    
-- end

-- function love.update(dt)
    -- local ti = love.timer.getTime() % MAX_TIME
    -- local sc = ti/MAX_TIME
    
    
    -- local currentSVec = vector.scale(sVec, sc)
    -- local currentFVec = vector.scale(FVec, sc)
    -- local currentAVec = vector.scale(AVec, sc) -- sieht komisch aus
    
    -- setSPoints(currentSVec)
    -- setRodColor(currentFVec)
    -- setReactions(currentAVec)
-- end

-- function drawText(text, x, y, fg, bg)
    -- love.graphics.push("all")

	-- local font  = love.graphics.getFont()
	-- local tw    = font:getWidth(text)
	-- local th    = font:getHeight()
    
    -- local xg = (x + 0.5)*100
    -- local yg = wh/2 - y*100
    
    -- love.graphics.setColor(bg)
    -- love.graphics.rectangle("fill", xg-tw/2,yg-th/2, tw,th)
    
    -- love.graphics.setColor(fg)
	-- love.graphics.print(text, xg, yg, 0, 1, 1, tw/2, th/2)
    
    -- love.graphics.pop()
-- end

-- function drawPoint(x, y, s)
    -- local xg = (x + 0.5)*100
    -- local yg = wh/2 - y*100
    
    -- love.graphics.circle("fill", xg, yg, s)
-- end

-- function drawLine(x1, y1, x2, y2)
    -- local x1g = (x1 + 0.5)*100
    -- local y1g = wh/2 - y1*100
    
    -- local x2g = (x2 + 0.5)*100
    -- local y2g = wh/2 - y2*100
    
    -- love.graphics.line(x1g,y1g, x2g,y2g)
-- end

-- function drawVector(x, y, vx, vy, color)
    -- love.graphics.push("all")
    
    -- local SCALE = 5000
    
    -- local x0 = x
    -- local y0 = y
    
    -- local vx = vx/SCALE
    -- local vy = vy/SCALE
    
    -- local x1 = x0-vx
    -- local y1 = y0-vy
    
    -- local x2 = x1 + 0.85*vx
    -- local y2 = y1 + 0.85*vy
    
    -- local nx = -0.05*vy
    -- local ny = 0.05*vx
    
    -- local x3 = x2+nx
    -- local y3 = y2+ny
    
    -- local x4 = x2-nx
    -- local y4 = y2-ny
    
    -- love.graphics.setColor(color)
    -- love.graphics.setLineWidth(2)
    
    -- drawLine(x1, y1, x0, y0)
    -- drawLine(x4, y4, x3, y3)
    -- drawLine(x3, y3, x0, y0)
    -- drawLine(x0, y0, x4, y4)
    
    -- love.graphics.pop()
-- end

-- function drawBearing(x, y, rotation, typ)
    -- local x, y = toGlobal(x, y)
    
    -- if typ == PINNED then
        -- love.graphics.draw(festlager.img, x,y, rotation, 0.2,0.2, festlager.w/2, 0)
    -- elseif typ == ROLLER then
        -- love.graphics.draw(loslager.img, x,y, rotation, 0.2,0.2, loslager.w/2, 0)
    -- end
    
    -- love.graphics.push('all')
    -- love.graphics.setColor(0, 0.7, 0.1)
    -- love.graphics.circle("fill", x, y, 5)
    -- love.graphics.pop()
    
-- end

-- function love.draw()

    -- love.graphics.setColor(0.5, 0.5, 0.5)
    -- love.graphics.setLineWidth(1)
    
    -- -- Verformt
    -- -- for i = 1, #rods do
        -- -- local rod = rods[i]
        -- -- local point1 = sPoints[rod[1]]
        -- -- local point2 = sPoints[rod[2]]
        
        -- -- local x1, y1, x2, y2 = point1[1], point1[2], point2[1], point2[2]
        -- -- x1, y1, x2, y2 = x1/1000, y1/1000, x2/1000, y2/1000
        -- -- drawLine(x1, y1, x2, y2)
    -- -- end
    
    -- for i = 1, #sPoints do
        -- local sPoint = sPoints[i]
        -- local x, y = sPoint[1]/1000, sPoint[2]/1000
        -- drawPoint(x, y, 3)
    -- end

    -- -- unverformt
    -- love.graphics.setLineWidth(4)
    -- for i = 1, #rods do
        -- local rod = rods[i]
        -- local point1 = sPoints[rod[1]]
        -- local point2 = sPoints[rod[2]]
        
        -- local x1, y1, x2, y2 = point1[1], point1[2], point2[1], point2[2]
        -- x1, y1, x2, y2 = x1/1000, y1/1000, x2/1000, y2/1000
        -- love.graphics.setColor(rodColors[i])
        -- drawLine(x1, y1, x2, y2)
        -- drawText(tostring(i), (x1+x2)/2, (y1+y2)/2, {1, 1, 1}, {0, 0, 0})
    -- end
    
    -- -- Punkte
    -- for i = 1, #points do
        -- local sPoint = sPoints[i]
        -- local x, y = sPoint[1]/1000, sPoint[2]/1000
        -- love.graphics.setColor(1, 1, 1)
        -- drawPoint(x, y, 5)
        -- drawText(roman.num2roman(i), x-0.15, y+0.15, {0, 0, 0}, {1, 1, 1})
    -- end
    
    -- drawBearing(sPoints[1][1]/1000, sPoints[1][2]/1000, 0, PINNED)
    -- drawBearing(sPoints[7][1]/1000, sPoints[7][2]/1000, 0, ROLLER)
    
    -- for i,v in ipairs(reactions) do
        -- drawVector(unpack(v))
    -- end


-- end
