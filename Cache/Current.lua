-- Current.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/2/2020, 9:55:26 PM
--
---- LUA
local select = _G.select

local C = LibStub('C_Everywhere')

---- WOW
local GetBankSlotCost = _G.GetBankSlotCost
local GetInventoryItemID = _G.GetInventoryItemID
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventoryItemQuality = _G.GetInventoryItemQuality
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetCursorMoney = _G.GetCursorMoney
local GetMoney = _G.GetMoney
local GetNumBankSlots = _G.GetNumBankSlots
local GetPlayerTradeMoney = _G.GetPlayerTradeMoney
local HasKey = _G.HasKey
local UnitClassBase = _G.UnitClassBase
local UnitFactionGroup = _G.UnitFactionGroup
local UnitRace = _G.UnitRace
local UnitSex = _G.UnitSex

---- G
local INVSLOT_LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS

---@class ns
local ns = select(2, ...)

local KEYRING_FAMILY = ns.KEYRING_FAMILY

---@class Current
local Current = {}
ns.Current = Current

function Current:GetOwnerInfo()
    ---@type tdBag2OwnerInfo
    local data = {}
    data.name, data.realm = ns.PLAYER, ns.REALM
    data.class = UnitClassBase('player')
    data.faction = UnitFactionGroup('player')
    data.race = select(2, UnitRace('player'))
    data.gender = UnitSex('player')
    data.money = (GetMoney() or 0) - GetCursorMoney() - GetPlayerTradeMoney()
    return data
end

function Current:GetBagInfo(bag)
    ---@type tdBag2BagInfo
    local data = {}

    if ns.IsContainerBag(bag) then
        data.free, data.family = C.Container.GetContainerNumFreeSlots(bag)
        data.count = C.Container.GetContainerNumSlots(bag)

        if ns.IsCustomBag(bag) then
            data.slot = ns.BagToSlot(bag)
            data.link = GetInventoryItemLink('player', data.slot)
            data.icon = GetInventoryItemTexture('player', data.slot)

            if ns.IsInBank(bag) then
                data.owned = (bag - NUM_BAG_SLOTS) <= GetNumBankSlots()
                data.cost = GetBankSlotCost()
            else
                data.owned = true
            end
        elseif ns.IsKeyring(bag) then
            data.family = KEYRING_FAMILY
            data.owned = HasKey() or data.count > 0
            data.free = data.count and data.free and data.count + data.free - 32
        else
            data.owned = true
        end
    elseif ns.IsEquip(bag) then
        data.count = INVSLOT_LAST_EQUIPPED
        data.family = -4
        data.owned = true
    end
    return data
end

function Current:GetItemInfo(bag, slot)
    ---@type tdBag2ItemInfo
    local data = {}
    if ns.IsContainerBag(bag) then
        data.id = C.Container.GetContainerItemID(bag, slot)
        data.link = C.Container.GetContainerItemLink(bag, slot)
        local info = C.Container.GetContainerItemInfo(bag, slot)
        if info then
            data.icon = info.iconFileID
            data.count = info.stackCount
            data.locked = info.isLocked
            data.quality = info.quality
            data.readable = info.isReadable
        end
    elseif ns.IsEquip(bag) then
        data.link = GetInventoryItemLink('player', slot)
        data.icon = GetInventoryItemTexture('player', slot)
        data.quality = GetInventoryItemQuality('player', slot)
        data.id = GetInventoryItemID('player', slot)
    end
    return data
end
