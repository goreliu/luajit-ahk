# luajit-ahk
LuaJIT FFI binding for [AutoHotkey_H](https://hotkeyit.github.io/v2/) v1.

UNICODE version of AutoHotkey.dll should be put into the directory of lua51.dll.

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

## API
```
-- return: true(success) false(error)
init()

-- script: A string with ahk script.
-- options: Additional parameter passed to AutoHotkey.dll.
-- parameters: Parameters passed to dll.
-- return: true(success) false(error)
initWithText(script, options, parameters)

-- scriptPath: A path to existing ahk file.
-- options: Additional parameter passed to AutoHotkey.dll.
-- parameters: Parameters passed to dll.
-- return: true(success) false(error)
initWithFile(scriptPath, options, parameters)

-- return: true(success) false(error)
exec(script)

-- return: true(success) false(error)
setVar(name, value)

-- getPointer: true(get pointer of variable) false(get the value, default)
-- return: string
getVar(name, getPointer)

-- return: true(label exists) false(otherwise)
label(name)

-- return: true(label exists) false(otherwise)
postLabel(name)

-- return: string
func(name, ...)

-- return: true(function exists) false(otherwise)
postFunc(name, ...)

-- return: true(therad is paused) false(otherwise)
pause()

-- return: true(therad is resumed) false(otherwise)
resume()

-- return: true(a thread is running) false(otherwise)
ready()

-- timeout: Time in milliseconds to wait until thread exits, default 0.
terminate(timeout)

-- timeout: Time in milliseconds to wait until thread exits, default 0.
reload(timeout)

-- execute: true(execute) false(do not execute, default)
-- return: A pointer to the first line of new created code.
addScript(script, execute)

-- pLine: A pointer to the line where execution will start or nil(default).
-- mode: 0(do not execute, default)
--       1(until return)
--       2(until block end)
--       3(only one line)
-- wait: true(wait) false(do not wait, default)
execLine(pLine, mode, wait)

-- reload: true(reload) false(do not reload, default)
-- ignoreError: 0(signal an error, default) 1(ignore error) 2
-- return: A pointer to the first line of new created code.
addFile(path, reload, ignoreError)

-- return: ffi.load('AutoHotkey')
C()

```
