-- TitleContainer.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/3/2020, 8:10:05 PM

local pairs, ipairs = pairs, ipairs
local max = math.max
local tinsert = table.insert

---@type ns
local ns = select(2, ...)

local L = ns.L

local Container = ns.UI.Container
local Updaters = Container.Updaters

local BAG_TITLES = { --
    [ns.MAIL_CONTAINER] = L['Mail'],
    [ns.COD_CONTAINER] = L['COD'],
}

---@class tdBag2TitleContainer: tdBag2Container
local TitleContainer = ns.Addon:NewClass('UI.TitleContainer', ns.UI.Container)

function TitleContainer:Constructor()
    self.titleLabels = {}
    self.numSlots = {}
end

function TitleContainer:GetTitleLabel(bag)
    if not self.titleLabels[bag] then
        local frame = CreateFrame('Frame', nil, self, 'tdBag2ContainerTitleTemplate')
        frame:SetHeight(20)
        frame.Text:SetText(BAG_TITLES[bag])
        self.titleLabels[bag] = frame
    end
    return self.titleLabels[bag]
end

function TitleContainer:Layout()
    self:ForAll(Updaters.Free, true)

    local profile = self.meta.profile
    local column = profile.column
    local scale = profile.scale
    local reverseSlot = profile.reverseSlot

    local x, y = 0, 0
    local size = ns.ITEM_SIZE + ns.ITEM_SPACING
    local isMail = self.meta.bagId == ns.BAG_ID.MAIL

    for _, label in pairs(self.titleLabels) do
        label:Hide()
    end

    local bags = self:GetBags()
    local multi = #bags > 1
    local addHeight = multi and -5 or 0

    for _, bag in ipairs(bags) do
        local numSlots = self:NumSlots(bag)
        local slotBegin, slotEnd, slotStep
        if not reverseSlot then
            slotBegin, slotEnd, slotStep = 1, numSlots, 1
        else
            slotBegin, slotEnd, slotStep = numSlots, 1, -1
        end

        if multi then
            local label = self:GetTitleLabel(bag)
            label:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, -y * size - addHeight)
            label:SetWidth(column * size - ns.ITEM_SPACING)
            label:SetScale(scale)
            label:Show()
            addHeight = addHeight + 20
        end

        for slot = slotBegin, slotEnd, slotStep do
            local itemButton = self:GetItemButton(bag, slot)
            if x == column then
                y = y + 1
                x = 0
            end

            itemButton:ClearAllPoints()
            itemButton:SetPoint('TOPLEFT', self, 'TOPLEFT', x * size, -y * size - addHeight)
            itemButton:SetScale(scale)
            itemButton:Show()

            x = x + 1
        end

        if isMail and x > 0 then
            y = y + 1
            x = 0
        end
    end

    if x > 0 then
        y = y + 1
    end

    local width = max(1, column * size * scale)
    local height = max(1, (y * size + addHeight) * scale)
    self:SetSize(width, height)
    self:SetScript('OnUpdate', nil)
    self:Fire('OnLayout')
end

function TitleContainer:GetBags()
    local bags = {}
    for _, bag in self:IterateBags() do
        local numSlots = Container.NumSlots(self, bag)
        if numSlots > 0 then
            tinsert(bags, bag)
            self.numSlots[bag] = numSlots
        end
    end
    return bags
end

function TitleContainer:NumSlots(bag)
    return self.numSlots[bag]
end
