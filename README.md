# luajit-ahk
LuaJIT FFI binding for [AutoHotkey_H](https://hotkeyit.github.io/v2/) v1.

**UNICODE version of AutoHotkey.dll should be put into the directory of lua51.dll.**

## example

```
local ahk = require 'ahk'

-- init()
ahk.init()

-- exec()
ahk.exec('MsgBox, exec test')

ahk.exec([[
    a := 333
    b := "getVar test"
]])

-- setVar()
ahk.setVar('b', 'getVar new test')

-- getVar()
print(ahk.getVar('a'))
ahk.exec('MsgBox, ' .. ahk.getVar('b'))

ahk.exec([[
Fun(Text) {
    MsgBox, % Text
    return Text
}

return

La:
    MsgBox, label test
    return
]])

-- func()
print(ahk.func('Fun', 'func test'))

-- label()
print(ahk.label('La'))

-- addScript()
ahk.addScript('MsgBox, addScript test', true)

-- execLine()
pLine = ahk.addScript('MsgBox, execLine test')
print(ahk.execLine(pLine, 3, true))

-- C()
local L = require 'utf8fix'.L
ahk.C().ahkExec(L'MsgBox, C test')

-- initWithText()
ahk.initWithText('#Persistent\nMsgbox, initWithText test %1%', nil, 'abc')

ahk.exec('Sleep, 2000')
```

## API
```
-- Load AutoHotkey.dll and call ahkTextDll with
--     #NoEnv
--     #NoTrayIcon
--     #Persistent
--     SetBatchLines, -1
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

-- Launch a Gosub routine in script.
-- return: true(label exists) false(otherwise)
label(name)

-- Like label(), but do not wait until execution finished. 
-- return: true(label exists) false(otherwise)
postLabel(name)

-- Launch a function in script.
-- return: string
func(name, ...)

-- Like func(), but run in background and return value will be ignored.
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

-- script: Script that will be added to a running script.
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

-- path: Path to a file that will be added to a running script.
-- reload: true(reload) false(do not reload, default)
-- ignoreError: 0(signal an error, default) 1(ignore error) 2
-- return: A pointer to the first line of new created code.
addFile(path, reload, ignoreError)

-- return: ffi.load('AutoHotkey')
C()

```
