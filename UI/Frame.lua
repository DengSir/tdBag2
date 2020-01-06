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
local FrameBase = ns.UI.FrameBase

local LibWindow = LibStub('LibWindow-1.1')

---@class tdBag2Frame: tdBag2FrameBase
---@field private meta tdBag2FrameMeta
---@field private portrait Texture
---@field private Icon string
---@field private Container tdBag2Container
---@field private TitleFrame tdBag2TitleFrame
---@field private OwnerSelector tdBag2OwnerSelector
---@field private BagFrame tdBag2BagFrame
---@field SearchBox tdBag2SearchBox
---@field private TokenFrame tdBag2TokenFrame
---@field private PluginFrame tdBag2PluginFrame
local Frame = ns.Addon:NewClass('UI.Frame', FrameBase)

function Frame:Constructor(_, bagId)
    ns.UI.MoneyFrame:Bind(self.MoneyFrame, self.meta)
    ns.UI.TokenFrame:Bind(self.TokenFrame, self.meta)
    ns.UI.BagFrame:Bind(self.BagFrame, self.meta)
    ns.UI.PluginFrame:Bind(self.PluginFrame, self.meta)

    self.Container = ns.UI.Container:New(self, self.meta)
    self.Container:SetPoint('TOPLEFT', self.Inset, 'TOPLEFT', 8, -8)
    self.Container:SetSize(1, 1)
    self.Container:SetCallback('OnLayout', function()
        self:UpdateSize()
        self:PlaceBagFrame()
        self:PlaceSearchBox()
    end)

    self.SearchBox:HookScript('OnEditFocusLost', function()
        self:SEARCH_CHANGED()
    end)
    self.SearchBox:HookScript('OnEditFocusGained', function()
        self:SEARCH_CHANGED()
    end)
end

function Frame:OnShow()
    FrameBase.OnShow(self)
    self:RegisterEvent('UPDATE_ALL', 'Update')
    self:RegisterEvent('SEARCH_CHANGED')
    self:Update()
end

function Frame:SEARCH_CHANGED()
    self:PlaceBagFrame()
    self:PlaceSearchBox()
end

function Frame:UpdateSize()
    return self:SetSize(self.Container:GetWidth() + 24, self.Container:GetHeight() + 100)
end

function Frame:Update()
    self:PlacePluginFrame()
    self:PlaceBagFrame()
    self:PlaceSearchBox()
    self:PlaceTokenFrame()
end

function Frame:PlacePluginFrame()
    return self.PluginFrame:Update()
end

function Frame:PlaceBagFrame()
    return self.BagFrame:SetShown(self.meta.profile.bagFrame and
                                      (self:IsSearchBoxSpaceEnough() or
                                          not (self.SearchBox:HasFocus() or Addon:GetSearch())))
end

function Frame:PlaceTokenFrame()
    return self.TokenFrame:SetShown(self.meta.profile.tokenFrame)
end

function Frame:PlaceSearchBox()
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
