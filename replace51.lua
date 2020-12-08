--[[
# 名词
原始表: 原始数据表
替换表: 生成的替换表


# 关于 table.insert 的模拟
替换表内还是使用 hash 的, 在原始表的基础上往后加元素, 所以取长度是先 #原始表,
再遍历替换表后面的元素.

在替换表后面如果有大量元素, 这种方法将会有一些性能问题, 但因为只是简单的取元素
判断是不是 nil, 所以开销还可以接受.

]]

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
        -- __newindex = function(self, key, value)
        --     rawset(self, key, value)
        -- end,
        -- __len = function(...)
        --     print("__len", ...)
        --     local len = #originalTable
        --     while true do
        --         local nextIndex = len + 1
        --         if rawget(ret, nextIndex) == nil then
        --             break
        --         else
        --             len = nextIndex
        --         end
        --     end
        --     return len
        -- end,
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

