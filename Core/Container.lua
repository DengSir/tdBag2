-- Container.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/17/2019, 10:17:19 AM

---- LUA
local ipairs, pairs = ipairs, pairs
local max = math.max
local select = select
local tinsert, tremove = table.insert, table.remove

---- WOW
local CreateFrame = CreateFrame
local CopyTable = CopyTable
local GetItemFamily = GetItemFamily

---@type ns
local ns = select(2, ...)
local ripairs = ns.ripairs
local Addon = ns.Addon
local Cache = ns.Cache
local TRADE_BAG_ORDER = ns.TRADE_BAG_ORDER

local KEYRING_CONTAINER = KEYRING_CONTAINER

---@class tdBag2Container: Frame
---@field private meta tdBag2FrameMeta
---@field private itemButtons table<number, table<number, tdBag2Item>>
---@field private bagSizes table<number, number>
---@field private bagOrdered number[]
local Container = ns.Addon:NewClass('UI.Container', 'Frame')

function Container:Constructor(_, meta)
    self.meta = meta
    self.bagFrames = {}
    self.itemButtons = {}

    for _, bag in ipairs(self.meta.bags) do
        self.itemButtons[bag] = {}
    end

    self:SetSize(1, 1)

    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)
end

function Container:OnShow()
    if not self.meta:IsCached() then
        self:RegisterEvent('BAG_SIZE_CHANGED')
        self:RegisterEvent('BAG_UPDATE')
        self:RegisterEvent('BAG_CLOSED')
        self:RegisterEvent('ITEM_LOCK_CHANGED')
        self:RegisterEvent('BAG_UPDATE_COOLDOWN')
        self:RegisterEvent('BAG_NEW_ITEMS_UPDATED')
        self:RegisterEvent('BANK_CLOSED', 'OnShow')
    else
        self:UnregisterAllEvents()
    end
    self:RegisterEvent('BAG_FOCUS_UPDATED')
    self:RegisterEvent('SEARCH_CHANGED')
    self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
    self:RegisterEvent('UPDATE_ALL')
    self:RegisterFrameEvent('FRAME_OWNER_CHANGED')
    self:RequestLayout()
end

function Container:OnHide()
    self:UnregisterAllEvents()
    self.lastFocusBag = nil
end

function Container:BAG_SIZE_CHANGED(_, bag)
    if self:HasBag(bag) then
        self:RequestLayout()
    end
end

local Updaters = {
    Update = ns.UI.Item.Update,
    UpdateFocus = ns.UI.Item.UpdateFocus,
    UpdateCooldown = ns.UI.Item.UpdateCooldown,
    UpdateBorder = ns.UI.Item.UpdateBorder,
    UpdateLocked = function(item)
        item:UpdateInfo()
        item:UpdateLocked()
    end,
    UpdateSearch = function(item)
        item:UpdateSearch()
        item:UpdateLocked()
    end,

    Free = function(item, container)
        container.itemButtons[item.bag][item.slot] = nil
        item:Free()
    end,
}

function Container:BAG_FOCUS_UPDATED(_, bag)
    self:ForBag(self.lastFocusBag, Updaters.UpdateFocus)
    self:ForBag(bag, Updaters.UpdateFocus)
    self.lastFocusBag = bag
end

function Container:FRAME_OWNER_CHANGED()
    self.bagOrdered = nil
    self:Update()
end

function Container:BAG_UPDATE(_, bag)
    self:ForBag(bag, Updaters.Update)
end

function Container:BAG_CLOSED()
    self.bagOrdered = nil
    self:RequestLayout()
end

function Container:ITEM_LOCK_CHANGED(_, bag, slot)
    return self:ForSlot(bag, slot, Updaters.UpdateLocked)
end

function Container:BAG_UPDATE_COOLDOWN()
    return self:ForAll(Updaters.UpdateCooldown)
end

function Container:BAG_NEW_ITEMS_UPDATED(...)
    return self:ForAll(Updaters.UpdateBorder)
end

function Container:SEARCH_CHANGED()
    return self:ForAll(Updaters.UpdateSearch)
end

function Container:GET_ITEM_INFO_RECEIVED(_, itemId)
    return self:ForItem(itemId, Updaters.Update)
end

function Container:UPDATE_ALL()
    self.bagOrdered = nil
    self:OnShow()
end

function Container:Update()
    self:OnShow()
end

function Container:ForAll(method, force)
    if not force and self:IsPendingLayout() then
        return
    end
    for bag, buttons in pairs(self.itemButtons) do
        for slot, itemButton in pairs(buttons) do
            if itemButton:IsShown() then
                method(itemButton, self)
            end
        end
    end
end

function Container:ForBag(bag, method)
    if not self:HasBag(bag) or self:IsPendingLayout() then
        return
    end
    for _, itemButton in pairs(self.itemButtons[bag]) do
        if itemButton:IsShown() then
            method(itemButton, self)
        end
    end
