
local color = require("color")

local canvas = {}


local wc, hc
local Px, Py
local wcVirtuel, hcVirtuel
local dx, dy

local gridPoints = {}


function canvas.init(fwc, fhc, fPx, fPy, fwcVirtuel, fhcVirtuel)

    wc, hc                  = fwc, fhc
    Px, Py                  = fPx, fPy
    wcVirtuel, hcVirtuel    = fwcVirtuel, fhcVirtuel


end

function canvas.getDXY()
    return dx,dy
end

function canvas.toGlobal(xl, yl)

    local xt = xl * wc/wcVirtuel
    local yt = yl * hc/hcVirtuel
    
    local xg = xt + wc/2 + Px
    local yg = -yt + hc/2 + Py
    
    return xg, yg

end

function canvas.toLocal(xg, yg)

    local xt = xg - (wc/2 + Px)
    local yt = -yg + hc/2 + Py
    local xl = xt*wcVirtuel/wc
    local yl = yt*hcVirtuel/hc
    
    return xl, yl

end

function canvas.drawGrid(rows, colums)
love.graphics.push("all")

    love.graphics.setColor(color.GRAY)

    dx = wcVirtuel/colums
    dy = hcVirtuel/rows
    
    local x = -wcVirtuel/2
    local y = hcVirtuel/2
    
    for i = 1, colums+1 do
        local a1, b1 = canvas.toGlobal(x, y)
        local a2, b2 = canvas.toGlobal(x, -y)
        
        love.graphics.line(a1,b1, a2,b2)
        
        x = x+dx
    end
    
    x = -wcVirtuel/2
    y = hcVirtuel/2
    
    for j = 1, rows+1 do
    
        local a1, b1 = canvas.toGlobal(x, y)
        local a2, b2 = canvas.toGlobal(-x, y)
        
        love.graphics.line(a1,b1, a2,b2)
        y = y-dy
    
    end

love.graphics.pop()
end

return canvas