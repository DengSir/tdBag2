-- Item.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/17/2019, 12:05:58 AM

---- LUA
local _G = _G
local select = select

---- WOW
local BankButtonIDToInvSlotID = BankButtonIDToInvSlotID
local CreateFrame = CreateFrame
local CursorUpdate = CursorUpdate
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local IsBattlePayItem = IsBattlePayItem
local ResetCursor = ResetCursor

local C_NewItems = C_NewItems

local ContainerFrame_UpdateCooldown = ContainerFrame_UpdateCooldown
local ContainerFrameItemButton_OnEnter = ContainerFrameItemButton_OnEnter
local CooldownFrame_Set = CooldownFrame_Set
local SetItemButtonCount = SetItemButtonCount
local SetItemButtonDesaturated = SetItemButtonDesaturated
local SetItemButtonTexture = SetItemButtonTexture

---- UI
local StackSplitFrame = StackSplitFrame
local GameTooltip = GameTooltip

---- G
local ITEM_STARTS_QUEST = ITEM_STARTS_QUEST
local LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM
local LE_ITEM_QUALITY_COMMON = LE_ITEM_QUALITY_COMMON
local LE_ITEM_QUALITY_POOR = LE_ITEM_QUALITY_POOR
local NEW_ITEM_ATLAS_BY_QUALITY = NEW_ITEM_ATLAS_BY_QUALITY
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG

---@type ns
local ns = select(2, ...)
local Addon = ns.Addon
local Cache = ns.Cache
local Search = ns.Search
local Unfit = ns.Unfit

---@class ItemInfo
---@field cached boolean
---@field id number
---@field link string
---@field quality number

---@class tdBag2Item: Button
---@field private meta tdBag2FrameMeta
---@field private bag number
---@field private slot number
---@field private hasItem boolean
---@field private notMatched boolean
---@field private info ItemInfo
---@field private Overlay Frame
---@field private newitemglowAnim AnimationGroup
---@field private flashAnim AnimationGroup
local Item = ns.Addon:NewClass('UI.Item', 'Button.ContainerFrameItemButtonTemplate')
Item.pool = {}

local DEFAULT_SLOT_COLOR = {r = 1, g = 1, b = 1}

function Item:Constructor()
    self.Cooldown = _G[self:GetName() .. 'Cooldown']
    self.QuestBorder = _G[self:GetName() .. 'IconQuestTexture']

    self:SuperCall('UnregisterAllEvents')

    self.QuestBorder:SetTexture(TEXTURE_ITEM_QUEST_BANG)
    self.QuestBorder:ClearAllPoints()
    self.QuestBorder:SetPoint('BOTTOMLEFT', 5, 4)
    self.QuestBorder:SetSize(8.88, 25.46)
    self.QuestBorder:SetTexCoord(0.14, 0.38, 0.23, 0.9)
    self.QuestBorder:SetAlpha(0.9)

    self.IconBorder:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
    self.IconBorder:SetBlendMode('ADD')
    self.IconBorder:ClearAllPoints()
    self.IconBorder:SetPoint('CENTER')
    self.IconBorder:SetSize(67, 67)

    self.NewItemTexture:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
    self.NewItemTexture:SetBlendMode('ADD')
    self.NewItemTexture:ClearAllPoints()
    self.NewItemTexture:SetPoint('CENTER')
    self.NewItemTexture:SetSize(67, 67)

    self.BattlepayItemTexture:Hide()

    self.nt = self:GetNormalTexture()

    self.UpdateTooltip = self.OnEnter
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', self.OnLeave)
    self:SetScript('OnEvent', nil)
end

---@return tdBag2Item
function Item:Alloc()
    local object = next(self.pool)
    if not object then
        object = Item:New(UIParent)
    else
        self.pool[object] = nil
    end
    return object
end

function Item:Free()
    self.bag = nil
    self.slot = nil
    self:SetID(0)
    self:Hide()
    self.pool[self] = true
end

function Item:Init(parent, meta, bag, slot)
    self:SetParent(parent)
    self.meta = meta
    self.bag = bag
    self.slot = slot
    self:SetID(slot)
end

function Item:OnShow()
    self:Update()
