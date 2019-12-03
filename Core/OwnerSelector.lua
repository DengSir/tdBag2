-- OwnerSelector.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/18/2019, 10:26:06 AM

---- LUA
local select = select
local tinsert = table.insert
local unpack = table.unpack or unpack

---- WOW
local CreateFrame = CreateFrame
local EasyMenu_Initialize = EasyMenu_Initialize
local HideDropDownMenu = HideDropDownMenu
local ToggleDropDownMenu = ToggleDropDownMenu
local SetPortraitTexture = SetPortraitTexture

---- UI
local GameTooltip = GameTooltip
local UIParent = UIParent

---- G
local CHARACTER = CHARACTER
local DELETE = DELETE

---@type ns
local ns = select(2, ...)
local L = ns.L
local Addon = ns.Addon
local Cache = ns.Cache

---@class tdBag2OwnerSelector: tdBag2MenuButton
---@field private meta tdBag2FrameMeta
local OwnerSelector = ns.Addon:NewClass('UI.OwnerSelector', ns.UI.MenuButton)
OwnerSelector.menuOffset = {xOffset = 8}

function OwnerSelector:Constructor(_, meta)
    self.meta = meta
    self.portrait = self.meta.frame.portrait
    self:SetScript('OnClick', self.OnClick)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', self.OnLeave)
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)
end

function OwnerSelector:OnShow()
    self:RegisterFrameEvent('FRAME_OWNER_CHANGED', 'UpdateIcon')
    self:RegisterEvent('UPDATE_ALL', 'Update')
    self:Update()
end

function OwnerSelector:OnHide()
    self:UnregisterAllEvents()
    self:CloseMenu()
end

function OwnerSelector:OnClick(button)
    if button == 'RightButton' then
        Addon:SetOwner(self.meta.bagId, nil)
    else
        self:OnLeave()
        self:ToggleMenu()
    end
end

function OwnerSelector:OnEnter()
    ns.AnchorTooltip(self)
    GameTooltip:SetText(CHARACTER)
    GameTooltip:AddLine(ns.LeftButtonTip(L.TOOLTIP_CHANGE_PLAYER))
    GameTooltip:AddLine(ns.RightButtonTip(L.TOOLTIP_RETURN_TO_SELF))
    GameTooltip:Show()
end

function OwnerSelector:OnLeave()
    GameTooltip:Hide()
end

function OwnerSelector:Update()
    self:UpdateEnable()
    self:UpdateIcon()
end

function OwnerSelector:UpdateEnable()
    self:SetEnabled(self:HasMultiOwners())
end

function OwnerSelector:UpdateIcon()
    if not self.meta.sets.iconChar then
        self.portrait:SetTexture(ns.BAG_ICONS[self.meta.bagId])
        self.portrait:SetTexCoord(0, 1, 0, 1)
    elseif self.meta:IsSelf() then
        SetPortraitTexture(self.portrait, 'player')
        self.portrait:SetTexCoord(0, 1, 0, 1)
    else
        local ownerInfo = Cache:GetOwnerInfo(self.meta.owner)
        if ownerInfo.race then
            local gender = ownerInfo.gender == 3 and 'FEMALE' or 'MALE'
            local race = ownerInfo.race:upper()
            local coords = ns.RACE_ICON_TCOORDS[race .. '_' .. gender]

            self.portrait:SetTexture([[Interface\Glues\CharacterCreate\UI-CharacterCreate-Races]])
            self.portrait:SetTexCoord(unpack(coords))
        elseif ownerInfo.faction == 'Alliance' then
            self.portrait:SetTexture([[Interface\Icons\inv_bannerpvp_02]])
            self.portrait:SetTexCoord(0, 1, 0, 1)
        else
            self.portrait:SetTexture([[Interface\Icons\inv_bannerpvp_01]])
            self.portrait:SetTexCoord(0, 1, 0, 1)
        end
    end
end

function OwnerSelector:HasMultiOwners()
    local iter = Cache:IterateOwners()
    return iter() and iter()
end

function OwnerSelector:CreateMenu()
    local menuList = {self:CreateOwnerMenu()}
    for name in Cache:IterateOwners() do
        if not ns.IsSelf(name) then
            tinsert(menuList, self:CreateOwnerMenu(name))
        end
    end
    return menuList
end

function OwnerSelector:CreateOwnerMenu(name)
    local info = Cache:GetOwnerInfo(name)
    local isSelf = not name
    local isCurrent = name == self.meta.owner
    local hasArrow = not isSelf and not isCurrent

    return {
        text = ns.GetOwnerColoredName(info),
        checked = isCurrent,
        hasArrow = hasArrow,
        menuList = hasArrow and {
            {
                notCheckable = true,
                text = DELETE,
                func = function()
                    Cache:DeleteOwnerInfo(name)
                    HideDropDownMenu(1)
                end,
            },
        },
        func = function()
            Addon:SetOwner(self.meta.bagId, not isSelf and name or nil)
        end,
    }
end
