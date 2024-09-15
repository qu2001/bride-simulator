
local truss = {}

truss.PINNED = 1
truss.ROLLER = 2

local GRAY = {0.5, 0.5, 0.5}

function truss.toGlobal(xl, yl)
    local x, y
    local wApo, hApo
    local winW, winH = love.graphics.getDimensions()
    local wl = 8000
    local hl = 6000
    
    wApo = winW-200
    hApo = winH-100
    
    x = xl*wApo/wl + 50
    y = -(yl*hApo/hl) + winH/2
    
    return x,y
end

function truss.drawGrid()
love.graphics.push("all")

    love.graphics.setColor(GRAY)
    local x1 = 0
    local y1 = 3000
    
    local x2 = 8000
    local y2 = 3000
    for i = 0, 6 do
        local a1, b1 = truss.toGlobal(x1, y1)
        local a2, b2 = truss.toGlobal(x2, y2)
        
        love.graphics.line(a1,b2, a2,b2)
        y1 = y1-1000
        y2 = y2-1000
    end
    
    x1 = 0
    y1 = 3000
    
    x2 = 0
    y2 = -3000
    for i = 0,8 do
        local a1, b1 = truss.toGlobal(x1, y1)
        local a2, b2 = truss.toGlobal(x2, y2)
        
        love.graphics.line(a1,b1, a2,b2)
        x1 = x1+1000
        x2 = x2+1000
    end

love.graphics.pop()
end

return truss
