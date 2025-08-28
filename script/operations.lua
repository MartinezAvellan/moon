local function split_decimal(s)
    local sign = ""

    if s:sub(1, 1) == "-" then
        sign = "-"
        s = s:sub(2)
    end

    local intp, fracp = s:match("^(%d+)%.(%d+)$")
    if intp then
        return sign .. intp, fracp, sign ~= ""
    else
        return sign .. s, "", sign ~= ""
    end
end

local function rtrim_zeros(frac)
    frac = frac:gsub("0+$", "")
    return (frac == "" and "0") or frac
end

local sub_decimal

local function add_decimal(a, b)
    a = tostring(a)
    b = tostring(b)
    local ai, af, a_negative = split_decimal(a)
    local bi, bf, b_negative = split_decimal(b)

    if a_negative and b_negative then
        local result = add_decimal(a:sub(2), b:sub(2))
        return "-" .. result
    end

    if a_negative then
        return sub_decimal(b, a:sub(2))
    end

    if b_negative then
        return sub_decimal(a, b:sub(2))
    end

    if ai:sub(1, 1) == "-" then ai = ai:sub(2) end
    if bi:sub(1, 1) == "-" then bi = bi:sub(2) end

    if #af < #bf then
        af = af .. string.rep("0", #bf - #af)
    elseif #bf < #af then
        bf = bf .. string.rep("0", #af - #bf)
    end

    local carry = 0
    local frac_sum = {}
    for i = #af, 1, -1 do
        local da = tonumber(af:sub(i, i))
        local db = tonumber(bf:sub(i, i))
        local s = da + db + carry
        carry = math.floor(s / 10)
        frac_sum[#af - i + 1] = tostring(s % 10)
    end

    local rii = ai:reverse()
    local rbi = bi:reverse()
    local max_i = math.max(#rii, #rbi)
    local int_sum = {}
    for i = 1, max_i do
        local da = tonumber(rii:sub(i, i)) or 0
        local db = tonumber(rbi:sub(i, i)) or 0
        local s = da + db + carry
        carry = math.floor(s / 10)
        int_sum[i] = tostring(s % 10)
    end
    if carry > 0 then
        int_sum[#int_sum + 1] = tostring(carry)
    end

    local int_res = table.concat(int_sum):reverse()
    local frac_res = table.concat(frac_sum):reverse()
    frac_res = rtrim_zeros(frac_res)

    if frac_res == "0" then
        return int_res
    end
    return int_res .. "." .. frac_res
end

sub_decimal = function(a, b)
    a = tostring(a)
    b = tostring(b)
    local ai, af, a_negative = split_decimal(a)
    local bi, bf, b_negative = split_decimal(b)

    if a_negative and b_negative then
        return sub_decimal(b:sub(2), a:sub(2))
    end

    if a_negative then
        local result = add_decimal(a:sub(2), b)
        return "-" .. result
    end

    if b_negative then
        return add_decimal(a, b:sub(2))
    end

    local a_num = tonumber(a)
    local b_num = tonumber(b)
    if a_num < b_num then
        local result = sub_decimal(b, a)
        return "-" .. result
    end

    if ai:sub(1, 1) == "-" then ai = ai:sub(2) end
    if bi:sub(1, 1) == "-" then bi = bi:sub(2) end

    if #af < #bf then
        af = af .. string.rep("0", #bf - #af)
    elseif #bf < #af then
        bf = bf .. string.rep("0", #af - #bf)
    end

    local borrow = 0
    local frac_res_tbl = {}
    for i = #af, 1, -1 do
        local da = tonumber(af:sub(i, i))
        local db = tonumber(bf:sub(i, i))
        local diff = da - db - borrow
        if diff < 0 then
            diff = diff + 10
            borrow = 1
        else
            borrow = 0
        end
        frac_res_tbl[#af - i + 1] = tostring(diff)
    end

    local rii = ai:reverse()
    local rbi = bi:reverse()
    local max_i = math.max(#rii, #rbi)
    local int_res_tbl = {}
    for i = 1, max_i do
        local da = tonumber(rii:sub(i, i)) or 0
        local db = tonumber(rbi:sub(i, i)) or 0
        local diff = da - db - borrow
        if diff < 0 then
            diff = diff + 10
            borrow = 1
        else
            borrow = 0
        end
        int_res_tbl[i] = tostring(diff)
    end

    local res_int_rev = table.concat(int_res_tbl)
    local res_int = res_int_rev:reverse():gsub("^0+", "")
    if res_int == "" then
        res_int = "0"
    end

    local frac_normal = table.concat(frac_res_tbl):reverse()
    frac_normal = rtrim_zeros(frac_normal)

    if frac_normal == "0" then
        return res_int
    end
    return res_int .. "." .. frac_normal
end

-- remove zeros à esquerda
local function ltrim_zeros(s)
    return (s:gsub("^0+", ""):match(".*%S") or "0")
end

local function normalize(a, b)
    local ai, af = split_decimal(a)
    local bi, bf = split_decimal(b)
    local scale = math.max(#af, #bf)
    af = af .. string.rep("0", scale - #af)
    bf = bf .. string.rep("0", scale - #bf)
    return ai .. af, bi .. bf, scale
end

local function mul_decimal(a, b)
    a = tostring(a)
    b = tostring(b)

    local a_negative = a:sub(1,1) == "-"
    local b_negative = b:sub(1,1) == "-"
    if a_negative then a = a:sub(2) end
    if b_negative then b = b:sub(2) end

    local ai, af = split_decimal(a)
    local bi, bf = split_decimal(b)

    local int_a = ai .. af
    local int_b = bi .. bf
    local scale = #af + #bf

    int_a = ltrim_zeros(int_a)
    int_b = ltrim_zeros(int_b)

    local la, lb = #int_a, #int_b
    local res = {}
    for i = 1, la + lb do res[i] = 0 end

    for i = la, 1, -1 do
        local carry = 0
        local da = tonumber(int_a:sub(i,i))
        for j = lb, 1, -1 do
            local db = tonumber(int_b:sub(j,j))
            local pos = (la - i) + (lb - j) + 1
            local idx = #res - pos + 1
            local sum = res[idx] + da*db + carry
            res[idx] = sum % 10
            carry = math.floor(sum / 10)
        end
        if carry > 0 then
            res[#res - (la - i + lb) + 1] = res[#res - (la - i + lb) + 1] + carry
        end
    end

    local result = table.concat(res):gsub("^0+", "")
    if result == "" then result = "0" end

    if scale > 0 then
        if #result <= scale then
            result = string.rep("0", scale - #result + 1) .. result
        end
        local intp = result:sub(1, #result - scale)
        local fracp = result:sub(#result - scale + 1)
        fracp = rtrim_zeros(fracp)
        if fracp == "0" then
            result = intp
        else
            result = intp .. "." .. fracp
        end
    end

    if a_negative ~= b_negative and result ~= "0" then
        result = "-" .. result
    end
    return result
end

local function div_decimal(a, b, precision)
    precision = precision or 18
    a = tostring(a)
    b = tostring(b)

    local a_negative = a:sub(1,1) == "-"
    local b_negative = b:sub(1,1) == "-"
    if a_negative then a = a:sub(2) end
    if b_negative then b = b:sub(2) end

    local ai, af = split_decimal(a)
    local bi, bf = split_decimal(b)

    local scale = math.max(#af, #bf)
    local int_a = ai .. af .. string.rep("0", precision)
    local int_b = bi .. bf

    int_a = ltrim_zeros(int_a)
    int_b = ltrim_zeros(int_b)

    local quotient, remainder = "", 0
    local curr = 0
    for i = 1, #int_a do
        curr = curr * 10 + tonumber(int_a:sub(i,i))
        local q = math.floor(curr / tonumber(int_b))
        quotient = quotient .. tostring(q)
        curr = curr % tonumber(int_b)
    end

    quotient = quotient:gsub("^0+", "")
    if quotient == "" then quotient = "0" end

    if precision > 0 then
        local intp = quotient:sub(1, #quotient - precision)
        if intp == "" then intp = "0" end
        local fracp = quotient:sub(#quotient - precision + 1)
        fracp = rtrim_zeros(fracp)
        if fracp == "0" then
            quotient = intp
        else
            quotient = intp .. "." .. fracp
        end
    end

    if a_negative ~= b_negative and quotient ~= "0" then
        quotient = "-" .. quotient
    end
    return quotient
end

local function main()
    local key = KEYS[1]
    local ttl = KEYS[2]

    local balance = ARGV[1]
    local operation = ARGV[2]
    local redisBalance = 0

    local currentBalance = cjson.encode(balance)
    local ok = redis.call("SET", key, currentBalance, "EX", ttl, "NX")
    if not ok then
        currentBalance = redis.call("GET", key)
        if currentBalance then
           redisBalance = cjson.decode(currentBalance)
        end
    end

    local result = "0"

    if operation == "ADD" then
        result = add_decimal(redisBalance, balance)
    elseif operation == "SUB" then
        result = sub_decimal(redisBalance, balance)
    elseif operation == "MUL" then
        result = mul_decimal(redisBalance, balance)
    elseif operation == "DIV" then
        result = div_decimal(redisBalance, balance)
    else
        return redis.error_reply("Operation not found! It could be ADD, SUB, MUL or DIV...")
    end

    currentBalance = cjson.encode(result)
    redis.call("SET", key, currentBalance, "EX", ttl)

    return result
end

return main()