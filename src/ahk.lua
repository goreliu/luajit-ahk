local M = {}

local ffi = require 'ffi'

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

local utf8fix = require 'utf8fix'
local L = utf8fix.L
local w2u = utf8fix.w2u

local C = nil

-- Load AutoHotkey.dll and call ahkTextDll with
--     #NoEnv
--     #NoTrayIcon
--     #Persistent
--     SetBatchLines, -1
-- return: true(success) false(error)
function M.init()
    if C ~= nil then
        return true
    end

    C = ffi.load('AutoHotkey')
    return C.ahkTextDll(L[[
        #NoEnv
        #NoTrayIcon
        #Persistent
        SetBatchLines, -1
        ]], nil, nil) ~= nil
end

-- script: A string with ahk script.
-- options: Additional parameter passed to AutoHotkey.dll.
-- parameters: Parameters passed to dll.
-- return: true(success) false(error)
function M.initWithText(script, options, parameters)
    if C == nil then
        C = ffi.load('AutoHotkey')
    end

    return C.ahkTextDll(L(script), L(options), L(parameters)) ~= nil
end

-- scriptPath: A path to existing ahk file.
-- options: Additional parameter passed to AutoHotkey.dll.
-- parameters: Parameters passed to dll.
-- return: true(success) false(error)
function M.initWithFile(scriptPath, options, parameters)
    if C == nil then
        C = ffi.load('AutoHotkey')
    end

    return C.ahkDll(L(scriptPath), L(options), L(parameters)) ~= nil
end

-- return: true(success) false(error)
function M.exec(script)
    return C.ahkExec(L(script)) == 1
end

-- return: true(success) false(error)
function M.setVar(name, value)
    return C.ahkAssign(L(name), L(value)) == 0
end

-- getPointer: true(get pointer of variable) false(get the value, default)
-- return: string
function M.getVar(name, getPointer)
    return w2u(C.ahkGetVar(L(name), getPointer and 1 or 0), -1)
end

-- Launch a Gosub routine in script.
-- return: true(label exists) false(otherwise)
function M.label(name)
    return C.ahkLabel(L(name), 0) == 1
end

-- Like label(), but do not wait until execution finished. 
-- return: true(label exists) false(otherwise)
function M.postLabel(name)
    return C.ahkLabel(L(name), 1) == 1
end

-- Launch a function in script.
-- return: string
function M.func(name, ...)
    local p1, p2, p3, p4, p5, p6, p7, p8, p9, p10 = ...
    local ret = C.ahkFunction(L(name), L(p1), L(p2), L(p3), L(p4), L(p5),
        L(p6), L(p7), L(p8), L(p9), L(p10))
    return w2u(ret, -1)
end

-- Like func(), but run in background and return value will be ignored.
-- return: true(function exists) false(otherwise)
function M.postFunc(name, ...)
    local p1, p2, p3, p4, p5, p6, p7, p8, p9, p10 = ...
    return C.ahkPostFunction(L(name), L(p1), L(p2), L(p3), L(p4), L(p5),
        L(p6), L(p7), L(p8), L(p9), L(p10)) == 0
end

-- return: true(therad is paused) false(otherwise)
function M.pause()
    return C.ahkPause(L'1') == 1
end

-- return: true(therad is resumed) false(otherwise)
function M.resume()
    return C.ahkPause(L'0') == 0
end

-- return: true(a thread is running) false(otherwise)
function M.ready()
    return C.ahkReady() == 1
end

-- timeout: Time in milliseconds to wait until thread exits, default 0.
function M.terminate(timeout)
    C.ahkTerminate(timeout or 0)
end

-- timeout: Time in milliseconds to wait until thread exits, default 0.
function M.reload(timeout)
    C.ahkReload(timeout or 0)
end

-- script: Script that will be added to a running script.
-- execute: true(execute) false(do not execute, default)
-- return: A pointer to the first line of new created code.
function M.addScript(script, execute)
    return C.addScript(L(script), execute and 1 or 0)
end

-- pLine: A pointer to the line where execution will start or nil(default).
-- mode: 0(do not execute, default)
--       1(until return)
--       2(until block end)
--       3(only one line)
-- wait: true(wait) false(do not wait, default)
function M.execLine(pLine, mode, wait)
    return C.ahkExecuteLine(pLine, mode or 0, wait and 1 or 0)
end

-- path: Path to a file that will be added to a running script.
-- reload: true(reload) false(do not reload, default)
-- ignoreError: 0(signal an error if there was problem adding file, default)
--              1(ignore error)
--              2(remove script lines added by previous calls to addFile()
--                and start executing at the first line in the new script)
-- return: A pointer to the first line of new created code.
function M.addFile(path, reload, ignoreError)
    return C.addFile(path, reload and 1 or 0, ignoreError or 0)
end

-- return: ffi.load('AutoHotkey')
function M.C()
    return C
end

return M
