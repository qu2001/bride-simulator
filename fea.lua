
-- Datum:   18.08.2024

local fea = {}

local matrix  = require("matrix")
local vector  = require("vector")

local DISP    = 1
local FORCE   = 2

local v     = {}
local vLen  = {}
local R     = {}
local k     = {}
local K     = {}
local Kg    = {}
local B     = {}
local C     = {}

local AVec  = {}
local CMod  = {}
local sVec  = {}

local ug    = {}
local uVec  = {}
local FVec  = {}

local points    = {}
local rods      = {}
local consts    = {}

local CCreated      = false
local CModCreated   = false
local isSolved      = false

function fea.createStiffness(fpoints, frods)

    CCreated      = true
    CModCreated   = false
    isSolved      = false

    points  = fpoints
    rods    = frods

    for i = 1,(#points*2)^2 do
        C[i] = 0
    end
    C.width     = #points*2
    C.height    = #points*2
    
    for i = 1, #rods do
    
        -- Stabvektor
        v[i] = {}
        local c1 = rods[i][1]
        local c2 = rods[i][2]
        v[i][1] = points[c1][1] - points[c2][1]
        v[i][2] = points[c1][2] - points[c2][2]
        v[i].width  = 1
        v[i].height = 2
        
        vLen[i] = vector.abs(v[i])
        
        -- Rotationsmatrix
        R[i] = {
            v[i][1], v[i][2], 0, 0,
            0, 0, v[i][1], v[i][2]
        }
        R[i].width  = 4
        R[i].height = 2
        R[i] = matrix.scale(1/vLen[i], R[i]);
        
        -- Steifigkeitsmatrizen
        k[i] = rods[i][3] / vLen[i]
        
        K[i] = {k[i], -k[i], -k[i], k[i]}
        K[i].width = 2
        K[i].height = 2
        
        local RT = matrix.transpose(R[i])
        Kg[i] = matrix.mul(matrix.mul(RT, K[i]), R[i])
        
        -- Bindungsmatrix erstellen
        B[i] = {}
        for j = 1, 2*#points * 4 do
            B[i][j] = 0
        end
        local Bw = 2*#points
        local Bh = 4
        B[i].width = Bw
        B[i].height = Bh
        
        B[i][c2*2-1]        = 1
        B[i][c2*2 + Bw]     = 1
        B[i][c1*2-1 + 2*Bw] = 1
        B[i][c1*2 + 3*Bw]   = 1
        
        -- Gesamtsteifigkeit
        local BT = matrix.transpose(B[i])
        local CL = matrix.mul(matrix.mul(BT, Kg[i]), B[i])
        C = matrix.plus(C, CL)
        
    end
end

function fea.modifyStiffness(fconsts)

    if CCreated then
        CCreated      = true
        CModCreated   = true
        isSolved      = false
    else
        error('Create stiffness matrix first.')
    end
    
    consts = fconsts
    CMod = matrix.copyMatrix(C)
    
    for i = 1,C.width do
        AVec[i] = 0
    end
    AVec.height = C.width
    AVec.width  = 1
    
    -- Randbedingungen einfügen
    for i = 1,#consts do
        KNR     = consts[i][1]
        UF      = consts[i][2]
        XY      = consts[i][3]
        val     = consts[i][4]
        
        local FGNR = 2*(KNR-1) + XY
        AVec[FGNR] = val
        
        if UF == DISP then
            local a = (FGNR-1)*C.width+1
            local b = FGNR*C.width
            
            for j = a,b do
                CMod[j] = 0
            end
            
            CMod[C.width*(FGNR-1) + FGNR] = 1
            
        end
        
        
    end
end

function fea.solve()

    if CModCreated then
        CCreated      = true
        CModCreated   = true
        isSolved      = true
    else
        error('Create modified stiffness matrix first.')
    end

    sVec = matrix.solve(CMod, AVec)
end

function fea.getDisplacement()

    if not isSolved then
        error('Solve FEA-System first.')
    end

    return sVec
end

function fea.getAxials()

    FVec.width = 1
    FVec.height = #rods

    if not isSolved then
        error('Solve FEA-System first.')
    end

    for i = 1,#rods do
        ug[i]   = matrix.mul(B[i], sVec)
        uVec[i] = matrix.mul(R[i], ug[i])
        FVec[i] = matrix.mul(K[i], uVec[i])[2]
    end
    
    return FVec
end

function fea.getReactions()
    if not isSolved then
        error('Solve FEA-System first.')
    end
    
    return matrix.mul(C, sVec)
end

return fea
