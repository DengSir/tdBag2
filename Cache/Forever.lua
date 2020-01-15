-- Forever.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/31/2019, 1:07:26 PM

---- LUA
local select, pairs, ipairs = select, pairs, ipairs
local tinsert = table.insert
local tonumber = tonumber
local strsplit = strsplit
local tDeleteItem = tDeleteItem

---- WOW
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local GetInventoryItemCount = GetInventoryItemCount
local GetInventoryItemLink = GetInventoryItemLink
local GetItemIcon = GetItemIcon
local GetItemInfo = GetItemInfo
local GetMoney = GetMoney
local IsLoggedIn = IsLoggedIn
local UnitClassBase = UnitClassBase
local UnitFactionGroup = UnitFactionGroup
local UnitFullName = UnitFullName
local UnitRace = UnitRace
local UnitSex = UnitSex

---- G
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local INVSLOT_LAST_EQUIPPED = INVSLOT_LAST_EQUIPPED

---@type ns
local ns = select(2, ...)

local BAGS = ns.GetBags(ns.BAG_ID.BAG)
local BANKS = ns.GetBags(ns.BAG_ID.BANK)
local NO_RESULT = {cached = true}

---@class tdBag2ForeverCharacter
---@field faction string
---@field class string
---@field race string
---@field gender number
---@field money number

---@alias tdBag2ForeverRealm table<string, tdBag2ForeverCharacter>
---@alias tdBag2ForeverDB table<string, tdBag2ForeverRealm>

---@class tdBag2Forever
---@field player tdBag2ForeverCharacter
---@field realm tdBag2ForeverRealm
---@field db tdBag2ForeverDB
---@field owners string[]
local Forever = ns.Addon:NewModule('Forever', 'AceEvent-3.0')

function Forever:OnInitialize()
    self.Cacher = ns.Cacher:New()
    self.Cacher:Patch(self, 'GetBagInfo', 'GetOwnerInfo', 'GetItemInfo')

    if IsLoggedIn() then
        self:PLAYER_LOGIN()
    else
        self:RegisterEvent('PLAYER_LOGIN')
    end
end

function Forever:PLAYER_LOGIN()
    self:SetupCache()
    self:SetupEvents()
    self:Update()
end

function Forever:SetupCache()
    local player, realm = UnitFullName('player')

    self.db = ns.Addon.db.global.forever
    self.db[realm] = self.db[realm] or {}
    self.realm = self.db[realm]
    self.realm[player] = self.realm[player] or {}
    self.player = self.realm[player]
    self.player[ns.EQUIP_CONTAINER] = self.player[ns.EQUIP_CONTAINER] or {}
    self.player[ns.MAIL_CONTAINER] = self.player[ns.MAIL_CONTAINER] or {}

    self.player.faction = UnitFactionGroup('player')
    self.player.class = UnitClassBase('player')
    self.player.race = select(2, UnitRace('player'))
    self.player.gender = UnitSex('player')

    local owners = {player}
    for k in pairs(self.realm) do
        if k ~= player then
            tinsert(owners, k)
        end
    end

    self.owners = owners
end

function Forever:SetupEvents()
    self:RegisterEvent('BAG_UPDATE')
    self:RegisterEvent('BAG_CLOSED')
    self:RegisterEvent('PLAYER_MONEY')
    self:RegisterEvent('BANKFRAME_OPENED')
    self:RegisterEvent('BANKFRAME_CLOSED')
    self:RegisterEvent('MAIL_SHOW')
    self:RegisterEvent('MAIL_CLOSED')
    self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
end

function Forever:Update()
    for _, bag in ipairs(BAGS) do
        self:SaveBag(bag)
    end

    for slot = 1, INVSLOT_LAST_EQUIPPED do
        self:SaveEquip(slot)
    end

    self:PLAYER_MONEY()
end

---- Events

function Forever:BANKFRAME_OPENED()
    self.atBank = true
    self.Cacher:RemoveCache(ns.REALM, ns.PLAYER)
    self:SendMessage('BANK_OPENED')
end

function Forever:BANKFRAME_CLOSED()
    if self.atBank then
        for _, bag in ipairs(ns.GetBags(ns.BAG_ID.BANK)) do
            self:SaveBag(bag)
        end
        self.atBank = nil
    end
    self:SendMessage('BANK_CLOSED')
end

function Forever:MAIL_SHOW()
    self.atMail = true
    self.Cacher:RemoveCache(ns.REALM, ns.PLAYER)
end