end

function Item:OnHide()
    if self.hasStackSplit == 1 then
        StackSplitFrame:Hide()
    end

    if self:IsNew() then
        C_NewItems.RemoveNewItem(self.bag, self.slot)
    end
end

function Item:OnEnter()
    if self:IsCached() then
        local Overlay = self.Overlay or self:CreateOverlay()
        Overlay:SetParent(self)
        Overlay:SetAllPoints(true)
        Overlay:Show()
    elseif self.hasItem then
        if ns.IsBank(self.bag) then
            ns.AnchorTooltip(self)
            GameTooltip:SetInventoryItem('player', BankButtonIDToInvSlotID(self.slot))
            GameTooltip:Show()
            CursorUpdate(self)
        else
            ContainerFrameItemButton_OnEnter(self)
        end
        self:UpdateBorder()
    else
        self:OnLeave()
    end
end

function Item:OnLeave()
    GameTooltip:Hide()
    ResetCursor()
end

function Item:CreateOverlay()
    local Overlay = CreateFrame('Button')
    Overlay:RegisterForClicks('anyUp')

    local function OverlayOnEnter(self)
        ---@type tdBag2Item
        local parent = self:GetParent()
        local item = parent:IsCached() and parent.info.link
        if item then
            ns.AnchorTooltip(self)
            GameTooltip:SetHyperlink(item, parent.info.count)
            GameTooltip:Show()
        end
        parent:LockHighlight()
        CursorUpdate(parent)
    end

    local function OverlayOnLeave(self)
        self:GetParent():OnLeave()
        self:Hide()
    end

    local function OverlayOnHide(self)
        local parent = self:GetParent()
        if parent then
            parent:UnlockHighlight()
        end
    end

    local function OverlayOnClick(self, button)
        local parent = self:GetParent()
        local link = parent:IsCached() and parent.info.link
        HandleModifiedItemClick(link)
    end

    Overlay.UpdateTooltip = OverlayOnEnter
    Overlay:SetScript('OnShow', OverlayOnEnter)
    Overlay:SetScript('OnHide', OverlayOnHide)
    Overlay:SetScript('OnEnter', OverlayOnEnter)
    Overlay:SetScript('OnLeave', OverlayOnLeave)
    Overlay:SetScript('OnClick', OverlayOnClick)

    Item.Overlay = Overlay
    return Overlay
end

function Item:Update()
    self:UpdateInfo()
    self:UpdateItem()
    self:UpdateSearch()
    self:UpdateLocked()
    self:UpdateBorder()
    self:UpdateCooldown()
    self:UpdateFocus()
    self:UpdateSlotColor()
end

function Item:GetItem()
    return self.info.hasItem
end

function Item:UpdateInfo()
    self.info = Cache:GetItemInfo(self.meta.owner, self.bag, self.slot)
    self.hasItem = self.info.id
    self.readable = self.info.readable
end

function Item:UpdateItem()
    SetItemButtonTexture(self, self.info.icon or [[Interface\AddOns\tdBag2\Resource\UI-Backpack-EmptySlot]])
    SetItemButtonCount(self, self.info.count)
end

function Item:UpdateLocked()
    SetItemButtonDesaturated(self, self.hasItem and (self.info.locked or self.notMatched))
end

function Item:UpdateBorder()
    local sets = self.meta.sets
    local id = self.info.id
    local quality = self.info.quality
    local new = sets.glowNew and self:IsNew()
    local r, g, b

    if id then
        if sets.glowEquipSet and Search:InSet(self.info.link) then
            r, g, b = 0.1, 1, 1
        elseif sets.glowQuest and self:IsQuestItem() then
            r, g, b = 1, 0.82, 0.2
        elseif sets.glowUnusable and Unfit:IsItemUnusable(id) then
            r, g, b = 1, 0.1, 0.1
        elseif sets.glowQuality and quality and quality > LE_ITEM_QUALITY_COMMON then
            r, g, b = GetItemQualityColor(quality)
        end
    end

    if new then
        if not self.newitemglowAnim:IsPlaying() then
            self.newitemglowAnim:Play()
            self.flashAnim:Play()
        end

        local paid = self:IsPaid()

        self.BattlepayItemTexture:SetShown(paid)
        self.NewItemTexture:SetShown(not paid)
        self.NewItemTexture:SetVertexColor(r or 1, g or 1, b or 1)
    else
        if self.newitemglowAnim:IsPlaying() or self.flashAnim:IsPlaying() then
            self.flashAnim:Stop()
            self.newitemglowAnim:Stop()
        end

        self.BattlepayItemTexture:Hide()
        self.NewItemTexture:Hide()
    end

    self.IconBorder:SetVertexColor(r, g, b, sets.glowAlpha)
    self.IconBorder:SetShown(r and not new)
    self.QuestBorder:SetShown(sets.iconQuestStarter and self:IsQuestStarter())
    self.JunkIcon:SetShown(sets.iconJunk and self:IsJunk())
