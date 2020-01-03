-- Cache.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/1/2020, 12:22:38 AM

---@type ns
local ns = select(2, ...)
local Forever = ns.Forever
local Current = ns.Current

---@class tdBag2CacheOwnerData
---@field name string
---@field realm string
---@field faction string
---@field class string
---@field race string
---@field gender number
---@field cached boolean
---@field money number

---@class tdBag2CacheBagData
---@field slot number
---@field owned boolean
---@field cached boolean
---@field count number
---@field free number
---@field family number
---@field cost number
---@field link string
---@field icon string
---@field id number

---@class tdBag2CacheItemData
---@field link string
---@field count number
---@field cached boolean
---@field icon string
---@field locked boolean
---@field quality number
---@field id number
---@field readable boolean

---@class tdBag2Cache
local Cache = {}
ns.Cache = Cache

local CACHED_EMPTY = {cached = true}
local PLAYER = ns.PLAYER
local REALM = ns.REALM

function Cache:GetOwnerAddress(owner)
    return REALM, owner or PLAYER
end

function Cache:GetOwnerInfo(owner)
    local realm, name = self:GetOwnerAddress(owner)
    local cached = self:IsOwnerCached(realm, name)

    if cached then
        return Forever:GetOwnerInfo(realm, name)
    else
        return Current:GetOwnerInfo()
    end
end

function Cache:GetBagInfo(owner, bag)
    print(owner, bag)
    local realm, name = self:GetOwnerAddress(owner)
    local cached = self:IsBagCached(realm, name, bag)

    if cached then
        return Forever:GetBagInfo(realm, name, bag)
    else
        return Current:GetBagInfo(bag)
    end
end

function Cache:GetItemInfo(owner, bag, slot)
    local realm, name = self:GetOwnerAddress(owner)
    local cached = self:IsBagCached(realm, name, bag)

    if cached then
        return Forever:GetItemInfo(realm, name, bag, slot)
    else
        return Current:GetItemInfo(bag, slot)
    end
end

function Cache:IsOwnerCached(realm, name)
    return realm ~= REALM or name ~= PLAYER
end

function Cache:IsBagCached(realm, name, bag)
    if self:IsOwnerCached(realm, name) then
        return true
    end

    if ns.IsInBank(bag) and not Forever.atBank then
        return true
    end

    if ns.IsMail(bag) or ns.IsEquip(bag) then
        return true
    end
end

function Cache:GetItemID(owner, bag, slot)
    local info = self:GetItemInfo(owner, bag, slot)
    return info and info.id
end

function Cache:IsOwnerBagCached(owner, bag)
    local realm, name = self:GetOwnerAddress(owner)
    return self:IsBagCached(realm, name, bag)
end

function Cache:GetOwners()
    return Forever:GetOwners()
end

function Cache:HasMultiOwners()
    return Forever:HasMultiOwners()
end
