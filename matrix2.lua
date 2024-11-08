
local Class = Object:new()
local Matrix = Class

function Class:init()

    if self.width and self.height and (not self.elements) then
        self.elements = {}
        for i = 1,self.width*self.height do
            self.elements[i] = 0
        end
    end

    self.elements   = self.elements or {}
    self.width      = self.width    or 0
    self.height     = self.height   or 0
    
    if self.width*self.height ~= #self.elements then
        error('Number of elements does not match with width and height of Matrix.')
    end

end

function Class:plus(M)

    if not (self.width == M.width and self.height == M.height) then
        error("Matrices must be the same dimension.")
    end
    
    local result = self:copy()
    
    for i = 1, result.width*result.height do
        result.elements[i] = self.elements[i] + M.elements[i]
    end
    
    return result

end

function Class:minus(M)
    if not (self.width == M.width and self.height == M.height) then
        error("Matrices must be the same dimension.")
    end
    
    local result = self:copy()
    
    for i = 1, result.width*result.height do
        result.elements[i] = self.elements[i] - M.elements[i]
    end
    
    return result
end

function Class:scale(c)

    local result = self:copy()
    for i,e in ipairs(self.elements) do
        result.elements[i] = c*e
    end
    
    return result

end

function Class:dot(M, i, j)
    if self.width ~= M.height then
        error("Left matrix must be as wide as right matrix is tall.")
    end
    
    if i > self.height or j > M.width then
        error("Indices i or j are out of bounds.")
    end
    
    local result = 0
    for k = 1, self.width do
        result = result + self.elements[(i-1)*self.width + k] * M.elements[(k-1)*M.width + j]
    end
    
    return result
end

function Class:mul(M)

    if self.width ~= M.height then
        error("Left matrix must be as wide as right matrix is tall.")
    end
    
    local result    = self:copy()
    result.width    = M.width
    result.height   = self.height
    
    for i = 1, result.width*result.height do
        result.elements[i] = 0
    
    end
    
    local k = 1
    for i = 1, self.height do
        
        for j = 1, M.width do
            result.elements[k] = result.elements[k] + self:dot(M, i, j)
            k = k+1
        
        end
        
    end
    
    return result

end

function Class:transpose()

    local T     = self:copy()
    T.width     = self.height
    T.height    = self.width
    
    local k = 1
    for i = 1, self.width do
    
        for j = 1, self.height do
            T.elements[k] = self.elements[i+(j-1)*self.width]
            k = k+1
        end
        
    end

    return T
end

function Class:submatrix(i, j)
    if i > self.height or j > self.width then
        error("Indices i or j are out of bounds.")
    end
    
    local R     = self:copy()
    R.width     = self.width - 1
    R.height    = self.height - 1

    local m = 1
    for row = 1, self.height do
        for col = 1, self.width do
            if row ~= i and col ~= j then
                R.elements[m] = self.elements[(row-1) * self.width + col]
                m = m + 1
            end
        end
    end
    
    return R
end

function Class:det2()
    if self.width ~= self.height or self.width ~= 2 then
        error("Matrix must be 2x2.")
    end
    local els = self.elements
    return els[1]*els[4] - els[2]*els[3]
end

function Class:det()
    if self.width ~= self.height then
        error("Matrix must be square.")
    end
    
    if self.width == 1 then
        return self.elements[1]
    elseif self.width == 2 then
        return self:det2()
    end
    
    local result    = 0
    local sign      = 1
    
    for i = 1, self.width do
    
        local c = self.elements[i]
        if c ~= 0 then
            local B = self:submatrix(1, i)
            result  = result + sign * c * B:det()
        end
        sign = -sign
            
    end
    
    return result
end

function Class:set(i, j, m)
    if i > self.height or i < 1 then error('Index i out of bounds.') end
    if j > self.width  or j < 1 then error('Index j out of bounds.') end
    
    self.elements[(i-1)*self.width + j] = m
end

function Class:get(i, j)
    if i > self.height or i < 1 then error('Index i out of bounds.') end
    if j > self.width  or j < 1 then error('Index j out of bounds.') end
    
    return self.elements[(i-1)*self.width + j]
end

function Class:copy()
    local M = Class:new{
        width     = self.width,
        height    = self.height
    }

    for i,element in ipairs(self.elements) do
        M.elements[i] = element
    end
    
    return M

end

function Class:toString()

    local str = ''

    for i = 1, self.height do
    
        for j = 1, self.width do
            local element   = self.elements[(i-1) * self.width + j]
            str = str .. string.format('%10g ', element)
            
        end
        
        str = str .. '\n'
    end
    
    return str
end

function Class:T()
    return self:transpose()
end

function Class:__add(M)
    return self:plus(M)
end

function Class:__sub(M)
    return self:minus(M)
end

function Class:__mul(c)
    if      type(self) == 'table' and type(c) == 'table' then
                return self:mul(c)
    elseif  type(c) == 'number' then
                return self:scale(c)
    elseif  type(c) == 'table' then
                return c:scale(self)
    end
    
    error('Wrong type to multiply a matrix.')
end

function Class:__tostring()
    return self:toString()
end

return Class