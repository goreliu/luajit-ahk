# luajit-ahk
LuaJIT FFI binding for [AutoHotkey_H](https://hotkeyit.github.io/v2/) v1.

## Installation

**UNICODE version of AutoHotkey.dll should be put into the directory of lua51.dll first.**

Install with [luarocks](https://luarocks.org/) [(luajit-ahk)](https://luarocks.org/modules/goreliu/luajit-ahk):

```
luarocks install luajit-ahk
```

Or download [master.zip](https://github.com/goreliu/luajit-ahk/archive/master.zip), use `src/ahk.lua` and `src/utf8fix.lua`.

## Example

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
-- ignoreError: 0(signal an error if there was problem adding file, default)
--              1(ignore error)
--              2(remove script lines added by previous calls to addFile()
--                and start executing at the first line in the new script)
-- return: A pointer to the first line of new created code.
addFile(path, reload, ignoreError)

-- return: ffi.load('AutoHotkey')
C()

```

## C API

```
ffi.cdef[[
typedef wchar_t *Str;
typedef unsigned int UInt;
typedef UInt *UPtr;

// scriptPath: A path to existing ahk file.
// options: Additional parameter passed to AutoHotkey.dll.
// parameters: Parameters passed to dll.
// return: A thread handle.
UPtr ahkDll(Str scriptPath, Str options, Str parameters);

// script: A string with ahk script.
// options: Additional parameter passed to AutoHotkey.dll.
// parameters: Parameters passed to dll.
// return: A thread handle.
UPtr ahkTextDll(Str script, Str options, Str parameters);

// return: 1 if a thread is running or 0 otherwise.
int ahkReady();

// script: A string with ahk script.
// return: 1 if script was executed and 0 if there was an error.
int ahkExec(Str script);

// varName: Name of a variable.
// value: Name of a variable.
// return: 0 on success and -1 on failure.
int ahkAssign(Str varName, Str value);

// varName: Name of variable to get value from.
// getPointer: Use 1 to get pointer of variable, else 0 to get the value.
// return: Always a string, empty string if variable does not exist or is empty.
Str ahkGetVar(Str varName, UInt getPointer);

// timeout: Time in milliseconds to wait until thread exits.
// return: Returns always 0.
int ahkTerminate(int timeout);

// timeout: Time in milliseconds to wait until thread exits.
// return: ?
int ahkReload(int timeout);

// operation: Pause or un-pause a script, on/off/1/0.
// return: 1 if thread is paused or 0 if it is not.
int ahkPause(Str operation);

// Launch a Goto/Gosub routine in script.
// name: Name of label to execute.
// nowait: Do not to wait until execution finished. 0 - Gosub (default) 1 - Goto (PostMessage mode)
// return: 1 if label exists 0 otherwise.
UInt ahkLabel(Str name, UInt nowait);

// Launch a function in script.
// name: Name of function to call.
// p*: Name of function to call.
// return: Always a string.
Str ahkFunction(Str name, Str p1, Str p2, Str p3, Str p4, Str p5,
    Str p6, Str p7, Str p8, Str p9, Str p10);

// Like ahkFunction, but run in background and return value will be ignored.
// return: 0 if function exists else -1.
UInt ahkPostFunction(Str name, Str p1, Str p2, Str p3, Str p4, Str p5,
    Str p6, Str p7, Str p8, Str p9, Str p10);

// script: Script that will be added to a running script.
// execute: 1(execute) 0(do not execute).
// return: A pointer to the first line of new created code.
UPtr addScript(Str script, int execute);

// pointerLine: A pointer to the line where execution will start.
// mode: 0 will not execute but return a pointer to next line.
//       1 UNTIL_RETURN
//       2 UNTIL_RETURN
//       3 ONLY_ONE_LINE
// wait: Set 1 to wait until the execution finished, 0 otherwise.
//       Be careful as it may happen that the dll call never returns!
// return: If no pointerLine is passed it returns a pointer to FirstLine,
//         else it returns a pointer to NextLine.
UPtr ahkExecuteLine(UPtr pointerLine, UInt mode, UInt wait);

// path: Path to a file that will be added to a running script.
// allowDuplicateInclude: 0(if already loaded, ignore)
//                        1(load it again)
// ignoreLoadFailure: 0(signal an error if there was problem adding file)
//                    1(ignore error)
//                    2(remove script lines added by previous calls to addFile()
//                      and start executing at the first line in the new script)
// return: A pointer to the first line of new created code.
UPtr addFile(Str path, int allowDuplicateInclude, int ignoreLoadFailure);

// ahkFindLabel
// ahkFindFunc
]]
```
