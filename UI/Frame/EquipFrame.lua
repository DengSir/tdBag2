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

function EquipFrame:Constructor()
    ---@type tdBag2EquipContainerCenterFrameTemplate
    self.CenterFrame = CreateFrame('Frame', nil, self, 'tdBag2EquipContainerCenterFrameTemplate')

    self.toggles = {}

    local function OnClick(button)
        ns.Addon:ToggleOwnerFrame(button.bagId, self.meta.owner)
    end

    local function OnEnter(button)
        local name = ns.Cache:GetOwnerInfo(self.meta.owner).name
        local title = ns.BAG_TITLES[button.bagId]
        title = name and format(title, Ambiguate(name, 'none')) or title
        GameTooltip:SetOwner(button, 'ANCHOR_TOP')
        GameTooltip:SetText(title)
        GameTooltip:Show()
    end

    local bags = {ns.BAG_ID.BAG, ns.BAG_ID.BANK, ns.BAG_ID.MAIL}

    for i, bagId in ipairs(bags) do
        ---@type tdBag2EquipBagToggleFrameTemplate
        local button = CreateFrame('Button', nil, self.CenterFrame, 'tdBag2EquipBagToggleFrameTemplate')
        button.icon:SetTexture(ns.BAG_ICONS[bagId])
        button.bagId = bagId

        button:SetScript('OnClick', OnClick)
        button:SetScript('OnEnter', OnEnter)
        button:SetScript('OnLeave', GameTooltip_Hide)

        if i == 1 then
            button:SetPoint('LEFT', self, 'CENTER', -button:GetWidth() * #bags / 2, 0)
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