end

function Container:ForSlot(bag, slot, method)
    if not self:HasBag(bag) or self:IsPendingLayout() then
        return
    end
    local itemButton = self.itemButtons[bag][slot]
    if itemButton and itemButton:IsShown() then
        method(itemButton, self)
    end
end

function Container:ForItem(itemId, method)
    if self:IsPendingLayout() then
        return
    end
    for bag, buttons in pairs(self.itemButtons) do
        for slot, itemButton in pairs(buttons) do
            if itemButton:IsShown() and itemButton.info.id == itemId then
                method(itemButton, self)
            end
        end
    end
end

function Container:HasBag(bag)
    return bag and self.meta:HasBag(bag)
end

function Container:GetBagFrame(bag)
    return self.bagFrames[bag] or self:CreateBagFrame(bag)
end

function Container:CreateBagFrame(bag)
    local frame = CreateFrame('Frame', nil, self)
    frame:SetID(bag)
    self.bagFrames[bag] = frame
    return frame
end

function Container:CreateItemButton(bag, slot)
    local itemButton = ns.UI.Item:Alloc()
    itemButton:Init(self:GetBagFrame(bag), self.meta, bag, slot)
    self.itemButtons[bag][slot] = itemButton
    return itemButton
end

function Container:GetItemButton(bag, slot)
    return self.itemButtons[bag][slot] or self:CreateItemButton(bag, slot)
end

function Container:RequestLayout()
    self:SetScript('OnUpdate', self.Layout)
end

function Container:IsPendingLayout()
    return self:GetScript('OnUpdate')
end

function Container:BuildOrderedBags()
    local hasKeyring = false
    local tradeBags = {}
    local normalBags = {}
    local reverseBag = self.meta.profile.reverseBag
    local atBottom = self.meta.profile.tradeBagOrder == TRADE_BAG_ORDER.BOTTOM

    for i, bag in ipairs(self.meta.bags) do
        if bag == KEYRING_CONTAINER then
            hasKeyring = true
        else
            local info = Cache:GetBagInfo(self.meta.owner, bag)
            if info.owned and info.family ~= 0 then
                tinsert(tradeBags, bag)
            else
                tinsert(normalBags, bag)
            end
        end
    end

    if atBottom == reverseBag then
        for _, bag in ripairs(tradeBags) do
            tinsert(normalBags, 1, bag)
        end

        if hasKeyring then
            tinsert(normalBags, 1, KEYRING_CONTAINER)
        end
    else
        for _, bag in ipairs(tradeBags) do
            tinsert(normalBags, bag)
        end

        if hasKeyring then
            tinsert(normalBags, KEYRING_CONTAINER)
        end
    end

    self.bagOrdered = normalBags
    return self.bagOrdered
end

function Container:IterateBags()
    local bags
    if self.meta.profile.tradeBagOrder ~= TRADE_BAG_ORDER.NONE then
        bags = self.bagOrdered or self:BuildOrderedBags()
    else
        bags = self.meta.bags
    end

    local iterate = self.meta.profile.reverseBag and ripairs or ipairs
    return iterate(bags)
end

function Container:Layout()
    self:ForAll(Updaters.Free, true)

    local profile = self.meta.profile
    local column = profile.column
    local scale = profile.scale
    local reverseSlot = profile.reverseSlot

    local x, y = 0, 0
    local size = ns.ITEM_SIZE + ns.ITEM_SPACING

    for _, bag in self:IterateBags() do
        if not self.meta:IsBagHidden(bag) then
            local slotBegin, slotEnd, slotStep
            if not reverseSlot then
                slotBegin, slotEnd, slotStep = 1, self:NumSlots(bag), 1
            else
                slotBegin, slotEnd, slotStep = self:NumSlots(bag), 1, -1
            end

            for slot = slotBegin, slotEnd, slotStep do
                local itemButton = self:GetItemButton(bag, slot)
                if x == column then
                    y = y + 1
                    x = 0
                end

                itemButton:ClearAllPoints()
                itemButton:SetPoint('TOPLEFT', self, 'TOPLEFT', x * size, -y * size)
                itemButton:SetScale(scale)
                itemButton:Show()

                x = x + 1
            end
        end
    end

    if x > 0 then
        y = y + 1
    end

    local width = max(1, column * size * scale)
    local height = max(1, y * size * scale)
    self:SetSize(width, height)
    self:SetScript('OnUpdate', nil)
    self:Fire('OnLayout')
end

function Container:NumSlots(bag)
    if bag == KEYRING_CONTAINER and self.meta:IsCached() then
        local realm, name = ns.Cache:GetOwnerAddress(self.meta.owner)
        return ns.Addon.db.global.quickfix.keyrings[name .. '-' .. realm] or 0
    end
    return Cache:GetBagInfo(self.meta.owner, bag).count or 0
end
