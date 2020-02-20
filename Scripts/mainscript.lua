local ShowHideButton = mainForm:GetChildChecked( "Button", false)
local OptionsPanel = mainForm:GetChildChecked( "OptionsPanel", false)
local Header = OptionsPanel:GetChildChecked("HeaderText", false) 
local Container = OptionsPanel:GetChildChecked( "Container", false)
local ButtonAdd = OptionsPanel:GetChildChecked( "ButtonAdd", false)
local IsAOPanelEnabled = GetConfig( "EnableAOPanel" ) or GetConfig( "EnableAOPanel" ) == nil
ButtonAdd:SetVal("button_label", userMods.ToWString(GTL("Add new set")))
ShowHideButton:SetVal("button_label", userMods.ToWString("ART"))
Header:SetVal("name", GTL("Artefact Manager") )

local arts = {
[GTL("Pilgrim's Crown")] = true,
[GTL("Grail of Awakening")] = true,
[GTL("Dragon Aspis")] = true,
[GTL("Victory Cross")] = true,
[GTL("Freedom Mirror")] = true,
[GTL("Unity Triquetrum")] = true,
[GTL("Codex of Life")] = true,
}

local articon = {
[GTL("Freedom Mirror")] = "1",
[GTL("Unity Triquetrum")] = "2",
[GTL("Victory Cross")] = "3",
[GTL("Pilgrim's Crown")] = "4",
[GTL("Dragon Aspis")] = "5",
[GTL("Grail of Awakening")] = "6",
[GTL("Codex of Life")] = "7",
}

local artid = {}
local count = 3
local slot = 40
local ActiveSet = 0

local needequip = {}

function wtSetPlace(w, place )
	local p=w:GetPlacementPlain()
	for k, v in pairs(place) do	
		p[k]=place[k] or v
	end
	w:SetPlacementPlain(p)
end

function CreateWG(desc, name, parent, show, place)
	local n = mainForm:CreateWidgetByDesc( mainForm:GetChildChecked( desc, true ):GetWidgetDesc() )
	if name then n:SetName( name ) end
	if parent then parent:AddChild(n) end
	if place then wtSetPlace( n, place ) end
	n:Show( show == true )
	return n
end

function LogTable(t, tabstep)
    tabstep = tabstep or 1
    if t == nil then
        LogInfo("nil (no table)")
        return
    end
    assert(type(t) == "table", "Invalid data passed")
    local TabString = string.rep("    ", tabstep)
    local isEmpty = true
    for i, v in pairs(t) do
        if type(v) == "table" then
            LogInfo(TabString, i, ":")
            LogTable(v, tabstep + 1)
        else
            LogInfo(TabString, i, " = ", v)
        end
        isEmpty = false
    end
    if isEmpty then
        LogInfo(TabString, "{} (empty table)")
    end
end

function GetBagArts()
local tab = avatar.GetInventoryItemIds()
	for _, itemId in pairs( tab ) do
		local info = itemLib.GetItemInfo( itemId )
		if info and arts[userMods.FromWString(info.name)] then
			artid[userMods.FromWString(info.name)] = info.id
		end
	end
end

function GetEquipArts()
for i = 38, 40 do
	local art = avatar.GetContainerItem( i, 0 )
		if art and arts[userMods.FromWString(itemLib.GetItemInfo( art ).name)] then
			artid[userMods.FromWString(itemLib.GetItemInfo( art ).name)] = itemLib.GetItemInfo( art ).id
		end
	end
end

function Delay()
	mainForm:PlayFadeEffect( 1, 1, 300 , EA_SYMMETRIC_FLASH )
end

function CheckDelay(params)
if params.wtOwner:GetName() == common.GetAddonName() then
if needequip then
	avatar.EquipItemByIdToSlot( artid[needequip[ActiveSet][slot]], slot )
	count = count - 1
	slot = slot - 1
		if count > 0 then
		Delay()
		else
		slot = 40
		count = 3
			end
		end
	end
end

function GetMainConfig()
GetBagArts()
GetEquipArts()
if userMods.GetGlobalConfigSection("ArtSettings") then
	needequip = userMods.GetGlobalConfigSection("ArtSettings")
	else userMods.SetGlobalConfigSection("ArtSettings", needequip) end
end

function SlashCMD( params )
local text = userMods.FromWString(params.text)
if text == "/арт" then
	Delay()
    end
end

