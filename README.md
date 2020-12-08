# 替换表
需求描述：
在使用 sproto 做协议时，当我们定义了一个结构体，而这个结构体和 dbData 完全吻合，
或者多一些字段，这个时候我们为了节省一次表拷贝，会直接把 dbData 塞给 sproto，但
如果想改某些跟表现相关的字段，就不得不拷贝一次表了，因为改 dbData 会导致数据库里
的值发生变动，而这是我们不希望发生的。

这时就可以用此函数生成一个替换表来解决这个问题。

```lua
local t1 = {
    1,2,3,
    a = "a",
    b = "b",
}

local t2 = table.replace(t1)

t2[1] = 11
t2.a = "aa"
```

这时不管是遍历 t2, 还是通过 skynet.pack/unpack, t2 的表现都像是一个正常的表一样，
其值为:
```lua
t2 = {
    [1] = 11,
    [2] = 2,
    [3] = 3,
    ["a"] = "aa",
    ["b"] = "b",
}
```

生成替换表的代价就是生成一个很小的表（只含替换字段）和一个 _next 闭包，相比于表拷贝，
这点开销忽略不计，可以放心使用。

# 模拟程度
5.3 版的实现已经做到了完全模拟, 以下操作均正常:
* table.insert
* #
* pairs
* ipairs
* for i=1,#t do print(i, t[i]) end
* 索引值(index)
* 赋值(__newindex)
***
5.1 版由于不支持 `__pairs` 和 `__len` 元方法, 所以实现起来比较麻烦, 不但 pairs 要通过把数据存到元表里来才能实现, `#` 和 `table.insert` 更是无法实现.

# 文件说明
* replace51.lua, 5.1 版本的实现
* replace53.lua, 5.3 版本的实现
* test.lua, 测试文件
