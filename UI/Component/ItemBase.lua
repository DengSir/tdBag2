-- ItemBase.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/10/2020, 12:02:10 AM
--
---- LUA
local _G = _G
local select = select
local next = next
local time = time
local floor = math.floor
local format = string.format
local securecall = securecall

---- WOW
local BankButtonIDToInvSlotID = BankButtonIDToInvSlotID
local CreateFrame = CreateFrame
local CursorUpdate = CursorUpdate
local GetItemInfo = GetItemInfo
local GetItemFamily = GetItemFamily
local GetItemQualityColor = GetItemQualityColor
local IsBattlePayItem = IsBattlePayItem
local ResetCursor = ResetCursor

local IsNewItem = C_NewItems.IsNewItem
local RemoveNewItem = C_NewItems.RemoveNewItem

local ContainerFrame_UpdateCooldown = ContainerFrame_UpdateCooldown
local ContainerFrameItemButton_OnEnter = ContainerFrameItemButton_OnEnter
local CooldownFrame_Set = CooldownFrame_Set
local SetItemButtonCount = SetItemButtonCount
local SetItemButtonDesaturated = SetItemButtonDesaturated
local SetItemButtonTexture = SetItemButtonTexture

---- UI
local StackSplitFrame = StackSplitFrame
local GameTooltip = GameTooltip
local UIParent = UIParent

---- G
local ITEM_STARTS_QUEST = ITEM_STARTS_QUEST
local LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM
local LE_ITEM_QUALITY_COMMON = Enum.ItemQuality.Common or Enum.ItemQuality.Standard or LE_ITEM_QUALITY_COMMON
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG

---@type ns
local ns = select(2, ...)
local Addon = ns.Addon
local Cache = ns.Cache
local Search = ns.Search
local Unfit = ns.Unfit
local LibJunk = LibStub('LibJunk-1.0')

local EXPIRED = GRAY_FONT_COLOR:WrapTextInColorCode(ns.L['Expired'])
local MINUTE, HOUR, DAY = 60, 3600, ns.SECONDS_OF_DAY
local KEYRING_FAMILY = ns.KEYRING_FAMILY

---@type tdBag2ItemBase
local ItemBase = ns.Addon:NewClass('UI.ItemBase', ns.IS_CLASSIC and 'Button' or 'ItemButton')
ItemBase.pool = {}
ItemBase.GenerateName = ns.NameGenerator('tdBag2ItemBase')

function ItemBase:Constructor()
    self:Hide()

    local name = self:GetName()
    self.QuestBorder = _G[name .. 'IconQuestTexture']
    self.Timeout = _G[name .. 'Stock']

    self.QuestBorder:SetTexture(TEXTURE_ITEM_QUEST_BANG)
    self.QuestBorder:ClearAllPoints()
    self.QuestBorder:SetPoint('BOTTOMLEFT', 5, 4)
    self.QuestBorder:SetSize(8.88, 25.46)
    self.QuestBorder:SetTexCoord(0.14, 0.38, 0.23, 0.9)
    self.QuestBorder:SetAlpha(0.9)
    self.QuestBorder:SetDrawLayer('ARTWORK', 2)

    self.IconBorder:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
    self.IconBorder:SetBlendMode('ADD')
    self.IconBorder:ClearAllPoints()
    self.IconBorder:SetPoint('CENTER')
    self.IconBorder:SetSize(67, 67)

    self.nt = self:GetNormalTexture()

    if not self.JunkIcon then
        self.JunkIcon = self.searchOverlay
        self.JunkIcon:ClearAllPoints()
        self.JunkIcon:SetAtlas('bags-junkcoin', true)
        self.JunkIcon:SetPoint('TOPLEFT', 1, 0)
        self.JunkIcon:SetDrawLayer('ARTWORK', 1)
    end

    self.UpdateTooltip = self.OnEnter
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', self.OnLeave)
    self:SetScript('OnEvent', nil)

    for _, opts in Addon:IterateItemPlugins() do
        if opts.init then
            securecall(opts.init, self)
        end
    end
end

function ItemBase:Alloc()
    local obj = next(self.pool)
    if not obj then
        obj = self:Create()
    else
        self.pool[obj] = nil
    end
    return obj
end

function ItemBase:Create()
    return ItemBase:Bind(CreateFrame('Button', ItemBase:GenerateName(), UIParent, 'ItemButtonTemplate'))
end

function ItemBase:Free()
    self.bag = nil
    self.slot = nil
    self:SetID(0)
    self:Hide()
    self.pool[self] = true
end

