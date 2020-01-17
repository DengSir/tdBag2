-- Tooltip.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/24/2019, 1:03:40 PM

---- LUA
local ipairs, select = ipairs, select
local tinsert, tconcat = table.insert, table.concat
local format = string.format
local tonumber = tonumber

---- WOW
local GetItemCount = GetItemCount

---- G
local HEARTHSTONE_ITEM_ID = HEARTHSTONE_ITEM_ID
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

---@type ns
local ns = select(2, ...)
local L = ns.L
local Cache = ns.Cache
local Counter = ns.Counter

---@class tdBag2Tooltip
local Tooltip = ns.Addon:NewModule('Tooltip', 'AceHook-3.0')
Tooltip:Disable()
Tooltip.APIS = {
    'SetMerchantItem', 'SetBuybackItem', 'SetBagItem', 'SetAuctionItem', 'SetAuctionSellItem', 'SetLootItem',
    'SetLootRollItem', 'SetInventoryItem', 'SetTradePlayerItem', 'SetTradeTargetItem', 'SetQuestItem',
    'SetQuestLogItem', 'SetInboxItem', 'SetSendMailItem', 'SetHyperlink', 'SetCraftItem', 'SetTradeSkillItem',
    'SetAction', 'SetItemByID',
}
Tooltip.EMPTY = {}
Tooltip.CACHED_EMPTY = {cached = true}

Tooltip.SPACES = {
    {key = 'equip', label = L['Equipped']}, --
    {key = 'bags', label = L['Inventory']}, --
    {key = 'banks', label = L['Bank']}, --
    {key = 'mails', label = L['Mail']}, --
}

function Tooltip:OnInitialize()
    self.Cacher = ns.Cacher:New()
    self.Cacher:Patch(self, 'GetOwnerItemInfo', true)
    self.GetOwnerItemInfo.Cachable = function(info)
        return info.cached
    end
    self:Update()
end

function Tooltip:Update()
    if ns.Addon.db.profile.tipCount then
        self:Enable()
    else
        self:Disable()
    end
end
Tooltip.Update = ns.Spawned(Tooltip.Update)

function Tooltip:OnEnable()
    self:HookTip(GameTooltip)
    self:HookTip(ItemRefTooltip)
end

function Tooltip:HookTip(tip)
    for _, api in ipairs(self.APIS) do
        self:SecureHook(tip, api, 'OnTooltipItem')
    end

    for _, shoppingTip in ipairs(tip.shoppingTooltips) do
        self:SecureHook(shoppingTip, 'SetCompareItem', 'OnCompareItem')
    end
end

function Tooltip:OnCompareItem(tip1, tip2)
    self:OnTooltipItem(tip1)
    self:OnTooltipItem(tip2)
end

function Tooltip:OnTooltipItem(tip)
    local _, item = tip:GetItem()
    if not item then
        return
    end
    local itemId = tonumber(item and item:match('item:(%d+)'))
    if itemId and itemId ~= HEARTHSTONE_ITEM_ID then
        self:AddOwners(tip, itemId)
        tip:Show()
    end
end

function Tooltip:AddOwners(tip, item)
    local owners, total = 0, 0
    for _, owner in ipairs(Cache:GetOwners()) do
        local info = self:GetOwnerItemInfo(owner, item)
        if info and info.total then
            local r, g, b = info.color.r, info.color.g, info.color.b
            tip:AddDoubleLine(info.name, info.text, r, g, b, r, g, b)
            owners = owners + 1
            total = total + info.total
        end
    end

    if owners > 1 then
        tip:AddDoubleLine(L['Total'], total, 0.66, 0.66, 0.66, 0.66, 0.66, 0.66)
    end
end

function Tooltip:GetCounts(counts)
    local places = 0
    local total = 0
    local sb = {}
    for i, v in ipairs(self.SPACES) do
        local count = counts[v.key]
        local label = v.label

        if count and count > 0 then
            places = places + 1
            total = total + count

            tinsert(sb, format('%s:%d', label, count))
        end
    end

    local text = tconcat(sb, ' ')

    if places > 1 then
        return total, format('%d |cffaaaaaa(%s)|r', total, text)
    elseif places == 1 then
        return total, text
    end
end

function Tooltip:GetOwnerItemInfo(owner, itemId)
    local info = Cache:GetOwnerInfo(owner)
    local total, text = self:GetCounts(Counter:GetOwnerItemCount(owner, itemId))
    local item
    if total then
        item = { --
            name = info.name,
            text = text,
            total = total,
            color = RAID_CLASS_COLORS[info.class or 'PRIEST'],
            cached = info.cached,
        }
    elseif info.cached then
        item = self.CACHED_EMPTY
    else
        item = self.EMPTY
    end
    return item
end
