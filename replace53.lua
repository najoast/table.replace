
local function table_set(t, key, value)
    if not t and value then -- and value 是防止创建无意义的空表
        t = { [key] = value }
    else
        t[key] = value
    end
    return t
end

local function replace_table_len(original_table, replace_table)
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
end

local function table_replace(original_table)
    local replace_table = {}
    local nil_keys -- key ==> true, 记录对原始表字段赋 nil 的 keys

    local _switched -- 遍历时要遍历原始表和替换表, 这个变量标记是否转换了表
    local function _next(replace_table, index)
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
            if rawget(replace_table, k) ~= nil  -- 替换表有了, 跳过
            or (nil_keys and nil_keys[k])       -- 置 nil 了, 跳过
            then
                return _next(original_table, k)
            else
                return k, v
            end
        end
    end

    return setmetatable(replace_table, {
        __index = function(_, key)
            local v = original_table[key]
            if v and (not (nil_keys and nil_keys[key])) then
                return v
            end
        end,
        __newindex = function(self, key, value)
            local original_has_value = original_table[key]
            if original_has_value then
                if value then
                    nil_keys = table_set(nil_keys, key, nil) -- 还原
                else
                    nil_keys = table_set(nil_keys, key, true) -- 抹掉
                end
            end
            rawset(self, key, value)
        end,
        __pairs = function()
            _switched = false
            return _next, replace_table, nil
        end,
        __len = function()
            if not nil_keys then
                return replace_table_len(original_table, replace_table)
            else
                local min
                for key in pairs(nil_keys) do
                    if type(key) == "number" then
                        if not min or key < min then
                            min = key
                        end
                    end
                end
                if not min then
                    return replace_table_len(original_table, replace_table)
                end
                local len = #original_table
                if min <= len then
                    return min - 1
                else -- min > len
                    while true do
                        local nextIndex = len + 1
                        if nextIndex >= min
                        or rawget(replace_table, nextIndex) == nil
                        then
                            break
                        else
                            len = nextIndex
                        end
                    end
                    return len
                end
            end
        end,
    })
end

return table_replace
