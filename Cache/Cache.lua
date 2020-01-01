-- Cache.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/1/2020, 12:22:38 AM

---@type ns
local ns = select(2, ...)

---@class tdBag2Cache
local Cache = ns.Cache

local CACHED_EMPTY = {cached = true}

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

local CachedInterface = {}
local CurrentInterface = {}

---@return tdBag2CacheOwnerData
function CachedInterface:GetOwnerInfo(realm, name)
    local realmData = ns.Forever.db[realm]
    local ownerData = realmData and realmData[name]
    if ownerData then
        return {
            name = name,
            realm = realm,
            faction = ownerData.faction,
            class = ownerData.class,
            race = ownerData.race,
            gender = ownerData.gender,
            money = ownerData.money,
            cached = true,
        }
    end
    return CACHED_EMPTY
end

function CachedInterface:GetBagInfo(realm, name, bag)
    ---@type tdBag2CacheBagData
    local data = {}
    local realmData = ns.Forever.db[realm]
    local ownerData = realmData and realmData[name]
    local bagData = ownerData and ownerData[bag]

    if ns.IsContainerBag(bag) then
        if ns.IsKeyring(bag) then
            data.family = 9
            data.owned = true
        elseif ns.IsBaseBag(bag) then
            data.count = GetContainerNumSlots(bag)
            data.owned = true
            data.family = 0
        end
    elseif bag == 'equip' then
        data.count = INVSLOT_LAST_EQUIPPED
    end

    data.cached = true

    if bagData then
        local free = 0
        for i = 1, data.count or bagData.size do
            if not bagData[i] then
                free = free + 1
            end
        end

        data.count = bagData.size or data.count
        data.family = bagData.family or data.family or 0
        data.owned = true
        data.free = free
        data.slot = ns.IsCustomBag(bag) and ContainerIDToInventoryID(bag) or nil

        if data.slot then
            local info = self:GetItemInfo(realm, name, 'equip', data.slot)
            data.icon = info.icon
            data.link = info.link
            data.id = info.id
        end
    end
    return data
end

function CachedInterface:GetItemInfo(realm, name, bag, slot)
    local realmData = ns.Forever.db[realm]
    local ownerData = realmData and realmData[name]
    local bagData = ownerData and ownerData[bag]
    local item = bagData and bagData[slot]
    if item then
        ---@type tdBag2CacheItemData
        local data = {}
        local link, count = strsplit(';', item)

        data.link = 'item:' .. link
        data.count = tonumber(count)
        data.cached = true
        data.id = tonumber(link:match('^(%d+)'))
        data.icon = GetItemIcon(data.link)
        local name, link, quality = GetItemInfo(data.link)
        if name then
            data.link = link
            data.quality = quality
        end
        return data
    end
    return CACHED_EMPTY
end

function CurrentInterface:GetOwnerInfo()
    ---@type tdBag2CacheOwnerData
    local data = {}
    data.name, data.realm = UnitName('player')
    data.class = UnitClassBase('player')
    data.faction = UnitFactionGroup('player')
    data.race = select(2, UnitRace('player'))
    data.gender = UnitSex('player')
    data.money = (GetMoney() or 0) - GetCursorMoney() - GetPlayerTradeMoney()
    return data
end

function CurrentInterface:GetBagInfo(bag)
    ---@type tdBag2CacheBagData
    local data = {}

    if ns.IsContainerBag(bag) then
        data.free, data.family = GetContainerNumFreeSlots(bag)
        data.count = GetContainerNumSlots(bag)

        if ns.IsCustomBag(bag) then
            data.slot = ContainerIDToInventoryID(bag)
            data.link = GetInventoryItemLink('player', data.slot)
            data.icon = GetInventoryItemTexture('player', data.slot)

            if ns.IsInBank(bag) then
                data.owned = (bag - NUM_BAG_SLOTS) <= GetNumBankSlots()
                data.cost = GetBankSlotCost()
            else
                data.owned = not not data.link
            end
        elseif ns.IsKeyring(bag) then
            data.family = 9
            data.owned = HasKey() or data.count > 0
            data.free = data.count and data.free and data.count + data.free - 32
        else
            data.owned = true
        end
    elseif bag == 'equip' then
        data.count = INVSLOT_LAST_EQUIPPED
        data.family = -4
        data.owned = true
    end
    return data
end

function CurrentInterface:GetItemInfo(bag, slot)
    ---@type tdBag2CacheItemData
    local data = {}
    if ns.IsContainerBag(bag) then
        local _
        data.icon, data.count, data.locked, data.quality, data.readable, _, data.link, _, _, data.id =
            GetContainerItemInfo(bag, slot)
    elseif bag == 'equip' then
        data.link = GetInventoryItemLink('player', slot)
        data.icon = GetInventoryItemTexture('player', slot)
        data.quality = GetInventoryItemQuality('player', slot)
        data.id = GetInventoryItemID('player', slot)
    end
    return data
end

local PLAYER = UnitName('player')
local REALM = GetRealmName()

function Cache:GetOwnerAddress(owner)
    return REALM, owner or PLAYER
end

function Cache:GetOwnerInfo(owner)
    local realm, name = self:GetOwnerAddress(owner)
    local cached = self:IsOwnerCached(realm, name)

    if cached then
        return CachedInterface:GetOwnerInfo(realm, name)
    else
        return CurrentInterface:GetOwnerInfo()
    end
end

function Cache:GetBagInfo(owner, bag)
    local realm, name = self:GetOwnerAddress(owner)
    local cached = self:IsBagCached(realm, name, bag)

    if cached then
        return CachedInterface:GetBagInfo(realm, name, bag)
    else
        return CurrentInterface:GetBagInfo(bag)
    end
end

function Cache:GetItemInfo(owner, bag, slot)
    local realm, name = self:GetOwnerAddress(owner)
    local cached = self:IsBagCached(realm, name, bag)

    if cached then
        return CachedInterface:GetItemInfo(realm, name, bag, slot)
    else
        return CurrentInterface:GetItemInfo(bag, slot)
    end
end

function Cache:IsOwnerCached(realm, name)
    return realm ~= REALM or name ~= PLAYER
end

function Cache:IsBagCached(realm, name, bag)
    if self:IsOwnerCached(realm, name) then
        return true
    end

    if ns.IsInBank(bag) and not ns.Forever.atBank then
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

function Cache:IterateOwners()
    return coroutine.wrap(function()
        for k, v in pairs(ns.Forever.db[REALM]) do
            coroutine.yield(k)
        end
    end)
end
