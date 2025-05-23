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

local C = LibStub('C_Everywhere')

---- WOW
local BankButtonIDToInvSlotID = BankButtonIDToInvSlotID
local CreateFrame = CreateFrame
local CursorUpdate = CursorUpdate
local ResetCursor = ResetCursor

local ContainerFrameItemButton_OnEnter = ContainerFrameItemButton_OnEnter
local SetItemButtonCount = SetItemButtonCount
local SetItemButtonDesaturated = SetItemButtonDesaturated
local SetItemButtonTexture = SetItemButtonTexture

---- UI
local GameTooltip = GameTooltip
local UIParent = UIParent

---- G
local LE_ITEM_CLASS_QUESTITEM = Enum.ItemClass.Questitem
local LE_ITEM_QUALITY_COMMON = LE_ITEM_QUALITY_COMMON
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GRAY_FONT_COLOR = GRAY_FONT_COLOR

---@type ns
local ns = select(2, ...)
local Addon = ns.Addon
local Cache = ns.Cache
local Search = ns.Search
local LibJunk = LibStub('LibJunk-1.0')

local EXPIRED = GRAY_FONT_COLOR:WrapTextInColorCode(ns.L['Expired'])
local MINUTE, HOUR, DAY = 60, 3600, ns.SECONDS_OF_DAY
local KEYRING_FAMILY = ns.KEYRING_FAMILY

---@class UI.ItemBase: EventsMixin, Object, Button
---@field meta FrameMeta
---@field EMPTY_SLOT_TEXTURE string
local ItemBase = ns.Addon:NewClass('UI.ItemBase', ns.ITEM_BUTTON_CLASS)
ItemBase.pool = {}
ItemBase.pluginPendings = {}
ItemBase.GenerateName = ns.NameGenerator('tdBag2ItemBase')

function ItemBase:Constructor()
    self:Hide()

    local name = self:GetName()
    self.QuestBorder = _G[name .. 'IconQuestTexture'] or self.IconOverlay
    ---@type FontString
    self.Timeout = _G[name .. 'Stock']

    self.QuestBorder:SetTexture(TEXTURE_ITEM_QUEST_BANG)
    self.QuestBorder:ClearAllPoints()
    self.QuestBorder:SetPoint('BOTTOMLEFT', 5, 4)
    self.QuestBorder:SetSize(8.88, 25.46)
    self.QuestBorder:SetTexCoord(0.14, 0.38, 0.23, 0.9)
    self.QuestBorder:SetAlpha(0.9)
    self.QuestBorder:SetDrawLayer('ARTWORK', 2)

    if ns.Addon.borderStyle == 'Default' then
        self.IconBorder:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
        self.IconBorder:SetBlendMode('ADD')
        self.IconBorder:ClearAllPoints()
        self.IconBorder:SetPoint('CENTER')
        self.IconBorder:SetSize(67, 67)
    else
        self.ignoreBorderGlow = true
    end

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

---@generic T
---@param self T
---@return T
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
    return self:Bind(CreateFrame(ns.ITEM_BUTTON_CLASS, self:GenerateName(), UIParent,
                                 ns.ITEM_BUTTON_CLASS ~= 'ItemButton' and 'ItemButtonTemplate' or nil))
end

function ItemBase:Free()
    self.bag = nil
    self.slot = nil
    self:SetID(0)
    self:Hide()
    self.pool[self] = true
    self.pluginPendings[self] = nil
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

-- @debug@
function ItemBase:OnHide()
end

-- @end-debug@

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
    GameTooltip:Hide()
    ResetCursor()
end

function ItemBase:CreateOverlay()
    local Overlay = CreateFrame('Button')
    Overlay:RegisterForClicks('anyUp')
    Overlay:Hide()

    local function OverlayOnEnter(self)
        ---@type UI.ItemBase
        local parent = self:GetParent()
        local item = parent:IsCached() and parent.info.link
        if item then
            ns.AnchorTooltip(self)
            GameTooltip:SetHyperlink(item, parent.info.count)
            GameTooltip:Show()
        elseif parent.meta:IsEquip() then
            ns.AnchorTooltip(self)
            GameTooltip:SetText(ns.INV_TOOLTIPS[parent.slot])
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

    local function OverlayOnClick(self)
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

