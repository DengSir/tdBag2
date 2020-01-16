-- BagToggle.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/20/2019, 2:30:12 AM

---- LUA
local select = select

---- WOW
local PlaySound = PlaySound

---- UI
local GameTooltip = GameTooltip

---- G
local BAGSLOTTEXT = BAGSLOTTEXT

---@type ns
local ns = select(2, ...)
local L = ns.L
local Addon = ns.Addon
local BAG_ID = ns.BAG_ID

---@class tdBag2BagToggle: tdBag2MenuButton
---@field private meta tdBag2FrameMeta
local BagToggle = ns.Addon:NewClass('UI.BagToggle', ns.UI.MenuButton)

function BagToggle:Constructor(_, meta)
    self.meta = meta
    self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    self:SetScript('OnClick', self.OnClick)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', self.OnLeave)
end

function BagToggle:OnClick(button)
    if button == 'LeftButton' then
        self.meta:ToggleOption('bagFrame')
        self:OnEnter()
        ns.PlayToggleSound(self.meta.profile.bagFrame)
    else
        local bagId = self.meta:IsBag() and BAG_ID.BANK or BAG_ID.BAG
        Addon:ToggleOwnerFrame(bagId, self.meta.owner)
    end
end

function BagToggle:OnEnter()
    ns.AnchorTooltip(self)
    GameTooltip:SetText(BAGSLOTTEXT)
    if self.meta.profile.bagFrame then
        GameTooltip:AddLine(ns.LeftButtonTip(L.TOOLTIP_HIDE_BAG_FRAME))
    else
        GameTooltip:AddLine(ns.LeftButtonTip(L.TOOLTIP_SHOW_BAG_FRAME))
    end
    if self.meta:IsBank() then
        GameTooltip:AddLine(ns.RightButtonTip(L.TOOLTIP_TOGGLE_BAG))
    else
        GameTooltip:AddLine(ns.RightButtonTip(L.TOOLTIP_TOGGLE_BANK))
    end
    GameTooltip:Show()
end

function BagToggle:OnLeave()
    GameTooltip:Hide()
end

Addon:RegisterPluginButton({
    key = 'BagToggle',
    text = L['Bag Toggle'],
    icon = ns.BAG_ICONS[ns.BAG_ID.BAG],
    order = 10000,
    init = function(button, frame)
        BagToggle:Bind(button, frame.meta)
    end,
})
