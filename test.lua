
local _M = {}

local function table_size(t)
    local size = 0
    for _ in pairs(t) do
        size = size + 1
    end
    return size
end

local function new_test_data()
    return {
        1,2,3,
        a = "a",
        b = "b",
    }
end

function _M.base_test(table_replace)
    local t = new_test_data()
    local r = table_replace(t)

    -- 替换表和原始表字段完全一样
    assert(table_size(r) == table_size(t))
    assert(#r == #t)
    for k, v in pairs(t) do
        assert(r[k] == v)
    end

    -- 现有字段的替换
    r[1] = 11
    r.a = "aa"
    assert(r[1] == 11 and r.a == "aa")
    assert(table_size(r) == 5)
    assert(#r == 3)

    -- 新增 array 字段
    r[4] = 4
    r[5] = 5
    assert(r[4] == 4 and r[5] == 5)
    assert(table_size(r) == 7)
    assert(#r == 5)

    -- 新增 hash 字段
    r.c = "c"
    r.d = "d"
    assert(r.c == "c" and r.d == "d")
    assert(table_size(r) == 9)
    assert(#r == 5)

    -- table.insert
    table.insert(r, 6)
    assert(#r == 6)
    --! 不支持 table.remove, 因为不支持原始表的数据删除, 只 remove 替换表的元素没问题, 但 remove 到原始表, 就会出错
end

function _M.ext_test(table_replace)
    local t = new_test_data()
    local r = table_replace(t)

    r.a = nil
    assert(r.a == nil)
    assert(table_size(r) == 4)
    assert(#r == 3)

    table.insert(r, 4)
    assert(r[4] == 4)
    assert(table_size(r) == 5)
    assert(#r == 4)

    assert(table.remove(r, 1) == 1)
    assert(#r == 3)
    assert(table_size(r) == 4)
    assert(r[1] == 2 and r[2] == 3 and r[3] == 4 and r[4] == nil)

    assert(table.remove(r) == 4)
    -- assert(#r == 2)
    -- assert(table_size(r) == 3)
    -- assert(r[1] == 2 and r[2] == 3 and r[3] == nil)
    -- 想象中是上面3行的样子, 实际是下面这样
    -- 原因就是当替换表有元素时, 不会触发 __newindex, 所以也不会在 nil_keys 里登记
    -- 这就导致取长度时从原始表里取了, 替换表内没登记 nil 就不会有正常的结果
    -- 这个是无解的, 就算有解, 代码也将会更复杂, 性能也会更差, 那就没有意义了
    --! 结论就是, 不要对替换表做 table.remove, 哪怕是 ext53 里的复杂实现
    assert(#r == 3)
    assert(table_size(r) == 4)
    assert(r[1] == 2 and r[2] == 3 and r[3] == 3)
end

return _M
