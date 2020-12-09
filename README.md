# 替换表
### 定义
替换表就是根据一个表 `A` 创建一个新表 `B`, `B` 的行为和 `A` 完全一样, 后续对 `B` 的赋值和修改都不会影响 `A`.

### 概念约定
* 原始表: 原始数据表
* 替换表: 基于原始表生成的新表

### 使用场景
在日常写代码时, 经常会用到 `table.copy` 这个接口来拷贝一个表, 然后改变新表的几个字段, 再把这个表丢出去作为返回值给其他地方用.

但有时候可能原始表有 100 字段, 而我们只要改几个字段, 这种情况下拷贝表是非常浪费的.

这时就可以用替换表来解决这个问题。

```lua
local t1 = {
    1,2,3,
    a = "a",
    b = "b",
}

local t2 = table_replace(t1)

t2[1] = 11
t2.a = "aa"
```

遍历 t2 的结果:
```lua
t2 = {
    [1] = 11,
    [2] = 2,
    [3] = 3,
    ["a"] = "aa",
    ["b"] = "b",
}
```

这时不管直接索引, 还是遍历 t2, 表现都像是一个正常的表一样, 使用时跟 `table.copy` 的行为是完全一样的, 但实际只生成了替换表, 还不会动到原始表.

### 开销
使用替换表的代价就是生成一个很小的替换表（只含替换字段）和一个 _next 闭包，相比于表拷贝，这点开销忽略不计，可以放心使用。

# 性能比较差的点
由于 `__len` 的实现是先取原始表长度, 再遍历替换表后面的元素, 所以当替换表的数组部分超出原始表太多时, 遍历开销会比较大, 但这个开销和大部分项目中的 `table.size` 是一样的, 所以也不用太担心, 这样的遍历是很快的.

# 模拟 table.copy 程度
5.3 版的实现, 已完全模拟:
* `table.insert`
* `#`
* `pairs`
* `ipairs`
* 索引值
* 赋值 (nil & 非 nil, 以及赋 nil 后 `#` 取长也都已支持)

### 赋 nil 问题
举例:
```lua
local t = { a = "a", b = "b" }
local r = table_replace(t)
r.a = nil
assert(r.a == "a") -- 断言成立
```
为什么会这样呢, 因为我们不能改原始表, 赋 nil 就只能在替换表内做, 再次索引时, 对于替换表内找不到的, 因为 `__index` 指向了原始表, 所以还是会从原始表内找到.

如果要支持这个特性, 可以定义一个空表, 约定值等于

***

`Lua 5.1` 版由于不支持 `__pairs` 和 `__len` 元方法, 所以实现起来比较麻烦, 不但 pairs 要通过把数据存到元表里来才能实现, `#` 和 `table.insert` 更是无法实现.

# 文件说明
* `replace51.lua`, 5.1 版本的实现, 由于把数据存到元表里, 且改写了 pairs, 所以会降低系统的整体性能, 请谨慎使用. 如果真想用, 可以改写 Lua 代码, 让其支持 `__pairs` 即可.
* `replace53.lua`, 5.3 版本的实现, 5.4 当然也可以用
* `test.lua`, 测试文件

# TODO
* 5.3 版简化实现, 剥离掉 nil / # / table.insert 的实现, 提供一个性能较好且足以应付大部分场景的版本