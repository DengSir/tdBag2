-- Forever.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/31/2019, 1:07:26 PM

---@type ns
local ns = select(2, ...)

local BAGS = ns.GetBags(ns.BAG_ID.BAG)
local BANKS = ns.GetBags(ns.BAG_ID.BANK)

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
local Forever = ns.Addon:NewModule('Forever', 'AceEvent-3.0')

function Forever:OnInitialize()
    self.cache = {}

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
    self.realm[player] = self.realm[player] or {equip = {}}
    self.player = self.realm[player]

    self.player.faction = UnitFactionGroup('player')
    self.player.class = UnitClassBase('player')
    self.player.race = select(2, UnitRace('player'))
    self.player.gender = UnitSex('player')
end

function Forever:SetupEvents()
    self:RegisterEvent('BAG_UPDATE')
    self:RegisterEvent('BAG_CLOSED')
    self:RegisterEvent('PLAYER_MONEY')
    self:RegisterEvent('BANKFRAME_OPENED')
    self:RegisterEvent('BANKFRAME_CLOSED')
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

function Forever:BAG_CLOSED(_, bag)
    C_Timer.After(0, function()
        self:BAG_UPDATE(nil, bag)
    end)
end

function Forever:BAG_UPDATE(_, bag)
    if bag <= NUM_BAG_SLOTS then
        self:SaveBag(bag)
    end
end

function Forever:PLAYER_MONEY()
    self.player.money = GetMoney()
end

function Forever:PLAYER_EQUIPMENT_CHANGED(_, slot)
    self:SaveEquip(slot)
end

----

function Forever:ParseItem(link, count)
    if link then
        local id = tonumber(link:match('item:(%d+):')) -- check for profession window bug
        if not id or id == 0 then
            error('111')
        end
        -- if id == 0 and TradeSkillFrame then
        --     local focus = GetMouseFocus():GetName()

        --     if focus == 'TradeSkillSkillIcon' then
        --         link = GetTradeSkillItemLink(TradeSkillFrame.selectedSkill)
        --     else
        --         local i = focus:match('TradeSkillReagent(%d+)')
        --         if i then
        --             link = GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, tonumber(i))
        --         end
        --     end
        -- end

        if link:find('0:0:0:0:0:%d+:%d+:%d+:0:0') then
            link = link:match('|H%l+:(%d+)')
        else
            link = link:match('|H%l+:([%d:]+)')
        end

        if count and count > 1 then
            link = link .. ';' .. count
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

    self.player.equip[slot] = self:ParseItem(link, count)
end

---- interface

local NO_RESULT = {cached = true}

local function Cached(f)
    return function(self, ...)
        local key = table.concat({tostringall(...)}, '/')
        local cache = self.cache[key]
        if not cache then
            print(key)
            cache = f(self, ...)
            self.cache[key] = cache

        end
        return cache
    end
end

function Forever:FindData(...)
    print(...)
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

function Forever:GetOwnerInfo(realm, name)
    local realmData = self.db[realm]
    local ownerData = realmData[name]
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
    elseif bag == 'equip' then
        data.count = INVSLOT_LAST_EQUIPPED
    end

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

function Forever:GetItemInfo(realm, name, bag, slot)
    local itemData = self:FindData(realm, name, bag, slot)
    if itemData then
        ---@type tdBag2CacheItemData
        local data = {}
        local link, count = strsplit(';', itemData)

        data.cached = true
        data.link = 'item:' .. link
        data.count = tonumber(count)
        data.id = tonumber(link:match('^(%d+)'))
        data.icon = GetItemIcon(data.id)

        local name, link, quality = GetItemInfo(data.link)
        if name then
            data.link = link
            data.quality = quality
        end
        return data
    end
    return NO_RESULT
end

Forever.GetOwnerInfo = Cached(Forever.GetOwnerInfo)
Forever.GetBagInfo = Cached(Forever.GetBagInfo)
Forever.GetItemInfo = Cached(Forever.GetItemInfo)
