-- EquipFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/13/2022, 1:45:58 PM
--
---@type ns
local ns = select(2, ...)

local SimpleFrame = ns.UI.SimpleFrame

---@class UI.EquipFrame: UI.SimpleFrame
local EquipFrame = ns.Addon:NewClass('UI.EquipFrame', SimpleFrame)
EquipFrame.CENTER_TEMPLATE = 'tdBag2EquipContainerCenterFrameTemplate'
EquipFrame.TOGGLES = {ns.BAG_ID.BAG, ns.BAG_ID.BANK, ns.BAG_ID.MAIL, ns.BAG_ID.SEARCH}

function EquipFrame:Constructor()
    ---@type tdBag2EquipContainerCenterFrameTemplate
    self.CenterFrame = CreateFrame('Frame', nil, self, self.CENTER_TEMPLATE)

    self.toggles = {}

    for i, bagId in ipairs(self.TOGGLES) do
        local button = ns.UI.EquipBagToggle:Create(self.CenterFrame, self.meta, bagId)

        if i == 1 then
            button:SetPoint('LEFT', self.CenterFrame, 'BOTTOM', -button:GetWidth() * #self.TOGGLES / 2, 60)
        else
            button:SetPoint('LEFT', self.toggles[i - 1], 'RIGHT')
        end

        tinsert(self.toggles, button)
    end
end

function EquipFrame:OnShow()
    SimpleFrame.OnShow(self)
    self:UpdateCenter()
    self:RegisterFrameEvent('OWNER_CHANGED', 'UpdateCenter')
end

function EquipFrame:UpdateCenter()
end