function ItemBase:SetBagSlot(parent, meta, bag, slot)
    self:SetParent(parent)
    self.meta = meta
    self.bag = bag
    self.slot = slot
    self:SetID(slot)
end

function ItemBase:OnShow()
    self:Update()
end

function ItemBase:OnEnter()
    if self:IsCached() then
        local Overlay = self.Overlay or self:CreateOverlay()
        Overlay:Hide()
        Overlay:SetParent(self)
        Overlay:SetAllPoints(true)
        Overlay:Show()
    elseif self.hasItem then
        if ns.IsBank(self.bag) then
            ns.AnchorTooltip(self)
            GameTooltip:SetInventoryItem('player', BankButtonIDToInvSlotID(self.slot))
            GameTooltip:Show()
            CursorUpdate(self)
        elseif ns.IsEquip(self.bag) then
            ns.AnchorTooltip(self)
            GameTooltip:SetInventoryItem('player', self.slot)
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

function ItemBase:OnLeave()
    GameTooltip_Hide()
    ResetCursor()
end

function ItemBase:CreateOverlay()
    local Overlay = CreateFrame('Button')
    Overlay:RegisterForClicks('anyUp')
    Overlay:Hide()

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

    ItemBase.Overlay = Overlay
    return Overlay
end

function ItemBase:Update()
    self:UpdateInfo()
    self:UpdateItem()
    self:UpdateSearch()
    self:UpdateLocked()
    self:UpdateBorder()
    self:UpdateFocus()
    self:UpdateRemain()
    self:UpdatePlugin()
end

function ItemBase:GetItem()
    return self.info.hasItem
end

function ItemBase:UpdateInfo()
    self.info = Cache:GetItemInfo(self.meta.owner, self.bag, self.slot)
    self.hasItem = self.info.id
    self.readable = self.info.readable
end

function ItemBase:UpdateItem()
    SetItemButtonTexture(self, self.info.icon or self.EMPTY_SLOT_TEXTURE or
                             [[Interface\AddOns\tdBag2\Resource\UI-Backpack-EmptySlot]])
    SetItemButtonCount(self, self.info.count)
end

function ItemBase:UpdateLocked()
    SetItemButtonDesaturated(self, self.hasItem and (self.info.locked or self.notMatched))
end

function ItemBase:UpdateSpecialBorder()
    self.IconOverlay:SetVertexColor(1, 1, 1)
    self.IconOverlay:Hide()

    if self.IconOverlay2 then
        self.IconOverlay2:Hide()
    end

    if self.hasItem then
        if IsArtifactRelicItem and IsArtifactRelicItem(self.info.id) then
            local r, g, b = self:GetBorderColor()
            self.IconOverlay:SetTexture([[Interface\AddOns\tdBag2\Resource\RelicIconFrame]])
            self.IconOverlay:Show()
            self.IconOverlay:SetVertexColor(r, g, b, 1 - (1 - self.meta.sets.glowAlpha) / 2)
        elseif C_AzeriteEmpoweredItem and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(self.info.id) then
            self.IconOverlay:SetAtlas('AzeriteIconFrame')
            self.IconOverlay:Show()
        elseif IsCorruptedItem and IsCorruptedItem(self.info.id) then
            self.IconOverlay:SetAtlas('Nzoth-inventory-icon')
            self.IconOverlay:Show()
        elseif not self:IsCached() and not self.info.bound and IsCosmeticItem and IsCosmeticItem(self.info.id) then
            self.IconOverlay:SetAtlas('CosmeticIconFrame')
            self.IconOverlay:Show()
        elseif C_Soulbinds and C_Soulbinds.IsItemConduitByItemInfo(self.info.id) then
            local color = BAG_ITEM_QUALITY_COLORS[self.info.quality]
            self.IconOverlay:SetVertexColor(color.r, color.g, color.b)
            self.IconOverlay:SetAtlas('ConduitIconFrame')
            self.IconOverlay:Show()
            self.IconOverlay2:SetAtlas('ConduitIconFrame-Corners')
            self.IconOverlay2:Show()
        end
    end
end

-- if ns.IS_CLASSIC then
function ItemBase:UpdateBorder()
    local sets = self.meta.sets

    if not self:UpdateSpecialBorder() then
        local r, g, b = self:GetBorderColor()
        self.IconBorder:SetVertexColor(r, g, b, sets.glowAlpha)
        self.IconBorder:SetShown(r)
    else
        self.IconBorder:Hide()
    end

    self.QuestBorder:SetShown(sets.iconQuestStarter and self:IsQuestStarter())
    self.JunkIcon:SetShown(sets.iconJunk and self:IsJunk())

    if ContainerFrameItemButton_UpdateItemUpgradeIcon then
        ContainerFrameItemButton_UpdateItemUpgradeIcon(self)
    end
