-- SearchToggle.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/28/2019, 1:35:39 AM

---@type ns
local ns = select(2, ...)
local L = ns.L

local GameTooltip = GameTooltip

local ipairs = ipairs
local tinsert, tremove = table.insert, table.remove
local format = string.format
local tContains = tContains

local ADD = ADD
local DELETE = DELETE
local SEARCH = SEARCH

---@class tdBag2SearchToggle: tdBag2MenuButton
---@field private meta tdBag2FrameMeta
local SearchToggle = ns.Addon:NewClass('UI.SearchToggle', ns.UI.MenuButton)

function SearchToggle:Constructor(_, meta)
    self.meta = meta
    self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    self:SetScript('OnClick', self.OnClick)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', GameTooltip_Hide)
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.UnregisterAllEvents)
end

function SearchToggle:OnShow()
    self:RegisterEvent('SEARCH_CHANGED', 'CloseMenu')
end

function SearchToggle:OnClick(button)
    if button == 'LeftButton' then
        self.meta.frame:ToggleSearchBoxFocus()
    else
        self:ToggleMenu()
    end
end

function SearchToggle:OnEnter()
    ns.AnchorTooltip(self)
    GameTooltip:SetText(SEARCH)
    GameTooltip:AddLine(ns.LeftButtonTip(L.TOOLTIP_SEARCH_TOGGLE))
    GameTooltip:AddLine(ns.RightButtonTip(L.TOOLTIP_SEARCH_RECORDS))
    GameTooltip:Show()
end

local separatorInfo

function SearchToggle:CreateMenu()
    local result = {}
    local searches = self.meta.sets.searches

    local text = ns.Addon:GetSearch()
    if text and text ~= '' and not tContains(searches, text) then
        tinsert(result, {
            text = format('%s |cff00ffff%s|r', ADD, text),
            notCheckable = true,
            func = function()
                tinsert(searches, text)
            end,
        })
        if not separatorInfo then
            separatorInfo = {
                text = '',
                hasArrow = false,
                dist = 0,
                isTitle = true,
                isUninteractable = true,
                notCheckable = true,
                iconOnly = true,
                icon = [[Interface\Common\UI-TooltipDivider-Transparent]],
                tCoordLeft = 0,
                tCoordRight = 1,
                tCoordTop = 0,
                tCoordBottom = 1,
                tSizeX = 0,
                tSizeY = 8,
                tFitDropDownSizeX = true,
                iconInfo = {
                    tCoordLeft = 0,
                    tCoordRight = 1,
                    tCoordTop = 0,
                    tCoordBottom = 1,
                    tSizeX = 0,
                    tSizeY = 8,
                    tFitDropDownSizeX = true,
                },
            }
        end
        tinsert(result, separatorInfo)
    end

    if #searches == 0 then
        tinsert(result, {text = L['No record'], disabled = true, notCheckable = true})
    else
        for i, item in ipairs(searches) do
            tinsert(result, {
                text = item,
                func = function()
                    ns.Addon:SetSearch(item)
                end,
                hasArrow = true,
                checked = text == item,
                menuList = {
                    {
                        text = DELETE,
                        notCheckable = true,
                        func = function()
                            tremove(searches, i)
                            self:CloseMenu()
                        end,
                    },
                },
            })
        end
    end
    return result
end

ns.Addon:RegisterPluginButton({
    key = 'SearchToggle',
    text = SEARCH,
    icon = [[Interface\Minimap\Tracking\None]],
    order = 10001,
    init = function(button, frame)
        SearchToggle:Bind(button, frame.meta)
    end,
})
