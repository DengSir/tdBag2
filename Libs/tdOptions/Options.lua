-- Options.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/15/2024, 11:37:25 PM
--
local MAJOR, MINOR = 'tdOptions', 1
local Lib = LibStub:NewLibrary(MAJOR, MINOR)

if not Lib then
    return
end

Lib.panels = Lib.panels or {}

table.sort(Lib.panels)

local AceGUI = LibStub('AceGUI-3.0')
local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

function Lib:Register(name, opts)
    if not self.Frame then
        local Frame = AceGUI:Create('Frame')
        Frame:Hide()
        Frame:SetTitle('tdOptions')
        Frame:SetLayout('Fill')
        Frame:SetWidth(830)
        Frame:SetHeight(588)
        Frame:EnableResize(false)
        Frame:SetCallback('OnClose', function(widget)
            AceConfigDialog:Close(MAJOR)
            self.InlineGroup:ReleaseChildren()
        end)

        local TreeGroup = AceGUI:Create('TreeGroup')
        TreeGroup:SetLayout('Fill')
        TreeGroup:EnableButtonTooltips(false)
        TreeGroup:SetTreeWidth(false)
        TreeGroup:SetTree(self.panels)
        -- TreeGroup.treeframe:SetBackdrop()
        -- TreeGroup.border:SetBackdrop()
        -- TreeGroup.content:ClearAllPoints()
        -- TreeGroup.content:SetPoint('TOPLEFT', TreeGroup.border, 'TOPLEFT', 6, 0)
        -- TreeGroup.content:SetPoint('BOTTOMRIGHT', TreeGroup.border, 'BOTTOMRIGHT')
        -- print(TreeGroup.border)
        TreeGroup:SetCallback('OnGroupSelected', function(_, _, group)
            self.Label:SetText(C_AddOns.GetAddOnMetadata(group, 'Title'))
            self.Label:SetImage(C_AddOns.GetAddOnMetadata(group, 'IconTexture'))
            self.Version:SetText(C_AddOns.GetAddOnMetadata(group, 'Version'))
            -- self.Frame:SetStatusText(C_AddOns.GetAddOnMetadata(group, 'Notes'))
            AceConfigDialog:Open(group, self.InlineGroup)
        end)
        -- TreeGroup.border:SetBackdropColor(0, 0, 0, 0)
        -- TreeGroup.treeframe:SetBackdropColor(0, 0, 0, 0)

        local LockHighlight = function(button)
            button.Texture:SetAtlas('Options_List_Active')
            getmetatable(button).__index.LockHighlight(button)
        end

        local function UnlockHighlight(button)
            button.Texture:SetAtlas('Options_List_Hover')
            getmetatable(button).__index.UnlockHighlight(button)
        end

        local orig_TreeGroup_CreateButton = TreeGroup.CreateButton
        TreeGroup.CreateButton = function(self)
            local button = orig_TreeGroup_CreateButton(self)
            button:SetHeight(28)
            button.highlight:SetTexture()
            button.highlight:Hide()
            button.Texture = button:CreateTexture(nil, 'HIGHLIGHT')
            button.Texture:SetAllPoints(true)
            -- button.icon:SetSize(28, 28)
            button.LockHighlight = LockHighlight
            button.UnlockHighlight = UnlockHighlight
            return button
        end

        Frame:AddChild(TreeGroup)

        local ParentGroup = AceGUI:Create('SimpleGroup')
        ParentGroup:SetLayout('Flow')
        TreeGroup:AddChild(ParentGroup)

        local Label = AceGUI:Create('Label')
        Label:SetRelativeWidth(0.7)
        Label:SetFont(STANDARD_TEXT_FONT, 16, 'THINKOUTLINE')
        Label:SetColor(0.8, 1, 1)
        Label:SetImageSize(32, 32)
        Label:SetImage([[Interface\ICONS\UI_Chat]])
        Label:SetText('Placeholder')
        ParentGroup:AddChild(Label)

        local Version = AceGUI:Create('Label')
        Version:SetRelativeWidth(0.3)
        Version:SetFont(STANDARD_TEXT_FONT, 13, 'THINKOUTLINE')
        Version:SetColor(1, 0.8, 0.8)
        Version:SetJustifyH('RIGHT')
        Version:SetText('Placeholder')
        ParentGroup:AddChild(Version)

        local Heading = AceGUI:Create('Heading')
        Heading:SetFullWidth(true)
        ParentGroup:AddChild(Heading)

        local InlineGroup = AceGUI:Create('SimpleGroup')
        InlineGroup:SetLayout('Fill')
        InlineGroup:SetFullWidth(true)
        InlineGroup:SetFullHeight(true)
        ParentGroup:AddChild(InlineGroup)

        self.Frame = Frame
        self.TreeGroup = TreeGroup
        self.ParentGroup = ParentGroup
        self.Label = Label
        self.Version = Version
        self.InlineGroup = InlineGroup
    end

    AceConfigRegistry:RegisterOptionsTable(name, opts)
    AceConfigDialog:AddToBlizOptions(name, name)

    table.insert(self.panels, {value = name, text = C_AddOns.GetAddOnMetadata(name, 'Title')})
end

function Lib:Open(name, ...)
    AceConfigDialog:SelectGroup(name, ...)
    self.Frame:Show()
    self.TreeGroup:SelectByValue(name)
end