end
-- else
--     function ItemBase:UpdateBorder()
--         local sets = self.meta.sets
--         SetItemButtonQuality(self, self.info.quality, self.info.id)
--         self.QuestBorder:SetShown(sets.iconQuestStarter and self:IsQuestStarter())
--     end
-- end

function ItemBase:UpdateFocus()
    if Addon:IsBagFocused(self.bag) then
        self:LockHighlight()
    else
        self:UnlockHighlight()
    end
end

function ItemBase:UpdateSearch()
    self.notMatched = not self:IsMatched() or nil
    self:SetAlpha(self.notMatched and 0.3 or 1)
end

function ItemBase:UpdateRemain()
    if not self.info.timeout then
        self.Timeout:Hide()
        return
    end
    local remainLimit = self.meta.sets.remainLimit
    if not remainLimit or remainLimit < 0 then
        self.Timeout:Hide()
        return
    end

    local remain = self.info.timeout - time()
    local days = floor(remain / DAY)

    if remainLimit > 0 and days > remainLimit then
        self.Timeout:Hide()
        return
    end

    local text
    if remain < 0 then
        text = EXPIRED
    elseif remain < MINUTE then
        text = format('|cffff2020%ds|r', remain)
    elseif remain < HOUR then
        text = format('|cffff2020%dm|r', remain / MINUTE)
    elseif remain < DAY then
        text = format('|cffff2020%dh|r', remain / HOUR)
    elseif days <= 5 then
        text = format('|cffff2020%dd|r', days)
    else
        text = format('|cff20ff20%dd|r', days)
    end

    self.Timeout:SetText(text)
    self.Timeout:Show()
end

function ItemBase:UpdatePlugin()
    if not Addon:HasAnyItemPlugin() then
        return
    end

    C_Timer.After(0.01, function()
        return self:OnUpdatePlugin()
    end)
end

function ItemBase:OnUpdatePlugin()
    if not self:IsVisible() then
        return
    end
    for i, opts in Addon:IterateItemPlugins() do
        securecall(opts.update, self)
    end
end

function ItemBase:GetBagFamily()
    if ns.IsBank(self.bag) or ns.IsBackpack(self.bag) then
        return 0
    end
    if ns.IsKeyring(self.bag) then
        return KEYRING_FAMILY
    end
    local info = Cache:GetBagInfo(self.meta.owner, self.bag)
    return info.link and GetItemFamily(info.link) or 0
end

function ItemBase:GetBorderColor()
    local sets = self.meta.sets
    local quality = self.info.quality
    if self.info.id then
        if sets.glowEquipSet and self:IsInEquipSet() then
            return 0.1, 1, 1
        elseif sets.glowQuest and self:IsQuestItem() then
            return 1, 0.82, 0.2
        elseif sets.glowUnusable and self:IsUnusable() then
            return 1, 0.1, 0.1
        elseif sets.glowQuality and quality and quality > LE_ITEM_QUALITY_COMMON then
            local color = BAG_ITEM_QUALITY_COLORS[quality]
            return color.r, color.g, color.b
        end
    end
end

function ItemBase:IsCached()
    return self.info and self.info.cached
end

function ItemBase:IsQuestItem()
    return self.hasItem and
               (select(12, GetItemInfo(self.info.id)) == LE_ITEM_CLASS_QUESTITEM or Search:ForQuest(self.info.link))
end

if ns.IS_CLASSIC then
    function ItemBase:IsQuestStarter()
        return self.hasItem and Search:TooltipPhrase(self.info.link, ITEM_STARTS_QUEST)
    end
else
    function ItemBase:IsQuestStarter()
        if not self.hasItem or self:IsCached() then
            return false
        end
        local isQuestItem, questId, isActive = GetContainerItemQuestInfo(self.bag, self.slot)
        return questId and not isActive
    end
end

function ItemBase:IsMatched()
    if self.meta:IsGlobalSearch() then
        return true
    end
    local search = Addon:GetSearch()
    if not search then
        return true
    end
    return Search:Matches(self.info.link, search)
end

function ItemBase:IsJunk()
    if not self.hasItem then
        return
    end
    return LibJunk:IsJunk(self.info.id)
end

function ItemBase:IsInEquipSet()
    return Search:InSet(self.info.link)
end

function ItemBase:IsUnusable()
    return Unfit:IsItemUnusable(self.info.id)
end