end

function Item:UpdateSlotColor()
    local color = DEFAULT_SLOT_COLOR
    local alpha = self.hasItem and 1 or self.meta.sets.emptyAlpha

    if self.meta.sets.colorSlots and not self.hasItem then
        local family = self:GetBagFamily()
        local name = ns.BAG_FAMILY[family]
        if name then
            color = self.meta.sets['color' .. name]
        else
            color = self.meta.sets.colorNormal
        end
    end

    self.nt:SetVertexColor(color.r, color.g, color.b, alpha)
    self.icon:SetVertexColor(color.r, color.g, color.b, alpha)
end

function Item:UpdateCooldown()
    if self.hasItem and not self:IsCached() then
        ContainerFrame_UpdateCooldown(self.bag, self)
    else
        self.Cooldown:Hide()
        CooldownFrame_Set(self.Cooldown, 0, 0, 0)
    end
end

function Item:UpdateFocus()
    if Addon:IsBagFocused(self.bag) then
        self:LockHighlight()
    else
        self:UnlockHighlight()
    end
end

function Item:UpdateSearch()
    local isNew = self.newitemglowAnim:IsPlaying()
    if isNew then
        self.newitemglowAnim:Stop()
        self.flashAnim:Stop()
    end

    self.notMatched = not self:IsMatched() or nil
    self:SetAlpha(self.notMatched and 0.3 or 1)

    if isNew then
        self.newitemglowAnim:Play()
    end
end

function Item:GetBagFamily()
    if ns.IsBank(self.bag) or ns.IsBackpack(self.bag) then
        return 0
    end
    if ns.IsKeyring(self.bag) then
        return 9
    end
    local info = Cache:GetBagInfo(self.meta.owner, self.bag)
    return info.link and GetItemFamily(info.link) or 0
end

function Item:IsCached()
    return self.info and self.info.cached
end

function Item:IsNew()
    return self.bag and not self:IsCached() and C_NewItems.IsNewItem(self.bag, self.slot)
end

function Item:IsPaid()
    return IsBattlePayItem(self.bag, self.slot)
end

function Item:IsQuestItem()
    return self.hasItem and
               (select(12, GetItemInfo(self.info.id)) == LE_ITEM_CLASS_QUESTITEM or Search:ForQuest(self.info.link))
end

function Item:IsQuestStarter()
    return self.hasItem and Search:TooltipPhrase(self.info.link, ITEM_STARTS_QUEST)
end

function Item:IsMatched()
    local search = Addon:GetSearch()
    if not search then
        return true
    end
    return Search:Matches(self.info.link, search)
end

function Item:IsJunk()
    if not self.hasItem then
        return
    end
    if Scrap then
        return Scrap:IsJunk(self.info.id)
    else
        local _, _, quality, _, _, _, _, _, _, _, price = GetItemInfo(self.info.id)
        return quality == LE_ITEM_QUALITY_POOR and price and price > 0
    end
end

do
    for c = 1, NUM_CONTAINER_FRAMES do
        for i = 1, MAX_CONTAINER_ITEMS do
            local item = _G[format('ContainerFrame%dItem%d', c, i)]
            if item then
                item:SetID(0)
                item:ClearAllPoints()
                item:Hide()
                item:UnregisterAllEvents()

                Item:Bind(item, UIParent)
                Item.pool[item] = true
            end
        end
    end
end
