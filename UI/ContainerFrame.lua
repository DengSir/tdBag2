-- ContainerFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/17/2019, 10:21:54 AM

---@type ns
local ns = select(2, ...)
local Addon = ns.Addon
local Frame = ns.UI.Frame

local LibWindow = LibStub('LibWindow-1.1')

---@class tdBag2ContainerFrame: tdBag2Frame
---@field private meta tdBag2FrameMeta
---@field private portrait Texture
---@field private Icon string
---@field private Container tdBag2Container
---@field private BagFrame tdBag2BagFrame
---@field private TokenFrame tdBag2TokenFrame
---@field private PluginFrame tdBag2PluginFrame
local ContainerFrame = ns.Addon:NewClass('UI.ContainerFrame', Frame)

function ContainerFrame:Constructor(_, bagId)
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

function ContainerFrame:OnShow()
    Frame.OnShow(self)
    self:RegisterEvent('UPDATE_ALL', 'Update')
    self:RegisterEvent('SEARCH_CHANGED')
    self:RegisterFrameEvent('BAG_FRAME_TOGGLED', 'SEARCH_CHANGED')
    self:Update()
end

function ContainerFrame:SEARCH_CHANGED()
    self:PlaceBagFrame()
    self:PlaceSearchBox()
end

function ContainerFrame:UpdateSize()
    return self:SetSize(self.Container:GetWidth() + 24, self.Container:GetHeight() + 100)
end

function ContainerFrame:Update()
    self:PlacePluginFrame()
    self:PlaceBagFrame()
    self:PlaceSearchBox()
    self:PlaceTokenFrame()
end

function ContainerFrame:PlacePluginFrame()
    return self.PluginFrame:Update()
end

function ContainerFrame:PlaceBagFrame()
    return self.BagFrame:SetShown(self.meta.profile.bagFrame and
                                      (self:IsSearchBoxSpaceEnough() or
                                          not (self.SearchBox:HasFocus() or Addon:GetSearch())))
end

function ContainerFrame:PlaceTokenFrame()
    return self.TokenFrame:SetShown(self.meta.profile.tokenFrame)
end

function ContainerFrame:PlaceSearchBox()
    if not self.meta.profile.bagFrame or self.SearchBox:HasFocus() or Addon:GetSearch() or self:IsSearchBoxSpaceEnough() then
        self.SearchBox:Show()
        self.SearchBox:ClearAllPoints()
        self.SearchBox:SetPoint('RIGHT', self.PluginFrame, 'LEFT', -9, 0)

        if self.BagFrame:IsShown() then
            self.SearchBox:SetPoint('LEFT', self.BagFrame, 'RIGHT', 15, 0)
        else
            self.SearchBox:SetPoint('TOPLEFT', 74, -28)
        end
    else
        self.SearchBox:Hide()
    end
end

function ContainerFrame:IsSearchBoxSpaceEnough()
    return self:GetWidth() - self.BagFrame:GetWidth() - self.PluginFrame:GetWidth() > 140
end
