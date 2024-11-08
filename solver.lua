
local Matrix = require 'matrix2'

local function sumL(L, r, c)
    local result = 0
    for i = 1,c-1 do
        result = result - L:get(r, i)*L:get(c, i)
    end
    
    return result
end

local function calcDiagonal(L, A, i)
    local result = 0
    for j = i-1, 1, -1 do
        result = result - L:get(i, j)^2
    end
    local Lii = math.sqrt(A:get(i, i) + result)
    L:set(i, i, Lii)
end

local function column1(L, A)

    local L11 = math.sqrt(A:get(1, 1))
    L:set(1, 1, L11)
    
    for i = 2, L.height do
        local Li1 = A:get(i, 1)/L11
        L:set(i, 1, Li1)

    end 
        
end


local function chol(A)
    -- Return lower Matrix L of Cholesky decomposition.
    local L = Matrix:new{width=A.width, height=A.height}
    
    column1(L, A)
    
    for i = 2,L.width do
    
        for j = i, L.height do
        
            if i == j then calcDiagonal(L, A, i)
            else
            
                local Lji = (A:get(i, j) + sumL(L, j, i)) / L:get(i, i)
                L:set(j, i, Lji)
            end
        
        end
    
    end
    
    return L
end

local function calcY(L, b)
    local y = b:copy()
    
    local y1 = b:get(1, 1) / L:get(1, 1)
    y:set(1, 1, y1)
    
    for i = 2, y.height do
    
        local result = 0
        for j = i-1, 1, -1 do
            result = result - L:get(i, j)*y:get(j, 1)
        end
    
        local yi = (b:get(i, 1) + result) / L:get(i, i)
        y:set(i, 1, yi)
    end
    
    return y

end

local function calcX(U, y)
    local x = y:copy()
    
    for i = x.height, 1, -1 do
    
        local result = 0
        for j = i+1, x.height do
            result = result - U:get(i, j)*x:get(j, 1)
        end
    
        local xi = (y:get(i, 1) + result) / U:get(i, i)
        x:set(i, 1, xi)
    end
    
    return x
end

local function solveCholesky(A, b)
    -- Solve A*x = b using Cholesky decomposition.
    local L = chol(A)
    local y = calcY(L, b)
    local x = calcX(L:T(), y)
    return x
end

local function solveCramer(A, b)
    -- solve A*x = b using Cramer's rule
    
    if A.height ~= b.height then
        error("Matrix A must be as tall as Vector b.")
    end
    
    local c0 = A:det()
    if c0 == 0 then
        error("Determinant of Matrix A must be non-zero.")
    end
    
    local x     = Matrix:new()
    x.width     = 1
    x.height    = A.height
    
    for i = 1, A.width do
    
        local Amod = A:copy()
        for j = 1, b.height do           
            Amod.elements[i + A.height*(j-1)] = b.elements[j]
        end
    
        x.elements[i] = Amod:det()/c0
    end
    
    
    return x
end

local function solve(A, b, rule)

    if      rule == 'cramer' then
                return solveCramer(A, b)
    elseif  rule == 'cholesky' then
                return solveCholesky(A, b)
    end
    
    error('Unknown rule.')

end

return solve