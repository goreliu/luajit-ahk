-- https://github.com/actboy168/ydhost/blob/master/tools/mapdump/lua/ffi/unicode.lua

--[[ Usage 
local utf8fix = require 'utf8fix'
local L = utf8fix.L
local A = utf8fix.A
--]]

local ffi = require 'ffi'

ffi.cdef[[
int MultiByteToWideChar(unsigned int CodePage,
    unsigned long dwFlags,
    const char* lpMultiByteStr,
    int cbMultiByte,
    wchar_t* lpWideCharStr,
    int cchWideChar);

int WideCharToMultiByte(unsigned int CodePage,
    unsigned long dwFlags,
    const wchar_t* lpWideCharStr,
    int cchWideChar,
    char* lpMultiByteStr,
    int cchMultiByte,
    const char* lpDefaultChar,
    int* pfUsedDefaultChar);
]]

local CP_UTF8 = 65001
local CP_ACP = 0

-- UTF-8 to UTF-16
local function u2w(input)
    local wlen = ffi.C.MultiByteToWideChar(CP_UTF8, 0, input, #input, nil, 0)
    local wstr = ffi.new('wchar_t[?]', wlen + 1)
    ffi.C.MultiByteToWideChar(CP_UTF8, 0, input, #input, wstr, wlen)

    return wstr, wlen
end

-- UTF-16 to UTF-8
local function w2u(wstr, wlen)
    local len = ffi.C.WideCharToMultiByte(CP_UTF8, 0, wstr, wlen, nil, 0, nil, nil)
    local str = ffi.new('char[?]', len + 1)
    ffi.C.WideCharToMultiByte(CP_UTF8, 0, wstr, wlen, str, len, nil, nil)

    return ffi.string(str)
end

-- ANSI to UTF-16
local function a2w(input)
    local wlen = ffi.C.MultiByteToWideChar(CP_ACP, 0, input, #input, nil, 0)
    local wstr = ffi.new('wchar_t[?]', wlen + 1)
    ffi.C.MultiByteToWideChar(CP_ACP, 0, input, #input, wstr, wlen)

    return wstr, wlen
end

-- UTF-16 to ANSI
local function w2a(wstr, wlen)
    local len = ffi.C.WideCharToMultiByte(CP_ACP, 0, wstr, wlen, nil, 0, nil, nil)
    local str = ffi.new('char[?]', len + 1)
    ffi.C.WideCharToMultiByte(CP_ACP, 0, wstr, wlen, str, len, nil, nil)

    return ffi.string(str)
end

return {
    u2w = u2w,
    w2u = w2u,
    a2w = a2w,
    w2a = w2a,
    u2a = function(input)
        return w2a(u2w(input))
    end,
    a2u = function(input)
        return w2u(a2w(input))
    end,
    L = function(input)
        if input == nil then
            return nil
        end

        return (u2w(input))
    end,
    A = function(input)
        if input == nil then
            return nil
        end

        return w2a(u2w(input))
    end,
    Pass = function(input)
        return input
    end,
}
