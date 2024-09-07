
-- Datum:   18.08.2024

local roman = {}

local symbols = {
    "I",  -- 1
    "IV", -- 4
    "V",  -- 5
    "IX", -- 9
    "X",  -- 10
    "XL", -- 40
    "IL", -- 49
    "L",  -- 50
    "XC", -- 90
    "IC", -- 99
    "C",  -- 100
    "CD", -- 400
    "ID", -- 499
    "D",  -- 500
    "CM", -- 900
    "IM", -- 999
    "M"   -- 1000
}

local values = {1, 4, 5, 9, 10, 40, 49, 50, 90, 99, 100, 400, 499, 500, 900, 999, 1000}


function roman.num2roman(num)
    local count     = #values
    local result    = ''
    
    while num > 0 do
    
        if num >= values[count] then
            result = result .. symbols[count]
            num = num - values[count]
        else
            count = count-1
        end
    
    end
    
    return result
    
end

return roman
