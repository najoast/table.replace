
local use51 = ...

local table_replace
if use51 then
    table_replace = require "replace51"
else
    table_replace = require "replace53"
end

local function test1()
    local t = {
        1,2,3,
        a = "a",
        b = "b",
    }

    local r = table_replace(t)
    -- r[4] = 4
    -- table.insert(r, 4)
    -- table.insert(r, 5)

    print(#t, #r)


    print("0000000000000000")

    for k,v in pairs(t) do
        print(k, v)
    end

    print("1111111111111111")

    for i=1,#t do
        print(i, t[i])
    end

    print("======")
    for k,v in ipairs(t) do
        print(k,v)
    end


    print("2222222222222222")

    r[1] = 11
    r.a = "aa"

    for k,v in pairs(r) do
        print(k, v)
    end

    print("3333333333333333")

    for i=1,#r do
        print(i, r[i])
    end
    print("======")

    for k,v in ipairs(r) do
        print(k,v)
    end
end

local function test2()
    local t = {
        1,2,3,
        a = "a",
        b = "b",
    }

    local r = table_replace( t)
    assert(#r == 3)
    assert(r[1] == 1 and r[2] == 2 and r[3] == 3)
    assert(r.a == "a" and r.b == "b")

    table.insert(r, 4)
    assert(#r == 4 and r[4] == 4)

    local function for_pairs(tt)
        for k, v in pairs(tt) do
            print(k, v)
        end
    end

    local function for_ipairs(tt)
        for k, v in ipairs(tt) do
            print(k, v)
        end
    end

    local function for_i(tt)
        for i = 1, #tt do
            print(i, tt[i])
        end
    end

    for_pairs(r)
    print("==========")
    for_ipairs(r)
    print("==========")
    for_i(r)
end

test1()
test2()
