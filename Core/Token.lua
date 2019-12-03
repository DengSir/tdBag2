-- Token.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 11/29/2019, 11:21:51 AM

local GetItemIcon = GetItemIcon
local GetItemCount = GetItemCount

local GameTooltip = GameTooltip

---@type ns
local ns = select(2, ...)
local L = ns.L
local Counter = ns.Counter

---@class tdBag2Token: Frame
---@field private Icon Texture
---@field private Count FontString
---@field private itemId number
local Token = ns.Addon:NewClass('UI.Token', 'Frame.tdBag2TokenTemplate')

function Token:Constructor()
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', GameTooltip_Hide)
    self:SetMouseClickEnabled(false)
end

function Token:SetItem(owner, itemId)
    self.itemId = itemId
    self.Icon:SetTexture(GetItemIcon(itemId))
    self.Count:SetText(ns.Counter:GetOwnerItemTotal(owner, itemId))
    self:SetWidth(self.Count:GetWidth() + 16)
end

function Token:OnEnter()
    ns.AnchorTooltip(self)
    GameTooltip:SetHyperlink('item:' .. self.itemId)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(ns.RightButtonTip(L.TOOLTIP_WATCHED_TOKENS))
    GameTooltip:Show()
end
