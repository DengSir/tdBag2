-- tdBag2.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/17/2019, 12:04:55 AM

---- LUA
local ipairs, pairs, nop, tinsert, sort = ipairs, pairs, nop, tinsert, sort

---- WOW
local ShowUIPanel = ShowUIPanel
local HideUIPanel = HideUIPanel
local CreateFrame = CreateFrame

---- UI
local BankFrame = BankFrame
local UIParent = UIParent

---@class ns
---@field UI UI
---@field Addon Addon
---@field Events Events
---@field FrameMeta tdBag2FrameMeta
---@field Counter tdBag2Counter
---@field Forever tdBag2Forever
---@field Cache tdBag2Cache
local ns = select(2, ...)
local BAG_ID = ns.BAG_ID

---@class tdBag2FrameProfile
---@field column number
---@field reverseBag boolean
---@field reverseSlot boolean
---@field managed boolean
---@field bagFrame boolean
---@field tokenFrame boolean
---@field window table
---@field tradeBagOrder string
---@field hiddenBags table<number, boolean>

---@class tdBag2Profile
---@field glowAlpha number
---@field textOffline boolean
---@field iconJunk boolean
---@field iconQuestStarter boolean
---@field glowQuest boolean
---@field glowUnusable boolean
---@field glowQuality boolean
---@field glowEquipSet boolean
---@field glowNew boolean
---@field colorSlots boolean
---@field lockFrame boolean
---@field emptyAlpha number
---@field tokens table
---@field searches string[]

---@class UI
---@field Frame tdBag2Frame
---@field Item tdBag2Item
---@field Bag tdBag2Bag
---@field Bank tdBag2Bank
---@field Inventory tdBag2Inventory
---@field Container tdBag2Container
---@field TitleFrame tdBag2TitleFrame
---@field OwnerSelector tdBag2OwnerSelector
---@field SearchBox tdBag2SearchBox
---@field TokenFrame tdBag2TokenFrame
---@field Token tdBag2Token
---@field MenuButton tdBag2MenuButton
ns.UI = {}
-- ns.Cache = LibStub('LibItemCache-2.0')
ns.Cache = {}
ns.Search = LibStub('LibItemSearch-1.2')
ns.Unfit = LibStub('Unfit-1.0')

---@class Addon
---@field private frames table<string, tdBag2Frame>
local Addon = LibStub('AceAddon-3.0'):NewAddon('tdBag2', 'LibClass-2.0', 'AceHook-3.0', 'AceEvent-3.0')
ns.Addon = Addon
_G.tdBag2 = Addon

function Addon:OnInitialize()
    self.frames = {}
    self.bagClasses = { --
        [BAG_ID.BAG] = ns.UI.Inventory,
        [BAG_ID.BANK] = ns.UI.Bank,
    }
    self.db = LibStub('AceDB-3.0'):New('TDDB_BAG2', {
        global = {forever = {}},
        profile = {
            frames = {
                [BAG_ID.BAG] = { --
                    window = {point = 'BOTTOMRIGHT', x = -50, y = 100},
                    disableButtons = {},
                    column = 8,
                    reverseBag = false,
                    reverseSlot = false,
                    managed = false,
                    bagFrame = false,
                    tokenFrame = true,
                    scale = 1,
                    tradeBagOrder = ns.TRADE_BAG_ORDER.BOTTOM,
                    hiddenBags = {},
                },
                [BAG_ID.BANK] = { --
                    window = {point = 'TOPLEFT', x = 50, y = -100},
                    disableButtons = {},
                    column = 12,
                    reverseBag = false,
                    reverseSlot = false,
                    managed = true,
                    bagFrame = true,
                    tokenFrame = true,
                    scale = 1,
                    tradeBagOrder = ns.TRADE_BAG_ORDER.NONE,
                    hiddenBags = {},
                },
            },

            displayMail = true,
            displayMerchant = true,
            displayCharacter = false,
            displayAuction = true,
            displayTrade = true,
            displayCraft = true,
            displayBank = true,

            closeMail = true,
            closeMerchant = true,
            closeCharacter = false,
            closeAuction = true,
            closeTrade = true,
            closeCraft = true,
            closeBank = true,
            closeCombat = false,

            glowQuest = true,
            glowUnusable = true,
            glowQuality = true,
            glowEquipSet = true,
            glowNew = true,
            glowAlpha = 0.5,

            lockFrame = false,
            iconJunk = true,
            iconQuestStarter = true,
            textOffline = true,
            tipCount = true,

            tokens = {[20560] = true, [20559] = true, [20558] = true},

            colorSlots = true,
            colorNormal = {r = 1, g = 1, b = 1},
            colorQuiver = {r = 1, g = 0.87, b = 0.68},
            colorSoul = {r = 0.64, g = 0.39, b = 1},
            colorEnchant = {r = 0.64, g = 0.83, b = 1},
            colorHerb = {r = 0.5, g = 1, b = 0.5},
            colorKeyring = {r = 1, g = 0.67, b = 0.95},
            emptyAlpha = 0.9,

            searches = {first = true},
        },
    }, true)

    self.db:RegisterCallback('OnProfileChanged', function()
        self:OnProfileChanged()
    end)

    -- clear old options
    do
        self.db.global.quickfix = nil
    end

    -- init search records
    do
        local searches = self.db.profile.searches
        if searches.first then
            searches.first = false

            local types = { --
                LE_ITEM_CLASS_WEAPON, --
                LE_ITEM_CLASS_ARMOR, --
                LE_ITEM_CLASS_CONSUMABLE, --
                LE_ITEM_CLASS_TRADEGOODS, --
                LE_ITEM_CLASS_REAGENT, --
            }

            for _, item in ipairs(types) do
                tinsert(searches, (GetItemClassInfo(item)))
            end
        end
    end

    self:SetupBankHider()
    self:SetupOptionFrame()
