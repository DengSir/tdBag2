-- Frame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/17/2019, 10:21:54 AM

---- LUA
local _G = _G
local ipairs = ipairs
local select = select
local tinsert, wipe = table.insert, table.wipe
local tContains, tDeleteItem = tContains, tDeleteItem

---- WOW
local CreateFrame = CreateFrame
local HideUIPanel = HideUIPanel
local PlaySound = PlaySound
local ShowUIPanel = ShowUIPanel
local UpdateUIPanelPositions = UpdateUIPanelPositions

---- G
local SOUNDKIT = SOUNDKIT

---@type ns
local ns = select(2, ...)
local Addon = ns.Addon

local LibWindow = LibStub('LibWindow-1.1')

---@class tdBag2Frame: Frame
---@field private meta tdBag2FrameMeta
---@field private menuButtons Button[]
---@field private pluginButtons table<string, Button>
---@field private portrait Texture
---@field private Icon string
---@field private Container tdBag2Container
---@field private TitleFrame tdBag2TitleFrame
---@field private OwnerSelector tdBag2OwnerSelector
---@field private BagFrame tdBag2BagFrame
---@field SearchBox tdBag2SearchBox
---@field private TokenFrame tdBag2TokenFrame
---@field private PluginFrame tdBag2PluginFrame
local Frame = ns.Addon:NewClass('UI.Frame', 'Frame')

function Frame:Constructor(_, bagId)
    self.meta = ns.FrameMeta:New(bagId, self)
    self.menuButtons = {}
    self.pluginButtons = {}
    self.name = 'tdBag2Bag' .. self.meta.bagId

    self.portrait:SetTexture(ns.BAG_ICONS[bagId])

    ns.UI.TitleFrame:Bind(self.TitleFrame, self.meta)
    ns.UI.OwnerSelector:Bind(self.OwnerSelector, self.meta)
    ns.UI.SearchBox:Bind(self.SearchBox, self.meta)
    ns.UI.MoneyFrame:Bind(self.MoneyFrame, self.meta)
    ns.UI.TokenFrame:Bind(self.TokenFrame, self.meta)

    if self.BagFrame then
        ns.UI.BagFrame:Bind(self.BagFrame, self.meta)
    end
    if self.PluginFrame then
        ns.UI.PluginFrame:Bind(self.PluginFrame, self.meta)
    end

    self.Container = ns.UI.Container:New(self, self.meta)
    self.Container:SetPoint('TOPLEFT', self.Inset, 'TOPLEFT', 8, -8)
    self.Container:SetSize(1, 1)
    self.Container:SetCallback('OnLayout', function()
        self:UpdateSize()
        self:LayoutSearchBoxAndBagFrame()
    end)

    self.SearchBox:HookScript('OnEditFocusLost', function()
        self:LayoutSearchBoxAndBagFrame()
    end)

    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)

    self:UpdateManaged()
    self:UpdateSpecial()
end

function Frame:OnShow()
    PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
    self:RegisterEvent('UPDATE_ALL', 'Update')
    self:RegisterEvent('SEARCH_CHANGED', 'LayoutSearchBoxAndBagFrame')
    self:Update()
end

function Frame:OnHide()
    PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    self.meta.owner = nil
    self:UnregisterAllEvents()
end

Frame.OnSizeChanged = ns.Spawned(UpdateUIPanelPositions)

function Frame:UpdateSize()
    return self:SetSize(self.Container:GetWidth() + 24, self.Container:GetHeight() + 100)
end

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

function Frame:ToggleOption(key)
    self.meta.profile[key] = not self.meta.profile[key]
end

function Frame:Update()
    self:LayoutPluginFrame()
    self:LayoutSearchBoxAndBagFrame()
    self:LayoutTokenFrame()
end

function Frame:LayoutSearchBoxAndBagFrame()
    self:LayoutBagFrame()
    self:LayoutSearchBox()
end

function Frame:LayoutPluginFrame()
    if self.PluginFrame then
        self.PluginFrame:Update()
    end
end

function Frame:LayoutBagFrame()
    if self.BagFrame then
        self.BagFrame:SetShown(self.meta.profile.bagFrame and
                                   (self:IsSearchBoxSpaceEnough() or
                                       not (self.SearchBox:HasFocus() or Addon:GetSearch())))
    end
end

function Frame:LayoutTokenFrame()
    self.TokenFrame:SetShown(self.meta.profile.tokenFrame)
end

function Frame:LayoutSearchBox()
    if not self.meta.profile.bagFrame or self.SearchBox:HasFocus() or Addon:GetSearch() or self:IsSearchBoxSpaceEnough() then
        self.SearchBox:Show()
        self.SearchBox:ClearAllPoints()

        if self.PluginFrame then
            self.SearchBox:SetPoint('RIGHT', self.PluginFrame, 'LEFT', -9, 0)
        else
            self.SearchBox:SetPoint('TOPRIGHT', -20, -28)
        end

        if self.BagFrame and self.BagFrame:IsShown() then
            self.SearchBox:SetPoint('LEFT', self.BagFrame, 'RIGHT', 15, 0)
        else
            self.SearchBox:SetPoint('TOPLEFT', 74, -28)
        end
    else
        self.SearchBox:Hide()
    end
end

function Frame:IsSearchBoxSpaceEnough()
    return self:GetWidth() - (self.BagFrame and self.BagFrame:GetWidth() or 0) -
               (self.PluginFrame and self.PluginFrame:GetWidth() or 0) > 140
end
