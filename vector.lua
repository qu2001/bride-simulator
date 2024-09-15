
local vector = {}

function vector.new(...)

    local vec = {}
    vec.height = select('#', ...)
    vec.width = 1
    
    local vararg = {...}
    for i,v in ipairs(vararg) do
        vec[i] = v
    end

    return vec
    
end

function vector.abs(v)

    if v.width ~= 1 then
        error("Vector v must be a column vector.")
    end

    local n = v.height*v.width

    
    local sum = 0
    for i = 1,n do
        sum = sum + v[i]^2
    end

    return math.sqrt(sum)
end

function vector.add(a, b)
 
    if a.width ~= 1 or b.width ~= 1 then
        error("Vector a and b must be column vectors.")
        
    elseif a.height ~= b.height then
        error("Vector a and b differ in size.")
        
    end
    
    local c     = {}
    c.height    = a.height
    c.width     = 1
    
    for i = 1,a.height do
        c[i] = a[i] + b[i]
    end
    
    return c

end

function vector.dot(a, b)

    if a.width ~= 1 or b.width ~= 1 then
        error("Vector a and b must be column vectors.")
        
    elseif a.height ~= b.height then
        error("Vector a and b differ in size.")
        
    end
    
    sum = 0
    for i = 1,a.height do
        sum = sum + a[i]*b[i]
    end
    
    return sum

end

function vector.scale(v, c)
    if v.width ~= 1 then
        error("Vector v must be a column vector.")
    end
    
    local s = {}
    s.width = 1
    s.height = v.height
    
    for i = 1,v.height do
        s[i] = c*v[i]
    end
    
    return s
    
end

function vector.get2DNormal(v)
    if v.width ~= 1 then
        error("Vector v must be a column vector.")
    elseif v.height > 2 then
        error("Vector v must be two dimensional.")
    end
    
    local n = {}
    n.width = 1
    n.height = 2
    n[1] = -v[2]
    n[2] = v[1]
    
    local vLen = vector.abs(v)
    n = vector.scale(n, 1/vLen)
    
    return n
    
end

function vector.printVector(v)

    if v.width ~= 1 then
        error("Vector v must be a column vector.")
    end
    
    for i = 1, v.height do
        local num = v[i]
        local str = string.format("%g", num)
        io.write(str .. '\n')
    end


end
    
return vector
