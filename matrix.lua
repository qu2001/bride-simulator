
local matrix = {}

function matrix.new(M, w, h)

    if w*h ~= #M then
        error("Matrix M can't be created using width w and height h.")
    end
    
    M.width = w
    M.height = h
    
    return M

end

function matrix.plus(A, B)
    if A.width ~= B.width and A.height ~= B.height then
        error("Matrix A and B must be same dimension.")
    end
    
    local C = {}
    C.width = A.width
    C.height = A.height
    
    for i = 1, C.width*C.height do
        C[i] = A[i] + B[i]
    end
    
    return C

end

function matrix.minus(A, B)
    if A.width ~= B.width and A.height ~= B.height then
        error("Matrix A and B must be same dimension.")
    end
    
    local C = {}
    C.width = A.width
    C.height = A.height
    
    for i = 1, C.width*C.height do
        C[i] = A[i] - B[i]
    end
    
    return C

end

function matrix.copyMatrix(M)

    local C = {}
    C.width = M.width
    C.height = M.height
    
    for i = 1, C.width*C.height do
        C[i] = M[i]
    end
    
    return C
end

function matrix.transpose(A)

    local T = {}
    T.width = A.height
    T.height = A.width
    
    local k = 1
    for i = 1, A.width do
    
        for j = 1, A.height do
            T[k] = A[i+(j-1)*A.width]
            k = k+1
        end
        
    end

    return T
end

function matrix.submatrix(A, i, j)
    if i > A.height or j > A.width then
        error("Indices i or j are out of bounds.")
    end
    
    local R = {}
    R.width = A.width - 1
    R.height = A.height - 1

    local m = 1
    for row = 1, A.height do
        for col = 1, A.width do
            if row ~= i and col ~= j then
                R[m] = A[(row-1) * A.width + col]
                m = m + 1
            end
        end
    end
    
    return R
end

function matrix.det2(M)
    if M.width ~= M.height or M.width ~= 2 then
        error("Matrix M must be 2x2.")
    end
    return M[1]*M[4] - M[2]*M[3]
end

function matrix.det(A)
    if A.width ~= A.height then
        error("Matrix M must be square.")
    end
    
    if A.width == 1 then
        return A[1]
    elseif A.width == 2 then
        return matrix.det2(A)
    end
    
    local result = 0
    local sign = 1
    
    for i = 1, A.width do
    
        local c = A[i]
        if c ~= 0 then
            local B = matrix.submatrix(A, 1, i)
            result = result + sign * c * matrix.det(B)
        end
        sign = -sign
            
    end
    
    return result
end

function matrix.dot(A, B, i, j)
    if A.width ~= B.height then
        error("Matrix A must be as wide as Matrix B is tall.")
    end
    
    if i > A.height or j > B.width then
        error("Indices i or j are out of bounds.")
    end
    
    local result = 0
    for k = 1, A.width do
        result = result + A[(i-1)*A.width + k] * B[(k-1)*B.width + j]
    end
    
    return result
end

function matrix.mul(A, B)

    if A.width ~= B.height then
        error("Matrix A must be as wide as Matrix B is tall.")
    end
    
    local C = {}
    C.width = B.width
    C.height = A.height
    for i = 1, C.width*C.height do
        C[i] = 0
    
    end
    
    local k = 1
    for i = 1, A.height do
        
        for j = 1, B.width do
            C[k] = C[k] + matrix.dot(A, B, i, j)
            k = k+1
        
        end
        
    end
    
    return C

end

function matrix.solve(A, b)
    -- solve A*x = b using Cramer's rule
    
    if A.height ~= b.height then
        error("Matrix A must be as tall as Vector b.")
    end
    
    local c0 = matrix.det(A)
    if c0 == 0 then
        error("Determinant of Matrix A must be non-zero.")
    end
    
    local x = {}
    x.width = 1
    x.height = A.height
    
    for i = 1, A.width do
    
        local Amod = matrix.copyMatrix(A)
        for j = 1, b.height do           
            Amod[i + A.height*(j-1)] = b[j]
        end
    
        x[i] = matrix.det(Amod)/c0
    end
    
    
    return x

end

function matrix.scale(c, M)

    local S = {};
    S.width = M.width
    S.height = M.height

    for i = 1, S.width*S.height do
        S[i] = c*M[i]
    end

    return S
    
end

function matrix.printMatrix(M)
    for i = 1, M.height do
        for j = 1, M.width do
            local num = M[(i-1) * M.width + j]
            local str = string.format("%8g ", num)
            io.write(str)
        end
        io.write("\n")
    end
end

return matrix
