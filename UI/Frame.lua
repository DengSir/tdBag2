-- FrameBase.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/7/2020, 12:31:57 AM

local _G = _G

local tinsert = table.insert
local tDeleteItem = tDeleteItem

local PlaySound = PlaySound
local ShowUIPanel = ShowUIPanel
local HideUIPanel = HideUIPanel

local UISpecialFrames = UISpecialFrames

---@type ns
local ns = select(2, ...)

local LibWindow = LibStub('LibWindow-1.1')

---@class tdBag2Frame: Frame
---@field protected meta tdBag2FrameMeta
---@field protected TitleFrame tdBag2TitleFrame
---@field protected OwnerSelector tdBag2OwnerSelector
---@field protected SearchBox tdBag2SearchBox
---@field protected Container tdBag2Container
local Frame = ns.Addon:NewClass('UI.Frame', 'Frame')

function Frame:Constructor(_, bagId)
    self.meta = ns.FrameMeta:New(bagId, self)
    self.name = 'tdBag2Bag' .. self.meta.bagId

    ns.UI.TitleFrame:Bind(self.TitleFrame, self.meta)
    ns.UI.OwnerSelector:Bind(self.OwnerSelector, self.meta)
    ns.UI.SearchBox:Bind(self.SearchBox, self.meta)

    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)

    self:UpdateManaged()
    self:UpdateSpecial()
end

function Frame:OnShow()
    PlaySound(862) -- SOUNDKIT.IG_BACKPACK_OPEN
    self:RegisterFrameEvent('MANAGED_TOGGLED', 'UpdateManaged')
end

function Frame:OnHide()
    PlaySound(863) -- SOUNDKIT.IG_BACKPACK_CLOSE
    self.meta.owner = nil
    self:UnregisterAllEvents()
end

Frame.OnSizeChanged = ns.Spawned(UpdateUIPanelPositions)

function Frame:UpdatePosition()
    if not self.meta.profile.managed then
        LibWindow.RegisterConfig(self, self.meta.profile.window)
        LibWindow.RestorePosition(self)
    end
end

function Frame:SavePosition()
    if not self.meta.profile.managed then
        LibWindow.SavePosition(self)
    end
end

function Frame:UpdateManaged()
    local managed = self.meta.profile.managed
    local changed = not self:GetAttribute('UIPanelLayout-enabled') ~= not managed

    if not changed then
        return
    end

    self.updatingManaged = true

    local shown = self:IsShown()
    if shown then
        HideUIPanel(self)
    end

    self:SetAttribute('UIPanelLayout-enabled', managed)
    self:SetAttribute('UIPanelLayout-defined', managed)
    self:SetAttribute('UIPanelLayout-whileDead', managed)
    self:SetAttribute('UIPanelLayout-area', managed and 'left')
    self:SetAttribute('UIPanelLayout-pushable', managed and 1)

    if shown then
        ShowUIPanel(self)
    end

    self:UpdateSpecial()
    self.updatingManaged = nil
end

function Frame:UpdateSpecial()
    if not self.meta.profile.managed then
        if not _G[self.name] then
            _G[self.name] = self
            tinsert(UISpecialFrames, self.name)
        end

        self:SetScript('OnSizeChanged', nil)
        self:UpdatePosition()
    else
        if _G[self.name] then
            _G[self.name] = nil
            tDeleteItem(UISpecialFrames, self.name)
        end

        self:SetScript('OnSizeChanged', self.OnSizeChanged)
        self:OnSizeChanged()
    end
end

function Frame:UpdateSize()
    return self:SetSize(self.Container:GetWidth() + 24, self.Container:GetHeight() + 78)
end

function Frame:ToggleSearchBoxFocus()
    if self.SearchBox:HasFocus() then
        self.SearchBox:ClearFocus()
    else
        self.SearchBox:Show()
        self.SearchBox:SetFocus()
    end
end

function Frame:ShowBottomBar()
    self.BtnCornerLeft:Hide()
    self.BtnCornerRight:Hide()
    self.ButtonBottomBorder:Hide()
    self.Inset:SetPoint('BOTTOMRIGHT', -6, 26)
end
