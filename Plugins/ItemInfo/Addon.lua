-- tdBag2_ItemLevel.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/30/2020, 12:09:19 AM
--
local Addon = tdBag2
if not Addon then
    return
end

if not Addon.RegisterPlugin or not Addon.SetupPluginOptions then
    return print('You must update tdBag2 to use Item level')
end

local L = LibStub('AceLocale-3.0'):GetLocale('tdBag2')

local PLUGIN = 'ItemLevel'

local tonumber = tonumber
local format = format
local strmatch = strmatch

local C = LibStub('C_Everywhere')

local IsEquippableItem = IsEquippableItem
local GetItemInfo = GetItemInfo
local GetItemInfoInstant = GetItemInfoInstant

local BIND_TRADE_TIME_REMAINING_P = BIND_TRADE_TIME_REMAINING:gsub('%%s', '(.+)')
local HOURS_P = FORMATED_HOURS:gsub('%%d', '(%%d+)')
local MINUTES_P = COMMUNITIES_INVITE_MANAGER_EXPIRES:gsub('%%d', '(%%d+)')

local EPIC = Enum.ItemQuality.Epic
local MISC = Enum.ItemClass.Miscellaneous
local LE_ITEM_BIND_ON_EQUIP = LE_ITEM_BIND_ON_EQUIP

local ITEM_LEVEL_IGNORES = { --
    INVTYPE_BAG = true,
    INVTYPE_AMMO = true,
}

local profile = setmetatable({}, {
    __index = function(_, k)
        return Addon.db.profile[PLUGIN][k]
    end,
})

local function Constructor(button)
    local text = button:CreateFontString(nil, 'OVERLAY', 'NumberFontNormalYellow')
    text:SetPoint('TOPLEFT', 3, -3)

    button.Expire = text
end

local function CanShowItemLevel(item)
    if not profile.showItemLevel then
        return false
    end
    if not item.hasItem then
        return false
    end
    if not IsEquippableItem(item.info.id) then
        return false
    end
    local invType = select(4, GetItemInfoInstant(item.info.id))
    return invType and not ITEM_LEVEL_IGNORES[invType]
end

local function CanShowInfo(item)
    if not item.hasItem then
        return false
    end
    if not item.meta:IsBag() then
        return false
    end
    if item.meta:IsCached() then
        return false
    end
    if IsEquippableItem(item.info.id) then
        return true
    end

    local _, _, quality, _, _, _, _, _, _, _, _, classId = GetItemInfo(item.info.id)
    if quality >= EPIC and classId == MISC then
        return true
    end
    return false
end

local function GetExpireTime(bag, slot)
    local info = C.TooltipInfo.GetBagItem(bag, slot)
    if not info then
        return
    end

    for _, v in ipairs(info.lines) do
        if v.leftText then
            local s = v.leftText:match(BIND_TRADE_TIME_REMAINING_P)
            if s then
                local h = tonumber(strmatch(s, HOURS_P)) or 0
                local m = tonumber(strmatch(s, MINUTES_P)) or 0
                return h * 60 + m
            end
        end
    end
end

local function UpdateItemLevel(item)
    if not CanShowItemLevel(item) then
        return
    end

    local _, _, quality, itemLevel = GetItemInfo(item.info.id)
    if not itemLevel then
        return
    end

    item.Count:Show()
    item.Count:SetText(itemLevel)

    if profile.showItemLevelColor then
        local r, g, b = GetItemQualityColor(quality)
        item.Count:SetTextColor(r, g, b)
    else
        item.Count:SetTextColor(1, 1, 1)
    end
end

local function GetPrecColor(value)
    local r, g, b
    if value > 0.5 then
        r = (1.0 - value) * 2
        g = 1.0
    else
        r = 1.0
        g = value * 2
    end
    b = 0.0
    return r, g, b
end

local function UpdateItemInfo(item)
    item.Expire:Hide()

    if not CanShowInfo(item) then
        return
    end

    if profile.showBOE then
        local bindType = select(14, C.Item.GetItemInfo(item.info.id))
        if bindType == Enum.ItemBind.OnEquip then
            local info = C.Container.GetContainerItemInfo(item.bag, item.slot)
            if info and not info.isBound then
                item.Expire:SetText('BoE')
                item.Expire:SetTextColor(0, 1, 1)
                item.Expire:Show()
                return
            end
        end
    end

    if profile.showExpireTime then
        local expire = GetExpireTime(item.bag, item.slot)
        if not expire then
            return
        end

        item.Expire:SetText(format('%dm', expire))
        item.Expire:SetTextColor(GetPrecColor(expire / 120))
        item.Expire:Show()
    end
end

local function UpdateAll(item)
    UpdateItemLevel(item)
    UpdateItemInfo(item)
end

Addon:RegisterPlugin{
    key = PLUGIN,
    text = L['Item info'],
    type = 'Item',
    init = Constructor,
    update = UpdateAll,
    profile = {showExpireTime = true, showBOE = true, showItemLevelColor = true, showItemLevel = true},
    options = {
        type = 'group',
        name = 'ItemLevel',
        get = function(item)
            return profile[item[#item]]
        end,
        set = function(item, value)
            profile[item[#item]] = value
            Addon:UpdateAll()
        end,
        args = {
            showExpireTime = {type = 'toggle', width = 'full', name = L['Show Expire Time'], order = 1},
            showBOE = {type = 'toggle', width = 'full', name = L['Show BoE'], order = 2},
            showItemLevel = {type = 'toggle', width = 'full', name = L['Show Item Level'], order = 3},
            showItemLevelColor = {type = 'toggle', width = 'full', name = L['Item level color by quality'], order = 4},
        },
    },
}