function Forever:MAIL_CLOSED()
    if not self.atMail then
        return
    end

    local db = wipe(self.player[ns.MAIL_CONTAINER])
    local now = time()

    local num, total = GetInboxNumItems()
    for i = 1, num do
        local daysLeft = select(7, GetInboxHeaderInfo(i))
        local timeout = now + daysLeft * 86400
        for j = 1, ATTACHMENTS_MAX_RECEIVE do
            local link = GetInboxItemLink(i, j)
            if link then
                local count = select(4, GetInboxItem(i, j))

                tinsert(db, self:ParseItem(link, count, timeout))
            end
        end
    end

    db.size = #db
    self.Cacher:RemoveCache(ns.REALM, ns.PLAYER)
end

function Forever:BAG_UPDATE(_, bag)
    if bag <= NUM_BAG_SLOTS then
        self:SaveBag(bag)
    end
end

Forever.BAG_CLOSED = ns.Spawned(Forever.BAG_UPDATE)

function Forever:PLAYER_MONEY()
    self.player.money = GetMoney()
end

function Forever:PLAYER_EQUIPMENT_CHANGED(_, slot)
    self:SaveEquip(slot)
end

function Forever:ParseItem(link, count, timeout)
    if link then
        if link:find('0:0:0:0:0:%d+:%d+:%d+:0:0') then
            link = link:match('|H%l+:(%d+)')
        else
            link = link:match('|H%l+:([%d:]+)')
        end

        local count = count and count > 1 and count or nil
        if count or timeout then
            link = link .. ';' .. (count or '')
        end
        if timeout then
            link = link .. ';' .. timeout
        end
        return link
    end
end

function Forever:SaveBag(bag)
    local size = GetContainerNumSlots(bag)
    local items
    if size > 0 then
        items = {}
        items.size = size
        items.family = not ns.IsBaseBag(bag) and select(2, GetContainerNumFreeSlots(bag)) or nil

        for slot = 1, size do
            local _, count, _, _, _, _, link = GetContainerItemInfo(bag, slot)
            items[slot] = self:ParseItem(link, count)
        end

        if not ns.IsBaseBag(bag) then
            self:SaveEquip(ContainerIDToInventoryID(bag))
        end
    end
    self.player[bag] = items
end

function Forever:SaveEquip(slot)
    local link = GetInventoryItemLink('player', slot)
    local count = GetInventoryItemCount('player', slot)

    self.player[ns.EQUIP_CONTAINER][slot] = self:ParseItem(link, count)
end

function Forever:FindData(...)
    local db = self.db
    for i = 1, select('#', ...) do
        local key = select(i, ...)
        db = db[key]
        if not db then
            return
        end
    end
    return db
end

---- interface

function Forever:GetOwnerInfo(realm, name)
    local ownerData = self:FindData(realm, name)
    if ownerData then
        ---@type tdBag2CacheOwnerData
        local data = {}
        data.cached = true
        data.name = name
        data.realm = realm
        data.faction = ownerData.faction
        data.class = ownerData.class
        data.race = ownerData.race
        data.gender = ownerData.gender
        data.money = ownerData.money
        return data
    end
    return NO_RESULT
end

function Forever:GetBagInfo(realm, name, bag)
    ---@type tdBag2CacheBagData
    local data = {}
    local bagData = self:FindData(realm, name, bag)

    data.cached = true

    if ns.IsContainerBag(bag) then
        if ns.IsKeyring(bag) then
            data.family = 9
            data.owned = true
        elseif ns.IsBaseBag(bag) then
            data.count = GetContainerNumSlots(bag)
            data.owned = true
            data.family = 0
        end
    elseif ns.IsEquip(bag) then
        data.count = INVSLOT_LAST_EQUIPPED
    end

    if bagData then
        local free = 0
        for i = 1, data.count or bagData.size or 0 do
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
            local info = self:GetItemInfo(realm, name, ns.EQUIP_CONTAINER, data.slot)
            data.icon = info.icon
            data.link = info.link
            data.id = info.id
        end
    end
    return data
end

function Forever:GetItemInfo(realm, name, bag, slot)
    local itemData = self:FindData(realm, name, bag, slot)
    if itemData then
        ---@type tdBag2CacheItemData
        local data = {}
        local link, count, timeout = strsplit(';', itemData)

        data.cached = true
        data.link = 'item:' .. link
        data.count = tonumber(count)
        data.id = tonumber(link:match('^(%d+)'))
        data.icon = GetItemIcon(data.id)
        data.timeout = tonumber(timeout)

        local name, link, quality = GetItemInfo(data.link)
        if name then
            data.link = link
            data.quality = quality
        end
        return data
    end
    return NO_RESULT
end

function Forever:GetOwners()
    return self.owners
end

function Forever:HasMultiOwners()
    return #self.owners > 1
end

function Forever:DeleteOwnerInfo(realm, name)
    local realmData = self.db[realm]
    if realmData then
        realmData[name] = nil

        if realmData == self.realm then
            tDeleteItem(self.owners, name)
            ns.Events:Fire('OWNER_REMOVED')
        end
    end
end
