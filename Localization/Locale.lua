-- Locale.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/11/2024, 3:43:22 PM
--
local ADDON = ...
local function Apply(locale, apply)
    local L = LibStub('AceLocale-3.0'):NewLocale(ADDON, locale)
    if L then
        apply(L)
    end
end

Apply('deDE', function(L)
-- @locale:language=deDE@
-- @end-locale@
end)

Apply('esES', function(L)
    -- @locale:language=esES@
    -- @end-locale@
end)

Apply('frFR', function(L)
    -- @locale:language=frFR@
    -- @end-locale@
end)

Apply('itIT', function(L)
    -- @locale:language=itIT@
    -- @end-locale@
end)
Apply('koKR', function(L)
    -- @locale:language=koKR@
    -- @end-locale@
end)

Apply('ptBR', function(L)
    -- @locale:language=ptBR@
    -- @end-locale@
end)

Apply('ruRU', function(L)
    -- @locale:language=ruRU@
    -- @end-locale@
end)

Apply('zhTW', function(L)
    -- @locale:language=zhTW@
    -- @end-locale@
end)
