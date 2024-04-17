-- Locale.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/17/2024, 3:31:22 PM
--
local A = ...
local function T(l, f)
    local o = LibStub('AceLocale-3.0'):NewLocale(A, l)
    if o then f(o) end
end

T('deDE', function(L)
-- @locale:language=deDE@
-- @end-locale@
end)

T('esES', function(L)
-- @locale:language=esES@
-- @end-locale@
end)

T('frFR', function(L)
-- @locale:language=frFR@
-- @end-locale@
end)

T('itIT', function(L)
-- @locale:language=itIT@
-- @end-locale@
end)

T('koKR', function(L)
-- @locale:language=koKR@
-- @end-locale@
end)

T('ptBR', function(L)
-- @locale:language=ptBR@
-- @end-locale@
end)

T('ruRU', function(L)
-- @locale:language=ruRU@
-- @end-locale@
end)

T('zhTW', function(L)
-- @locale:language=zhTW@
-- @end-locale@
end)
