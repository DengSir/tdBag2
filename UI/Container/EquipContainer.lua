-- EquipContainer.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/10/2022, 8:29:17 PM
--
---@type ns
local ns = select(2, ...)

---@class UI.EquipContainer: UI.Container
local EquipContainer = ns.Addon:NewClass('UI.EquipContainer', ns.UI.Container)

function EquipContainer:Constructor()
    self:SetSize(313, 343)
end

function EquipContainer:OnLayout()
    local bag = self.meta.bags[1]

    for slot = 1, self:NumSlots(bag) do
        local itemButton = self:GetItemButton(bag, slot)
        local pos = ns.GetInvPos(slot)

        itemButton:ClearAllPoints()
        itemButton:SetPoint(pos.point, self, pos.point, pos.x, pos.y)
        itemButton:Show()
    end
end
