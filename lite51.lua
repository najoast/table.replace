--! 此版本的实现仅提供一种实现的思路, 由于改写了 pairs 函数, 会造成全局性的性能降低, 请谨慎使用

local function replace_table_next(t, index)
    local mt = getmetatable(t)
    local r = mt.___replace
    if r.switched then
        local k,v = next(r.original, index)
        if rawget(t, k) ~= nil then -- 原生表有了，跳过
            return replace_table_next(t, k)
        else
            return k, v
        end
    else
        local k,v = next(t, index)
        if k ~= nil then
            return k, v
        else
            r.switched = true
            return replace_table_next(t)
        end
    end
end

local function table_replace(originalTable)
    local ret = {}
    return setmetatable(ret, {
        -- 借位
        ___replace = {
            switched = false,
            original = originalTable,
        },
        -- Lua 元方法
        __index = originalTable,
    })
end

do
    local raw_pairs = pairs
    function pairs(t)
        local mt = getmetatable(t)
        if mt and mt.___replace then
            return replace_table_next, t
        else
            return raw_pairs(t)
        end
    end
end

return table_replace