function ItemBase:GetEmptyIcon()
    if self.meta:IsEquip() then
        return ns.INV_ICONS[self.slot]
    else
        return self.EMPTY_SLOT_TEXTURE or [[Interface\AddOns\tdBag2\Resource\UI-Backpack-EmptySlot]]
    end
end

function ItemBase:UpdateItem()
    SetItemButtonTexture(self, self.info.icon or self:GetEmptyIcon())
    SetItemButtonCount(self, self.info.count)
end

function ItemBase:UpdateLocked()
    SetItemButtonDesaturated(self, self.hasItem and (self.info.locked or self.notMatched))
end

function ItemBase:UpdateBorder()
    local sets = self.meta.sets
    local r, g, b = self:GetBorderColor()

    self:ApplyBorderColor(r, r, g, b, sets.glowAlpha)
    self.QuestBorder:SetShown(sets.iconQuestStarter and self:IsQuestStarter())
    self.JunkIcon:SetShown(sets.iconJunk and self:IsJunk())
end

function ItemBase:ApplyBorderColor(shown, r, g, b, a)
    if shown then
        self.IconBorder:SetVertexColor(r, g, b, self.ignoreBorderGlow and 1 or a)
        self.IconBorder:Show()
    else
        self.IconBorder:Hide()
    end
end

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

local PendingUpdatePlugin
do
    local timer
    local pendings = ItemBase.pluginPendings

    local function OnTimer()
        timer = nil

        for obj in pairs(pendings) do
            obj:OnUpdatePlugin()
        end
        wipe(pendings)
    end

    function PendingUpdatePlugin(obj)
        if not timer then
            timer = true
            C.Timer.After(0.01, OnTimer)
        end
        pendings[obj] = true
    end
end

function ItemBase:UpdatePlugin()
    if not Addon:HasAnyItemPlugin() then
        return
    end
    return PendingUpdatePlugin(self)
end

function ItemBase:OnUpdatePlugin()
    if not self:IsVisible() then
        return
    end
    for _, opts in Addon:IterateItemPlugins() do
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
    return info.link and C.Item.GetItemFamily(info.link) or 0
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
            local color = ITEM_QUALITY_COLORS[quality]
            return color.r, color.g, color.b
        end
    end
end

function ItemBase:IsCached()
    return self.info and self.info.cached
end

local IsQuestItem = ns.memorize(function(link)
    return select(12, C.Item.GetItemInfo(link)) == LE_ITEM_CLASS_QUESTITEM or Search:IsQuestItem(link) or false
end)

function ItemBase:IsQuestItem()
    if not self.hasItem then
        return
    end

    if not self:IsCached() and self.meta:IsContainer() then
        local info = C.Container.GetContainerItemQuestInfo(self.bag, self.slot)
        if info and info.questID then
            return true
        end
    end
    return IsQuestItem(self.info.id)
end

function ItemBase:IsQuestStarter()
    if not self.hasItem then
        return
    end
    if self:IsCached() or not self.meta:IsContainer() then
        return
    end
    local info = C.Container.GetContainerItemQuestInfo(self.bag, self.slot)
    if not info then
        return
    end
    return info.questID and not info.isActive
end

function ItemBase:IsMatched()
    if self.meta:IsGlobalSearch() then
        return true
    end
    if not self.hasItem then
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
    if Search.BelongsToSet == nop then
        local id = self.info.id
        if C.Item.IsEquippableItem(id) then
            for _, setID in pairs(C.EquipmentSet.GetEquipmentSetIDs()) do
                local items = C.EquipmentSet.GetItemIDs(setID)
                for _, v in pairs(items) do
                    if v == id then
                        return true
                    end
                end
            end
        end
    end
    return Search:BelongsToSet(self.info.id)
end

function ItemBase:IsUnusable()
    return Search:IsUnusable(self.info.id)
end
