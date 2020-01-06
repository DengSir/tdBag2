-- TitleFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/18/2019, 10:14:01 AM

local format = string.format

local IsAltKeyDown = IsAltKeyDown

---@type ns
local ns = select(2, ...)
local L = ns.L
local Cache = ns.Cache

---@class tdBag2TitleFrame: Button
---@field private meta tdBag2FrameMeta
local TitleFrame = ns.Addon:NewClass('UI.TitleFrame', 'Button')

function TitleFrame:Constructor(_, meta)
    self.meta = meta
    self.title = ns.BAG_TITLES[meta.bagId]
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)
    self:SetScript('OnMouseDown', self.OnMouseDown)
    self:SetScript('OnMouseUp', self.OnMouseUp)
    self:SetScript('OnClick', self.OnClick)
    self:RegisterForClicks('RightButtonUp')
end

function TitleFrame:OnShow()
    self:Update()
    self:RegisterFrameEvent('FRAME_OWNER_CHANGED', 'Update')
    self:RegisterEvent('UPDATE_ALL', 'Update')

    if self.meta:IsBank() then
        self:RegisterEvent('BANK_CLOSED', 'Update')
    end
end

function TitleFrame:OnHide()
    self:UnregisterAllEvents()
    if self.moving then
        self:OnMouseUp()
    end
end

function TitleFrame:OnMouseDown()
    if not self.meta.profile.managed and (not self.meta.sets.lockFrame or IsAltKeyDown()) then
        self.meta.frame:StartMoving()
        self.moving = true
    end
end

function TitleFrame:OnMouseUp()
    local parent = self.meta.frame
    parent:StopMovingOrSizing()
    parent:SavePosition()
    self.moving = nil
end

function TitleFrame:OnClick(button)
    if button == 'RightButton' then
        ns.Addon:OpenFrameOption(self.meta.bagId)
    end
end

function TitleFrame:Update()
    local title = format(self.title, Cache:GetOwnerInfo(self.meta.owner).name)
    if self.meta.sets.textOffline and self.meta:IsCached() then
        title = title .. ' ' .. L['|cffff2020(Offline)|r']
    end
    self:SetText(title)
end