end

function Addon:OnEnable()
    if IsAddOnLoaded('tdPack2') then
        local tdPack2 = LibStub('AceAddon-3.0'):GetAddon('tdPack2')
        self:RegisterPluginButton({
            key = 'tdPack2',
            icon = [[Interface\AddOns\tdPack2\Resource\INV_Pet_Broom]],
            init = function(button, frame)
                tdPack2:SetupButton(button, frame.meta.bagId == BAG_ID.BANK)
            end,
        })
    end
end

function Addon:OnModuleCreated(module)
    ns[module:GetName()] = module
end

function Addon:OnClassCreated(class, name)
    local uiName = name:match('^UI%.(.+)$')
    if uiName then
        ns.UI[uiName] = class
        ns.Events:Embed(class)
    else
        ns[name] = class
    end
end

function Addon:OnProfileChanged()
    self:UpdateAllFrameMeta()
    self:UpdateAllManaged()
    self:UpdateAllPosition()
    self:UpdateAll()
end

function Addon:SetupBankHider()
    self.BankHider = CreateFrame('Frame')
    self.BankHider:Hide()

    BankFrame:UnregisterAllEvents()
    BankFrame:SetScript('OnShow', nil)
    BankFrame:SetParent(self.BankHider)
    BankFrame:ClearAllPoints()
    BankFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 0, 0)
    BankFrame:SetSize(1, 1)
end

function Addon:GetFrameProfile(bagId)
    return self.db.profile.frames[bagId]
end

function Addon:CreateFrame(bagId)
    local class = self.bagClasses[bagId]
    if not class then
        return
    end
    local frame = class:New(UIParent, bagId)
    self.frames[bagId] = frame
    return frame
end

function Addon:GetFrame(bagId)
    return self.frames[bagId]
end

function Addon:ShowFrame(bagId, manual)
    local frame = self:GetFrame(bagId) or self:CreateFrame(bagId)
    if frame and not frame:IsShown() then
        frame.manual = manual
        ShowUIPanel(frame)
    end
end

function Addon:HideFrame(bagId, manual)
    local frame = self:GetFrame(bagId)
    if frame and (manual or not frame.manual) then
        HideUIPanel(frame)
    end
end

function Addon:ToggleFrame(bagId, manual)
    local frame = self:GetFrame(bagId)
    if not frame or not frame:IsShown() then
        self:ShowFrame(bagId, manual)
    else
        self:HideFrame(bagId, manual)
    end
end

function Addon:ToggleOwnerFrame(bagId, owner)
    local frame = self:GetFrame(bagId) or self:CreateFrame(bagId)
    if not frame:IsShown() or frame.meta.owner ~= owner then
        self:ShowFrame(bagId, true)
        self:SetOwner(bagId, owner)
    else
        self:HideFrame(bagId, true)
    end
end

---- update

function Addon:UpdateAll()
    ns.Events:Fire('UPDATE_ALL')
end

function Addon:UpdateAllManaged()
    for _, frame in pairs(self.frames) do
        frame:UpdateManaged()
    end
end

function Addon:UpdateAllFrameMeta()
    for k, frame in pairs(self.frames) do
        frame.meta:Update()
    end
end

function Addon:UpdateAllPosition()
    for _, frame in pairs(self.frames) do
        frame:UpdatePosition()
    end
end

---- owner

function Addon:SetOwner(bagId, owner)
    if not bagId then
        self:SetOwner(BAG_ID.BAG, nil)
        self:SetOwner(BAG_ID.BANK, nil)
    else
        local frame = self:GetFrame(bagId)
        if frame then
            frame.meta.owner = owner
            ns.Events:FireFrameEvent('FRAME_OWNER_CHANGED', bagId)
        end
    end
end

---- focus bag

function Addon:FocusBag(bag)
    self.focusBag = bag
    ns.Events:Fire('BAG_FOCUS_UPDATED', bag)
end

function Addon:IsBagFocused(bag)
    return self.focusBag == bag
end

---- search

function Addon:SetSearch(text)
    if text and text:trim() == '' then
        text = nil
    end
    if self.searchText ~= text then
        self.searchText = text
        ns.Events:Fire('SEARCH_CHANGED')
    end
end

function Addon:GetSearch()
    return self.searchText
end

---- plugin buttons

---@return fun():number, tdBag2PluginOptions
function Addon:IteratePluginButtons()
    if self.pluginButtons then
        return ipairs(self.pluginButtons)
    else
        return nop
    end
end

---@class tdBag2PluginOptions
---@field icon number|string
---@field order number
---@field init function
---@field key string
---@field text  string

---@param opts tdBag2PluginOptions
function Addon:RegisterPluginButton(opts)
    self.pluginButtons = self.pluginButtons or {}

    opts.order = opts.order or #self.pluginButtons
    opts.text = opts.text or opts.key

    tinsert(self.pluginButtons, opts)
    sort(self.pluginButtons, function(a, b)
        return a.order < b.order
    end)

    if self.RefreshPluginOptions then
        self:RefreshPluginOptions()
    end
end
