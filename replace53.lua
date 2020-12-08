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
local function table_replace(originalTable)
    local ret = {}

    local _isSwitched
    local function _next(tbl, index)
        if _isSwitched then
            local k,v = next(originalTable, index)
            if rawget(tbl, k) ~= nil then -- 原生表有了，跳过
                return _next(tbl, k)
            else
                return k, v
            end
        else
            local k,v = next(tbl, index)
            if k ~= nil then
                return k, v
            else
                _isSwitched = true
                return _next(tbl)
            end
        end
    end

    return setmetatable(ret, {
        __index = originalTable,
        __newindex = function(self, key, value)
            rawset(self, key, value)
        end,
        __pairs = function()
            _isSwitched = false
            return _next, ret, nil
        end,
        __len = function()
            local len = #originalTable
            while true do
                local nextIndex = len + 1
                if rawget(ret, nextIndex) == nil then
                    break
                else
                    len = nextIndex
                end
            end
            return len
        end,
    })
end

return table_replace
