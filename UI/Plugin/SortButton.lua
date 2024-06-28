-- SortButton.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/10/2024, 7:28:34 PM
--
local ns = select(2, ...)

local C = LibStub('C_Everywhere')

local GameTooltip = GameTooltip

---@class UI.SortButton: UI.MenuButton
---@field meta FrameMeta
local SortButton = ns.Addon:NewClass('UI.SortButton', ns.UI.MenuButton)

function SortButton:Constructor(_, meta)
    self.meta = meta
    self:SetScript('OnClick', self.OnClick)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', GameTooltip_Hide)
end

function SortButton:OnClick()
    if self.meta:IsBag() then
        C.Container.SortBags()
    elseif self.meta:IsBank() then
        C.Container.SortBankBags()

        C.Timer.After(0.3, function()
            C.Container.SortReagentBankBags()
        end)
    end
end

function SortButton:OnEnter()
    ns.AnchorTooltip(self)
    if self.meta:IsBag() then
        GameTooltip:SetText(BAG_CLEANUP_BAGS)
    elseif self.meta:IsBank() then
        GameTooltip:SetText(BAG_CLEANUP_BANK)
    end
    GameTooltip:Show()
end
