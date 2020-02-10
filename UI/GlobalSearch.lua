-- GlobalSearch.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 1:14:38 AM

local setmetatable = setmetatable

---@type ns
local ns = select(2, ...)

local Frame = ns.UI.Frame

---@class tdBag2GlobalSearchFrame: tdBag2Frame
---@field Container tdBag2TitleContainer
local GlobalSearch = ns.Addon:NewClass('UI.GlobalSearch', Frame)

function GlobalSearch:Constructor()
    ns.UI.TitleContainer:Bind(self.Container, self.meta)

    setmetatable(self.Container.itemButtons, {
        __index = function(t, k)
            t[k] = {}
            return t[k]
        end,
    })

    self.Container:SetAlwaysShowTitle(true)

    self.OwnerSelector:UpdateIcon()
    self.OwnerSelector:Hide()

    self.SearchBox:SetScript('OnShow', self.SearchBox.SetFocus)
    self.SearchBox:SetScript('OnEscapePressed', self.SearchBox.ClearFocus)
    self.SearchBox:SetScript('OnHide', function(self)
        return self:SetText('')
    end)
    self.SearchBox.SetSearch = function(self, text)
        return ns.GlobalSearch:Search(text)
    end
end

function GlobalSearch:OnShow()
    self.meta:SetOwner(ns.GLOBAL_SEARCH_OWNER)
    self:RegisterEvent('GLOBAL_SEARCH_UPDATE')
    Frame.OnShow(self)
end

function GlobalSearch:GLOBAL_SEARCH_UPDATE()
    self.meta.bags = ns.GlobalSearch:GetBags()
    self.Container:RequestLayout()
end
