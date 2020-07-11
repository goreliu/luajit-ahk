# utf8fix

Convert strings between UTF-8, UTF-16 and ANSI, for LuaJIT (Windows only).

```
u2w: UTF-8  -> UTF-16
w2u: UTF-16 -> UTF-8
a2w: ANSI   -> UTF-16
w2a: UTF-16 -> ANSI
u2a: UTF-8  -> ANSI
a2w: ANSI   -> UTF-16
L:   UTF-8  -> UTF-16
A:   UTF-8  -> ANSI
```

## Example

```
local utf8fix = require 'utf8fix'
local L = utf8fix.L
local A = utf8fix.A

local file = io.open(A'test 测试.txt', 'wb')
if file == nil then
    print('failed to open file')
else
    -- UTF-8 编码，设置 chcp 65001 后可以正常显示
    print('success 打开文件成功')

    -- ANSI 编码
    print(A'success 打开文件成功')
end

-- 写入文件时不需要转码
file:write('test 测试鿃㒨にほんご조선말🎉🥼👔✨');
file:close()

local ffi = require 'ffi'

ffi.cdef[[
int MessageBoxW(void *w, const wchar_t *txt, const wchar_t *cap, int type);
int MessageBoxA(void *w, const char *txt, const char *cap, int type);
]]

-- 可以正常显示
ffi.C.MessageBoxW(nil, L'test 测试鿃㒨にほんご조선말🎉🥼👔✨', L'W test 测试👔', 0)

-- 部分中文、日文可以正常显示，其他字符显示为问号，只为演示，基本没有实用性
ffi.C.MessageBoxA(nil, A'test 测试鿃㒨にほんご조선말🎉🥼👔✨', A'A test 测试👔', 0)

os.remove(A'test 测试.txt')
```