function ShowSettings()
if needequip then
	for k, v in pairs(needequip) do
		local wt = {}
		wt.itemslot = CreateWG("ItemPanel", "wtItemSlot", nil, true, {alignX=3, sizeX=192, posX=5, highPosX=25, alignY=3, sizeY=60, posY=0, highPosY=0,})
		wt.delete = wt.itemslot:GetChildChecked("ButtonDelete", false)
		wt.delete:SetName(tostring(k))
		wt.accept = wt.itemslot:GetChildChecked("ButtonAccept", false) 
		wt.accept:SetName(tostring(k))
		
		wt.slot38 = CreateWG("IconPanel", "38", wt.itemslot, true, {alignX=0, posX = 50, posY = 5})
		wt.slot39 = CreateWG("IconPanel", "39", wt.itemslot, true, {alignX=0, posX = 120, posY = 5})
		wt.slot40 = CreateWG("IconPanel", "40", wt.itemslot, true, {alignX=0, posX = 190, posY = 5})
		
		wt.slot38:SetBackgroundTexture( common.GetAddonRelatedTexture(articon[v[38]]))
		wt.slot39:SetBackgroundTexture( common.GetAddonRelatedTexture(articon[v[39]]))
		wt.slot40:SetBackgroundTexture( common.GetAddonRelatedTexture(articon[v[40]]))

		Container:PushFront(wt.itemslot)
		end
	end
end

function ShowHideMenu()
if DnD:IsDragging() then return	end
if OptionsPanel:IsVisible() then	
		OptionsPanel:Show(false)
		Container:RemoveItems()
	else
		OptionsPanel:Show(true)	
		ShowSettings()
	end  
end

function CloseMenu()
if OptionsPanel:IsVisible() then OptionsPanel:Show(false) Container:RemoveItems() end
end

function Accept(params)
	ActiveSet = tonumber(params.sender)
	Delay()
end

function Delete(params)
params.widget:GetParent():DestroyWidget()
needequip[tonumber(params.sender)] = nil
SaveOptions()
end

function Add(params)
needequip[GetTableSize(needequip)+1] = {
[38] = userMods.FromWString(itemLib.GetItemInfo( avatar.GetContainerItem( 38, 0 ) ).name), 
[39] = userMods.FromWString(itemLib.GetItemInfo( avatar.GetContainerItem( 39, 0 ) ).name),
[40] = userMods.FromWString(itemLib.GetItemInfo( avatar.GetContainerItem( 40, 0 ) ).name),
},
Container:RemoveItems()
ShowSettings()
SaveOptions()
end

function SaveOptions()
if needequip then
	userMods.SetGlobalConfigSection("ArtSettings", sorttablekeys(needequip))
	end
end

function sorttablekeys(table)
local newtab, i = {}, 0
for k, v in pairs(table) do
	i = i + 1
	newtab[i] = table[k]
end
	return newtab
end

function onAOPanelStart( params )
	if IsAOPanelEnabled then
		local SetVal = { val1 = userMods.ToWString("ART"), class1 = "LogColorRed" }
		local params = { header = SetVal, ptype = "button", size = 32 }
		userMods.SendEvent( "AOPANEL_SEND_ADDON", { name = common.GetAddonName(), sysName = common.GetAddonName(), param = params } )
		ShowHideButton:Show( false )
	end 
end

function OnAOPanelButtonLeftClick( params ) 
if params.sender == common.GetAddonName() then 
	if OptionsPanel:IsVisible() then	
			OptionsPanel:Show(false)
			Container:RemoveItems()
		else
			OptionsPanel:Show(true)	
			ShowSettings()
		end  
	end 
end

function onAOPanelChange( params )
	if params.unloading and params.name == "UserAddon/AOPanelMod" then
		ShowHideButton:Show( true )
	end
end

function enableAOPanelIntegration( enable )
	IsAOPanelEnabled = enable
	SetConfig( "EnableAOPanel", enable )
	if enable then
		onAOPanelStart()
	else
		ShowHideButton:Show( true )
	end
end

function Init()
	common.RegisterEventHandler( CheckDelay, "EVENT_EFFECT_FINISHED" )
	common.RegisterEventHandler( SlashCMD, "EVENT_UNKNOWN_SLASH_COMMAND" )
	common.RegisterReactionHandler( ShowHideMenu, "Button" ) 
	common.RegisterReactionHandler( Accept, "accept" ) 
	common.RegisterReactionHandler( Delete, "delete" ) 
	common.RegisterReactionHandler( Add, "add" ) 
	common.RegisterReactionHandler( CloseMenu, "cross_pressed" ) 
	common.RegisterEventHandler( onAOPanelStart, "AOPANEL_START" )
    common.RegisterEventHandler( OnAOPanelButtonLeftClick, "AOPANEL_BUTTON_LEFT_CLICK" )  
	common.RegisterEventHandler( onAOPanelChange, "EVENT_ADDON_LOAD_STATE_CHANGED" )
	GetMainConfig()
	DnD.Init(ShowHideButton, ShowHideButton, true)
	DnD.Init(OptionsPanel, OptionsPanel, true)
end

if (avatar.IsExist()) then Init()
else common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")	
end