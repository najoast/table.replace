--[[
注意事项:

1. 对于原始表中存在的项, 无法通过对替换表赋 nil 删除这个元素.
   如果真想要这个特性, 请使用 full53.lua 里的实现, 该实现满足这个特性,
   但代码复杂很多, 性能也要差一点, 所以如果没需求还是建议用这个版本.

2. 可以对替换表做 table.insert, 但最好不要使用 table.remove 来删除元素,
   会有各种问题.

]]

local function table_replace(original_table)
    local replace_table = {}

    local _switched -- 遍历时要遍历原始表和替换表, 这个变量标记是否转换了表
    local function _next(_, index)
        if not _switched then -- replace_table
            local k, v = next(replace_table, index)
            if k then
                return k, v
            else
                _switched = true
                return _next(original_table)
            end
        else -- original_table
            local k, v = next(original_table, index)
            if rawget(replace_table, k) ~= nil then -- 替换表有了, 跳过
                return _next(original_table, k)
            else
                return k, v
            end
        end
    end

    return setmetatable(replace_table, {
        __index = original_table,
        __pairs = function()
            _switched = false
            return _next, replace_table
        end,
        __len = function()
            local len = #original_table
            while true do
                local nextIndex = len + 1
                if rawget(replace_table, nextIndex) == nil then
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


