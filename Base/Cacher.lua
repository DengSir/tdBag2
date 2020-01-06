-- Cacher.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/6/2020, 4:12:47 PM

---@type ns
local ns = select(2, ...)

---@class tdBag2Cacher
local Cacher = ns.Addon:NewClass('Cacher')

function Cacher:Constructor()
    self._cache = {}
end

function Cacher:Generate(f)
    return function(obj, ...)
        local cache = self:FindCache(...)
        if not cache._cache then
            cache._cache = f(obj, ...)
        end
        return cache._cache
    end
end

function Cacher:Patch(cls, ...)
    for i = 1, select('#', ...) do
        local method = select(i, ...)
        cls[method] = self:Generate(cls[method])
    end
end

function Cacher:FindCache(...)
    local cache = self._cache
    for i = 1, select('#', ...) do
        local key = select(i, ...)
        cache[key] = cache[key] or {}
        cache = cache[key]
    end
    return cache
end

function Cacher:RemoveCache(...)
    wipe(self:FindCache(...))
end
