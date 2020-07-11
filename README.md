# luajit-ahk
LuaJIT FFI binding for [AutoHotkey_H](https://hotkeyit.github.io/v2/) v1 (UNICODE version of AutoHotkey.dll should be put into the directory of lua51.dll).

## example

```
local ahk = require 'ahk'

ahk.init()

ahk.exec('MsgBox, 0, title, exec test 1, 0.3')

ahk.exec([[
    a := 333
    b := "getVar test 2"
]])

ahk.exec('MsgBox, 0, title, ' .. ahk.getVar('b') .. ', 0.3')

ahk.exec([[
Fun(Text) {
    MsgBox, 0, title, % Text, 0.3
    return Text
}

return

La:
    MsgBox, 0, title, label test 4, 0.3
    return
]])

print(ahk.func('Fun', 'func test 3'))

print(ahk.label('La'))

local L = require 'utf8fix'.L
ahk.C().ahkExec(L'MsgBox, 0, title, C test 5, 0.3')

ahk.addScript('MsgBox, 0, title, addScript test 6, 0.3', true)

pLine = ahk.addScript('MsgBox, 0, title, execLine test 7, 0.3')
print(ahk.execLine(pLine, 3, true))
```
