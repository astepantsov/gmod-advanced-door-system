--Modern Graphical User Interface (MGUI)
--@01/09/2016
--Made by krekeris (http://steamcommunity.com/profiles/76561198079040229/)
--You're not allowed to use this without author's permission.




--[[ START: autorun/mgui_init.lua ]]--
mgui = mgui or {}
mgui.font = "Roboto"
mgui.version = "1.0"

mgui.theme = {
	helper = Color(37, 37, 38),
	helpert = Color(37, 37, 38, 150),
	main = Color(45, 45, 48),
	second = Color(0, 122, 204),
	list_bg = Color(70, 70, 80, 200),
	outline = Color(63, 63, 70)
} 

mgui.Colors = {
	["Blue"] = Color(33, 150, 243),
	["Orange"] = Color(255, 152, 0),
	["Green"] = Color(76, 175, 80),
	["LightGreen"] = Color(139, 195, 74),
	["DeepOrange"] = Color(255, 87, 34),
	["Red"] = Color(244, 67, 54),
	["Indigo"] = Color(63, 81, 181)
}

mgui.CreateFont = function(name, tbl)
	if tbl.bold then tbl.weight = 1000; tbl.bold = nil end
	tbl.font = tbl.font or mgui.font

	surface.CreateFont("mgui_" .. name, tbl)

	return "mgui_" .. name
end

mgui.error = function(str)
	MsgC(Color(255, 20, 20), "[modernGUI] error: ", str, "\n")
end

mgui.warning = function(str)
	MsgC(Color(250, 200, 0), "[modernGUI] warning: ", str, "\n")
end 

//if CLIENT then include("mgui/mgMap.lua")
//else AddCSLuaFile("mgui/mgMap.lua") end

local toReplace = {
	["<"] = "&lt;",
	[">"] = "&gt;",
	["&"] = "&amp;"
}

mgui.SafeString = function(str)
	local newStr, _ = str:gsub("[<>&%c]", function(m)
		return toReplace[m] or ""
	end)
	
	return newStr 
end

if CLIENT then
	hook.Add("Initialize", "mgui_stuff", function()
		local drawShadow = derma.GetDefaultSkin().tex.Shadow
 
		mgui.DrawShadow = function(x, y, w, h)
			DisableClipping(true)
			drawShadow(-4, -4, w + 10, h + 10)
			DisableClipping(false)
		end  
	end)
else
	resource.AddSingleFile("moderngui/error.png")
end

--[[ END: autorun/mgui_init.lua ]]--



if SERVER then return end



--[[ START: mgui/util.lua ]]--
local SetColor = surface.SetDrawColor
local SetMaterial = surface.SetMaterial

local DrawRect = surface.DrawRect
local DrawOutlinedRect = surface.DrawOutlinedRect
local DrawTexturedRect = surface.DrawTexturedRect
local DrawTexturedRectRotated = surface.DrawTexturedRectRotated

local GetTextSize = surface.GetTextSize
local SetFont = surface.SetFont

local DrawText = draw.SimpleText

local mError = Material("moderngui/error.png", "smooth")

file.CreateDir("mgui")
file.CreateDir("mgui/saved")

mgui.NullMaterial = mError
mgui.SetDrawColor = SetColor

mgui.GetTextSize = function(font, text)
    SetFont(font)
    return GetTextSize(text)
end

mgui.DownloadMaterial = function(url, params, callback)
    local crc = util.CRC(url)
    if file.Exists("mgui/saved/" .. crc .. ".png", "DATA") then
        callback(Material("../data/mgui/saved/" .. crc .. ".png", params))
        return
    end
    http.Fetch(url, function(body)
        file.Write("mgui/saved/" .. crc .. ".png", body)
        callback(Material("../data/mgui/saved/" .. crc .. ".png", params))
    end,
    function(err)
        mgui.error("error downloading material (" .. url .. "): " .. (err or "unknown error"))
        callback(mError)
    end)
end

mgui.CreateCirclePoly = function(x, y, radius, seg)
	local tbl = {}

	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		local aSin, aCos = math.sin(a), math.cos(a)

		tbl[i + 1] = {x = x + aSin * radius, y = y + aCos * radius, u = aSin / 2 + 0.5, v = aCos / 2 + 0.5}
	end

	return tbl
end

mgui.DrawPreMadeCircle = surface.DrawPoly

mgui.DrawCircle = function(x, y, radius, seg)
	surface.DrawPoly(mgui.CreateCirclePoly(x, y, radius, seg))
end

mgui.LerpColor = function(fr, from, to)
    from.a = from.a or 255
    to.a = to.a or 255

    return Color(
        Lerp(fr, from.r, to.r),
        Lerp(fr, from.g, to.g),
        Lerp(fr, from.b, to.b),
        Lerp(fr, from.a, to.a))
end

mgui.DrawRect = function(x, y, w, h, ...)
    if (...) then
        SetColor(...)
    end

    DrawRect(x, y, w, h)
end

mgui.DrawLine = function(startx, starty, endx, endy, ...)
    if (...) then
        surface.SetDrawColor(...)
    end

    surface.DrawLine(startx, starty, endx, endy)
end

mgui.DrawOutlinedRect = function(x, y, w, h, ...)
    if (...) then
        SetColor(...)
    end

    DrawOutlinedRect(x, y, w, h)
end

mgui.DrawTexturedRect = function(x, y, w, h, material, ...)
    if (...) then
        SetColor(...)
    else
        SetColor(255, 255, 255, 255)
    end

    SetMaterial(material)
    DrawTexturedRect(x, y, w, h)
end

mgui.DrawTexturedRectRotated = function(x, y, w, h, material, rotation, ...)
    if (...) then
        SetColor(...)
    else
        SetColor(255, 255, 255, 255)
    end

    SetMaterial(material)
    DrawTexturedRectRotated(x, y, w, h, rotation)
end

mgui.DrawText = function(text, font, x, y, color, align_x, align_y)
    local w, h = DrawText(text, font, x, y, color, align_x, align_y)

    if !w or !h then
        SetFont(font)
        w, h = GetTextSize(text)
    end

    return w, h
end

mgui.cosine = function(d, f, t)
    return t * Lerp(d, f / t, -math.cos(math.pi * t) / 2 + 0.5)
end
--[[ END: mgui/util.lua ]]--



--[[ START: mgui/mgFrame.lua ]]--
local PANEL = {}

local fontTitle = mgui.CreateFont("frame_title", {size = 16})
local newClr = mgui.theme.helpert
local outline = Color(0, 0, 0, 25)
local ui = mgui
local mClose = ui.NullMaterial

ui.DownloadMaterial("http://i.imgur.com/J8Fzrio.png", "smooth", function(m) mClose = m end)

function PANEL:Init()
    self.CloseButton = vgui.Create("DButton", self)
    self.CloseButton:SetSize(24, 24)
    self.CloseButton:SetText("")
    self.CloseButton.DoClick = function()
    	self:Remove()
	end
	self.CloseButton.Paint = function(self, w, h)
		ui.DrawTexturedRect(4, 4, w - 8, h - 8, mClose, 255, 0, 0, 150)
	end

    self.btnClose:Remove()
    self.btnMaxim:Remove()
    self.btnMinim:Remove()

    self.lblTitle:SetFont(fontTitle)
	self.lblTitle:SetColor(Color(190, 190, 190))
end

function PANEL:Paint(w, h)
	if ( self.m_bBackgroundBlur ) then
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
	end

	ui.DrawShadow(0, 0, w, h)
	
	ui.DrawRect(0, 0, w, h, ui.theme.main)
	ui.DrawRect(0, 0, w, 25, newClr)

	// outline
	ui.DrawOutlinedRect(0, 0, w, h, ui.theme.outline)
	ui.DrawOutlinedRect(1, 26, w - 2, h - 27, outline)
	ui.DrawRect(0, 25, w, 1, ui.theme.outline)

	if self.DrawOver then self:DrawOver(w, h) end
end

function PANEL:PerformLayout()
    self.CloseButton:SetPos(self:GetWide() - 25, 1)
    self.lblTitle:SetPos(8, 3)
	self.lblTitle:SetSize(self:GetWide() - 25, 20)
end

vgui.Register("mgFrame", PANEL, "DFrame")
--[[ END: mgui/mgFrame.lua ]]--



--[[ START: mgui/mgHorizontalTabs.lua ]]--
local PANEL = {}

local ui = mgui
local fontTab = ui.CreateFont("tab_text", {size = 18})

function PANEL:Init()
	self.Tabs = {}
end

function PANEL:LayoutButtons()
	local count = #self.Tabs
	local bw, bh = math.floor(self.FixedWidth and self.FixedWidth or self:GetWide() / count), self:GetTall()

	for k, v in ipairs(self.Tabs) do
		v:SetPos(bw * (k - 1), 0)
		v:SetSize(bw, bh)
	end
end

function PANEL:SetFixedWidth(w)
	self.FixedWidth = w
end

function PANEL:SetSelected(pnl)
	for k, v in ipairs(self.Tabs) do
		if v != pnl then
			v.Selected = false
			if v.Child then v.Child:SetVisible(false) end
		else
			v.Selected = true
			if v.Child then v.Child:SetVisible(true) end
		end
	end
end

function PANEL:TabChange() end

function PANEL:AddTab(name, icon, child)
	local pnl = self
	local b = vgui.Create("DButton", self)
	b.Name = name
	b.Icon = icon
	b.Child = child
	if child then child:SetVisible(false) end
	b.DoClick = function(self)
		pnl:TabChange(name, child)
		pnl:SetSelected(self)
	end
	b.alpha = 0
	b.salpha = 0
	b:SetText("")
	b.Order = table.insert(self.Tabs, b)
	b.Paint = function(self, w, h)
		if self.Order != #pnl.Tabs then
			ui.DrawRect(w - 1, 0, 1, h, 255, 255, 255, 20)
			w = w - 1
		end

		local toAlpha = (self.Depressed and 60) or (self.Hovered and 30) or 0
		self.alpha = Lerp(FrameTime() * 4, self.alpha, toAlpha)
		self.salpha = Lerp(FrameTime() * 3, self.salpha, self.Selected and 150 or 0)

		ui.DrawRect(0, 0, w, h, 255, 255, 255, self.alpha)
		ui.DrawText(self.Name, fontTab, (self.Icon and 8 or 0) + w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		ui.DrawRect(0, h - 2, w, 2, 0, 122, 204, self.salpha)
		if self.Icon then
			ui.DrawTexturedRect(8, h / 2 - 8, 16, 16, self.Icon, 255, 255, 255, 200)
		end

		if self.DrawOver then self:DrawOver(w, h) end
	end
	self:LayoutButtons()

	return b
end

function PANEL:Paint(w, h)
	ui.DrawRect(0, 0, w, h, ui.theme.list_bg)
end

vgui.Register("mgHorizontalTabs", PANEL, "DPanel")
--[[ END: mgui/mgHorizontalTabs.lua ]]--



--[[ START: mgui/mgVerticalTabs.lua ]]--
local PANEL = {}

local ui = mgui

function PANEL:Init()
	self.Tabs = {}
end

function PANEL:LayoutButtons()
	local count = #self.Tabs
	local bw, bh = 0, 0

	if self.Stretch then
		bw, bh = self:GetWide(), self.FixedHeight and self.FixedHeight or 40

		self:SetTall(bh * count + 30)
	else
		bw, bh = self:GetWide(), self.FixedHeight and self.FixedHeight or math.floor((self:GetTall() - 30) / count)
	end

	for k, v in ipairs(self.Tabs) do
		v:SetPos(0, 30 + bh * (k - 1))
		v:SetSize(bw, bh)
	end
end

function PANEL:SetFixedHeight(h)
	self.FixedHeight = h
end

function PANEL:SetStretch(b)
	self.Stretch = b
end

function PANEL:SetSelected(pnl)
	for k, v in ipairs(self.Tabs) do
		if v != pnl then
			v.Selected = false
			if v.Child then v.Child:SetVisible(false) end
		else
			v.Selected = true
			if v.Child then v.Child:SetVisible(true) end
		end
	end
end

function PANEL:TabChange() end

function PANEL:AddTab(name, icon, child)
	local pnl = self
	local b = vgui.Create("DButton", self)
	b.Order = table.insert(self.Tabs, b)
	b.Name = name
	b.Icon = icon
	b.alpha = 0
	b.salpha = 0
	b:SetText("")
	b.Child = child
	if child then child:SetVisible(false) end
	b.DoClick = function(self)
		pnl:TabChange(name, child)
		pnl:SetSelected(self)
		self._pressed = CurTime()
		self._mousex, self._mousey = self:LocalCursorPos()
	end
	b.Paint = function(self, w, h)
		local last = self.Order == #pnl.Tabs
		if !last then
			ui.DrawRect(0, 0, w, h, ui.theme.list_bg)
			if self.Depressed then ui.DrawRect(0, 0, w, h, 100, 100, 100, 20)
			elseif self.Hovered then ui.DrawRect(0, 0, w, h, 100, 100, 100, 15) end
			ui.DrawRect(0, h - 1, w, 1, 255, 255, 255, 5)
			if self.Selected then ui.DrawRect(w - 2, 0, 2, h, ui.theme.second) end
		else
			draw.RoundedBoxEx(8, 0, 0, w, h, ui.theme.list_bg, false, false, true, true)
			if self.Depressed then draw.RoundedBoxEx(8, 0, 0, w, h, Color(100, 100, 100, 20), false, false, true, true)
			elseif self.Hovered then draw.RoundedBoxEx(8, 0, 0, w, h, Color(100, 100, 100, 15), false, false, true, true) end
			if self.Selected then ui.DrawRect(w - 2, 0, 2, h - 4, ui.theme.second) end
		end

		ui.DrawText(self.Name, "mgui_tab_text", self.Icon and 32 or 8, h / 2 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		if self.Icon then
			ui.DrawTexturedRect(8, h / 2 - 8, 16, 16, self.Icon, 255, 255, 255, 200)
		end

		if self._pressed then
			local fraction = (self._pressed + 0.5 - CurTime()) / 0.5
			local size = w * (1 - fraction)

			if fraction <= 0 then self._pressed = nil; return end

			surface.SetDrawColor(255, 255, 255, 60 * fraction)
			draw.NoTexture()
			//DisableClipping(true)
			ui.DrawCircle(self._mousex, self._mousey, size, 60)
			//DisableClipping(false)
		end

		if self.DrawOver then self:DrawOver(w, h) end
	end
	self:LayoutButtons()
end

function PANEL:SetTitle(txt)
	self.Title = txt
end

function PANEL:Paint(w, h)
	draw.RoundedBoxEx(8, 0, 0, w, 30, Color(16, 169, 172), true, true)
	ui.DrawText(self.Title, "mgui_tab_text", w / 2, 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end 

vgui.Register("mgVerticalTabs", PANEL, "DPanel")
--[[ END: mgui/mgVerticalTabs.lua ]]--



--[[ START: mgui/mgTextEntry.lua ]]--
local PANEL = {}

local ui = mgui
local textCol, hlCol, cursorCol = Color(60, 60, 60), Color(150, 150, 150), Color(60, 60, 60)
local bg, bgActive, bgDisabled = Color(250, 250, 250), Color(250, 250, 210), Color(220, 220, 220)

ui.CreateFont("textentry_italic", {font = "Arial", size = 14, italic = true})

function PANEL:SetGhostText(txt)
	self.strGhostText = txt
end

function PANEL:Paint(w, h)
	local focus = self:HasFocus()
	ui.DrawRect(0, 0, w, h, (self:GetDisabled() and bgDisabled) or (focus and bgActive) or bg)
	self:DrawTextEntryText(textCol, hlCol, cursorCol)
	if !focus and self:GetValue() == "" and self.strGhostText then ui.DrawText(self.strGhostText, "mgui_textentry_italic", 5, h / 2, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
	ui.DrawOutlinedRect(0, 0, w, h, focus and ui.theme.second or ui.theme.list_bg)
end

vgui.Register("mgTextEntry", PANEL, "DTextEntry")
--[[ END: mgui/mgTextEntry.lua ]]--



--[[ START: mgui/mgPanel.lua ]]--
local PANEL = {}

local ui = mgui

function PANEL:SetShadow(b)
	self.b_DrawShadow = b
end

function PANEL:Paint(w, h)
	if self.b_DrawShadow then mgui.DrawShadow(0, 0, w, h) end
	ui.DrawRect(0, 0, w, h, 70, 70, 80, 50)
end

vgui.Register("mgPanel", PANEL, "DPanel")
--[[ END: mgui/mgPanel.lua ]]--



--[[ START: mgui/mgNotifications.lua ]]--
local pnl
local ui = mgui
local queue = {}

mgui.Notify = function(text, duration, text_clr, priority)
	if !text or text == "" then
		mgui.warning("@mgui.Notify: text argument isn't specified, ignoring the message")
		return
	end
	if IsValid(pnl) then table.insert(queue, priority and 1 or #queue + 1, {text, duration, text_clr}) return end
	duration = duration or 5
	local clr = text_clr and (text_clr.r .. ", " .. text_clr.g .. ", " .. text_clr.b .. ", " .. text_clr.a or 255) or "250, 250, 250, 255"
	local objMarkup = markup.Parse("<font=mgui_tab_text><colour=" .. clr .. ">" .. text .. "</colour></font>", ScrW() - 20)
	local height = objMarkup:GetHeight() + 12
	local ypos = ScrH() - height

	pnl = vgui.Create("DPanel")
	pnl:SetSize(ScrW(), height)
	pnl:SetPos(0, ScrH())
	pnl.DieTime = CurTime() + duration
	pnl.BodyFraction = 0
	pnl.OnRemove = function()
		timer.Simple(0.1, function()
			if queue[1] then
				mgui.Notify(unpack(queue[1]))
				table.remove(queue, 1)
			end
		end)
	end
	pnl.Paint = function(self, w, h)
		ui.DrawShadow(0, 0, w, h)
		local mAlpha = !self.dies and 255 * self.BodyFraction or (255 - 255 * self.BodyFraction)
		ui.DrawRect(0, 3, w, h - 3, 45, 45, 48, mAlpha)
		ui.DrawRect(0, 2, w, 1, 63, 63, 70, mAlpha)
		ui.DrawRect(0, 1, w * ((self.DieTime - CurTime() - 0.3) / (duration - 0.3)), 1, 0, 122, 204, 200)
		//ui.DrawTexturedRect(0, -6, w, 8, mgui.Shadow.top, 255, 255, 255)
		objMarkup:Draw(w / 2, h / 2 + 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	pnl.Think = function(self)
		if self.Anim:Active() then
			self.Anim:Run()
		end
		if !self.dies then
			self:SetPos(0, ScrH() - self.BodyFraction * height)
		else
			self:SetPos(0, ScrH() - height + self.BodyFraction * height)
		end
		self:SetDrawOnTop(true)
		if self.DieTime - 0.3 <= CurTime() and !self.dies then
			self.dies = true
			self.Anim:Start(0.3)
		elseif self.DieTime <= CurTime() then
			pnl:Remove()
		end
	end
	pnl.Anim = Derma_Anim("mgui_show",pnl, function(pnl, _, fr)
		pnl.BodyFraction = fr
	end)
	pnl.Anim:Start(0.3)
end
--[[ END: mgui/mgNotifications.lua ]]--



--[[ START: mgui/mgComboBox.lua ]]--
local PANEL = {}

local ui = mgui


function PANEL:Paint(w, h)
	ui.DrawRect(0, 0, w, h, 240, 240, 240)
	ui.DrawOutlinedRect(0, 0, w, h, ui.theme.list_bg)
end

vgui.Register("mgComboBox", PANEL, "DComboBox") 
--[[ END: mgui/mgComboBox.lua ]]--



--[[ START: mgui/mgButton.lua ]]--
local PANEL = {}

local ui = mgui
local font = mgui.CreateFont("button_text", {size = 16})

function PANEL:Init()
	self.clrMain = Color(0, 122, 204, 220)
	self.alpha = 0
	self._font = font
	self:SetText("")
	self.SetText = function(self, str)
		self.strText = str
	end
	self.GetText = function(self)
		return self.strText or ""
	end
end

function PANEL:SetColor(clr)
	self.clrMain = clr
end

function PANEL:GetColor()
	return self.clrMain
end

function PANEL:SetFont(font)
	self._font = font
end

function PANEL:Paint(w, h)
	ui.DrawText(self:GetText(), self._font, w / 2, h / 2 - 1, self.clrMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	ui.DrawOutlinedRect(0, 0, w, h, self.clrMain)
	//ui.DrawOutlinedRect(1, 1, w - 2, h - 2, self.clrMain)

	local toalpha = 0
	if self.Depressed then toalpha = 8
	elseif self.Hovered then toalpha = 5 end

	self.alpha = Lerp(FrameTime() * 4, self.alpha, toalpha)

	ui.DrawRect(1, 1, w - 2, h - 2, 255, 255, 255, self.alpha)

	if self.DrawOver then self:DrawOver(w, h) end
end


vgui.Register("mgButton", PANEL, "DButton")
--[[ END: mgui/mgButton.lua ]]--



--[[ START: mgui/mgTextButton.lua ]]--
local PANEL = {}

local ui = mgui

function PANEL:Init()
	self.clrMain = ui.theme.second
	self.white = 0
	self:SetText("")
	self.SetText = function(self, str)
		self.strText = str
	end
	self.GetText = function(self)
		return self.strText or ""
	end
end

function PANEL:SetColor(clr)
	self.clrMain = clr
end

function PANEL:GetColor()
	return self.clrMain
end

function PANEL:Paint(w, h)
	ui.DrawText(self:GetText(), "mgui_button_text", 0, h / 2 - 1, Color(self.clrMain.r + self.white, self.clrMain.g + self.white, self.clrMain.b + self.white), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local towhite = 0
	if self.Depressed then towhite = 30
	elseif self.Hovered then towhite = 20 end

	self.white = towhite
end


vgui.Register("mgTextButton", PANEL, "DButton")
--[[ END: mgui/mgTextButton.lua ]]--



--[[ START: mgui/mgScrollPanel.lua ]]--
// Copied from Garry's Mod files with some small changes.

--[[   _                                
	( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

--]]
local PANEL = {}

AccessorFunc( PANEL, "Padding", 	"Padding" )
AccessorFunc( PANEL, "pnlCanvas", 	"Canvas" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.pnlCanvas 	= vgui.Create( "Panel", self )
	self.pnlCanvas.OnMousePressed = function( self, code ) self:GetParent():OnMousePressed( code ) end
	self.pnlCanvas:SetMouseInputEnabled( true )
	self.pnlCanvas.PerformLayout = function( pnl )
	
		self:PerformLayout()
		self:InvalidateParent()
	
	end
	
	-- Create the scroll bar
	self.VBar = vgui.Create( "mgVScrollBar", self )
	self.VBar:Dock( RIGHT )

	self:SetPadding( 0 )
	self:SetMouseInputEnabled( true )
	
	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackground( false )

end

--[[---------------------------------------------------------
   Name: AddItem
-----------------------------------------------------------]]
function PANEL:AddItem( pnl )

	pnl:SetParent( self:GetCanvas() )
	
end

function PANEL:OnChildAdded( child )

	self:AddItem( child )

end

--[[---------------------------------------------------------
   Name: SizeToContents
-----------------------------------------------------------]]
function PANEL:SizeToContents()

	self:SetSize( self.pnlCanvas:GetSize() )
	
end

--[[---------------------------------------------------------
   Name: GetVBar
-----------------------------------------------------------]]
function PANEL:GetVBar()

	return self.VBar
	
end

--[[---------------------------------------------------------
   Name: GetCanvas
-----------------------------------------------------------]]
function PANEL:GetCanvas()

	return self.pnlCanvas

end

function PANEL:InnerWidth()

	return self:GetCanvas():GetWide()

end

--[[---------------------------------------------------------
   Name: Rebuild
-----------------------------------------------------------]]
function PANEL:Rebuild()

	self:GetCanvas():SizeToChildren( false, true )
		
	-- Although this behaviour isn't exactly implied, center vertically too
	if ( self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall() ) then

		self:GetCanvas():SetPos( 0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5 )
	
	end
	
end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:OnMouseWheeled( dlta )

	return self.VBar:OnMouseWheeled( dlta )
	
end

--[[---------------------------------------------------------
   Name: OnVScroll
-----------------------------------------------------------]]
function PANEL:OnVScroll( iOffset )

	self.pnlCanvas:SetPos( 0, iOffset )
	
end

--[[---------------------------------------------------------
   Name: ScrollToChild
-----------------------------------------------------------]]
function PANEL:ScrollToChild( panel )

	self:PerformLayout()
	
	local x, y = self.pnlCanvas:GetChildPosition( panel )
	local w, h = panel:GetSize()
	
	y = y + h * 0.5;
	y = y - self:GetTall() * 0.5;

	self.VBar:AnimateTo( y, 0.5, 0, 0.5 );
	
end


--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	local Wide = self:GetWide()
	local YPos = 0
	
	self:Rebuild()
	
	self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
	YPos = self.VBar:GetOffset()
		
	if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )
	
	self:Rebuild()


end

function PANEL:Clear()

	return self.pnlCanvas:Clear()

end


derma.DefineControl( "mgScrollPanel", "", PANEL, "DPanel" )

--[[ END: mgui/mgScrollPanel.lua ]]--



--[[ START: mgui/mgVScrollBar.lua ]]--
local PANEL = {}
local ui = mgui
local mGrip = ui.NullMaterial

ui.DownloadMaterial("http://i.imgur.com/06tvlxM.png", "vertexlitgeneric", function(m) mGrip = m end)

function PANEL:Init()
	local normal, hovered = Color(75, 75, 81), Color(79, 79, 84)
	self.btnGrip.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, self.Hovered and hovered or normal)

		local center = h / 2
		for i = 1, 3 do
			ui.DrawRect(3, center + ((i == 2 and 2) or (i == 3 and - 2) or 0), w - 6, 1, 255, 255, 255, 100)
		end
	end

	self.btnUp.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, ui.theme.list_bg)
	end

	self.btnUp.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, ui.theme.list_bg)
	end

	self.btnUp:Remove()
	self.btnDown:Remove()
	self:SetShadow(true)
end

function PANEL:Paint(w, h)
	if self.b_Shadow then ui.DrawShadow(0, 0, w, h) end
	ui.DrawRect(0, 0, w, h, 70, 70, 80, 100)
end

function PANEL:SetShadow(b)
	self.b_Shadow = b
end

function PANEL:OnCursorMoved( x, y )

	if ( !self.Enabled ) then return end
	if ( !self.Dragging ) then return end

	local x = 0
	local y = gui.MouseY()
	local x, y = self:ScreenToLocal( x, y )
	
	-- Uck. 
	y = y - self.HoldPos
	
	local TrackSize = self:GetTall() - self.btnGrip:GetTall()
	
	y = y / TrackSize
	
	self:SetScroll( y * self.CanvasSize )	
	
end

function PANEL:PerformLayout()
	local Wide = self:GetWide()
	local Scroll = self:GetScroll() / self.CanvasSize
	local BarSize = math.max(self:BarScale() * self:GetTall(), 10)
	local Track = self:GetTall() - BarSize
	Track = Track + 1
	
	Scroll = Scroll * Track
	
	self.btnGrip:SetPos(0, Scroll)
	self.btnGrip:SetSize(Wide, BarSize)
end

vgui.Register("mgVScrollBar", PANEL, "DVScrollBar")
--[[ END: mgui/mgVScrollBar.lua ]]--



--[[ START: mgui/mgSlider.lua ]]--
local PANEL = {}
local ui = mgui
local smat = ui.NullMaterial
local font = ui.CreateFont("slider_text", {size = 14})
local meta = FindMetaTable("Panel")

ui.DownloadMaterial("http://i.imgur.com/ztmVewi.png", "smooth", function(m) smat = m end)

local function KnobPaint(pnl, w, h)
	if pnl.Depressed then
		ui.DrawTexturedRect(-1, -1, w + 2, h + 2, smat, pnl._color)
	else
		ui.DrawTexturedRect(0, 0, w, h, smat, pnl._color)
	end
end

function PANEL:Paint(w, h)
	if !self.strText and !self.bShowAmount then return end

	local text = self.strText
	if !text and self.bShowAmount then 
		text = math.Round(self:GetValue())
	elseif self.bShowAmount then
		text = text .. " (" .. math.Round(self:GetValue()) .. ")"
	end

	ui.DrawText(text, font, 0, 0, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function PANEL:SetText(str)
	self.strText = str
end

function PANEL:ShowAmount(bool)
	self.bShowAmount = bool
end

local SLIDER = {}

function SLIDER:Paint(w, h)
	local fr = self:GetSlideX()

	ui.DrawRect(0, 6, w, 3, mgui.theme.list_bg)
	ui.DrawRect(0, 6, w * fr, 3, self._color)
end

PANEL.GetFloat = function(self)
	return self.Slider:GetSlideX()
end

function PANEL:SetMin(value)
	self.Slider.fMinValue = value
end

function PANEL:SetMax(value)
	self.Slider.fMaxValue = value
end

function PANEL:SetMinMax(min, max)
	self.Slider.fMinValue = min
	self.Slider.fMaxValue = max
end

function PANEL:GetValue()
	local min, max = self.Slider.fMinValue or 0, self.Slider.fMaxValue or 100
	
	return (max - min) * self:GetFloat() + min
end

function PANEL:SetValue(v)
	local min, max = self.Slider.fMinValue or 0, self.Slider.fMaxValue or 100
	local values = max - min
	self:SetSlideX(v / values)
end

function PANEL:Init()
	self:SetSize(200, 30)
	self._color = Color(0, 200, 200)

	local slider = vgui.Create("DSlider", self)
	slider:SetPos(0, 15)
	slider:SetSize(200, 15)
	slider._color = self._color

	local setWide = self.SetWide

	self.SetWide = function(self, ...)
		self.Slider:SetWide(...)
		setWide(self, ...)
	end

	for k, v in pairs(SLIDER) do
		slider[k] = v
	end

	for k, v in pairs(DSlider) do
		if !self[k] then
			if isfunction(v) then
				self[k] = function(self, ...)
					return slider[k](slider, ...)
				end
			else
				self[k] = v
			end
		end
	end

	slider.Knob.Paint = KnobPaint
	slider.Knob._color = self._color

	self.Slider = slider
end

derma.DefineControl("mgSlider", "", PANEL, "Panel")

--[[ END: mgui/mgSlider.lua ]]--



--[[ START: mgui/mgDialogs.lua ]]--
local dialogs = {}
local confirmFont = mgui.CreateFont("confirm_dialog", {size = 24})

local function CreateDialogFrame(title)
	DIALOG_FRAME = vgui.Create("mgFrame")
	DIALOG_FRAME:SetSize(400, 100)
	DIALOG_FRAME:Center()
	DIALOG_FRAME:MakePopup()
	DIALOG_FRAME:DoModal(true)
	DIALOG_FRAME:SetBackgroundBlur(true)
	DIALOG_FRAME:SetTitle(title)
	DIALOG_FRAME.Callback = function() end
	DIALOG_FRAME.CreateButton = function(self)
		self:SetTall(self:GetTall() + 30)
		self.btn = vgui.Create("mgButton", self)
		self.btn:SetPos(5, self:GetTall() - 30)
		self.btn:SetSize(self:GetWide() - 10, 25)
		self.btn:SetText("OK")
		self.btn.DoClick = function()
			self:Callback()
			self:Remove()
		end
	end
	DIALOG_FRAME.setTall = DIALOG_FRAME.SetTall

	DIALOG_FRAME.SetTall = function(self, ...)
		self:setTall(...)
		self:Center()
	end
end

dialogs.string = function(callback, ghost, default)
	local entry = vgui.Create("mgTextEntry", DIALOG_FRAME)
	entry:SetPos(5, 30)
	entry:SetSize(DIALOG_FRAME:GetWide() - 10, 25)
	entry:SetGhostText(ghost)
	if default then entry:SetValue(default) end

	DIALOG_FRAME:SetTall(60)
	DIALOG_FRAME.entry = entry
	DIALOG_FRAME.Callback = function()
		callback(entry:GetValue() or "")
	end
end

dialogs.slider = function(callback, min, max, default)
	local slider = vgui.Create("mgSlider", DIALOG_FRAME)
	slider:ShowValue(true)
	local ypos = 30 + slider:GetOffset()
	slider:SetPos(5, ypos)
	slider:SetWide(DIALOG_FRAME:GetWide() - 10)
	slider:SetMinMax(min or 0, max or 100)
	if default then entry:SetValue(default) end

	DIALOG_FRAME:SetTall(ypos + slider:GetTall() + 5)
	DIALOG_FRAME.slider = slider

	DIALOG_FRAME.Callback = function()
		callback(slider:GetValue() or 0)
	end
end

dialogs.color = function(callback, def)
	DIALOG_FRAME:SetTall(300)

	local mixer = vgui.Create("DColorMixer", DIALOG_FRAME)
	mixer:SetPos(5, 45)
	mixer:SetSize(DIALOG_FRAME:GetWide() - 10, DIALOG_FRAME:GetTall() - 50)
	if def then mixer:SetColor(def) end

	DIALOG_FRAME.DrawOver = function(self, w, h)
		mgui.DrawRect(5, 30, w - 10, 10, color_white)
		mgui.DrawRect(5, 30, w - 10, 10, mixer:GetColor())
		mgui.DrawOutlinedRect(5, 30, w - 10, 10, mgui.theme.outline)
	end

	DIALOG_FRAME.Callback = function()
		callback(mixer:GetColor() or color_white)
	end
	DIALOG_FRAME.mixer = mixer
end

dialogs.confirm = function(callback, confirm_btn, cancel_btn)
	local btnsize = (DIALOG_FRAME:GetWide() - 15) / 2

	local cancel = vgui.Create("mgButton", DIALOG_FRAME)
	cancel:SetSize(btnsize, 25)
	cancel:SetPos(5, 30)
	cancel:SetText(cancel_btn or "No")
	cancel:SetColor(mgui.Colors.Red)
	cancel.DoClick = function() DIALOG_FRAME:Remove() end

	local conf = vgui.Create("mgButton", DIALOG_FRAME)
	conf:SetSize(btnsize, 25)
	conf:SetPos(10 + btnsize, 30)
	conf:SetText(confirm_btn or "Yes")
	conf:SetColor(mgui.Colors.Green)
	conf.DoClick = function() callback(); DIALOG_FRAME:Remove() end

	DIALOG_FRAME:SetTall(60)
	
	return true 
end

mgui.ShowDialog = function(type, title, ...)
	if IsValid(DIALOG_FRAME) then return end

	CreateDialogFrame(title or "")
	local btns = dialogs[type](...)
	if !btns then DIALOG_FRAME:CreateButton() end

	return DIALOG_FRAME
end
--[[ END: mgui/mgDialogs.lua ]]--



--[[ START: mgui/mgStatusLabel.lua ]]--
local PANEL = {}
PANEL.CreatedFonts = {}
PANEL.Colors = {
	default = Color(153, 153, 153), // grey
	primary = Color(66, 139, 202), // blue
	success = Color(92, 184, 92), // green
	info = Color(91, 192, 222), // light blue
	warning = Color(240, 173, 78, 220), // orange
	danger = Color(217, 83, 79) // red
}
local font = mgui.CreateFont("status_label", {font = "Arial", size = 14})

function PANEL:SetType(t)
	self._color = self.Colors[t] or self.Colors.default
	self._type = t
end

function PANEL:GetType()
	return self._type
end

function PANEL:Init()
	self._sizetocontents = true
	self._text = "default"
	self:SetType("default")
	self:SetSize(60, 18)
end

function PANEL:SizeToContents(b)
	self._sizetocontents = b
end

function PANEL:SetText(str)
	self._text = str
end

function PANEL:GetText()
	return self._text or ""
end

function PANEL:SetFunction(func)
	if !func then
		self:SetCursor("arrow")
		self._function = nil
		return
	end

	self._function = func
	self:SetCursor("hand")
end

function PANEL:OnMousePressed(key)
	if self._function and key == MOUSE_LEFT then
		self._function()
	end
end

function PANEL:Paint(w, h)
	DisableClipping(true)
	draw.RoundedBox(4, 1, 1, w, h, Color(0, 0, 0, 100))
	DisableClipping(false)
	draw.RoundedBox(4, 0, 0, w, h, self._color)
	mgui.DrawText(self._text, font, w / 2 + 1, h / 2, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	local textw, _ = mgui.DrawText(self._text, font, w / 2, h / 2 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if self._function and self.Hovered then
		mgui.DrawText(self._text, font, w / 2, h / 2 - 1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	if self._sizetocontents then
		self:SetWide(textw + 10)
		self._sizetocontents = nil
	end
end 

vgui.Register("mgStatusLabel", PANEL, "DPanel")
--[[ END: mgui/mgStatusLabel.lua ]]--



--[[ START: mgui/mgSoundPlayer.lua ]]--
local PANEL = {}

local mPlay = mgui.NullMaterial
mgui.DownloadMaterial("http://i.imgur.com/mFinAP5.png", "smooth", function(m) mPlay = m end)
local mPause = mgui.NullMaterial
mgui.DownloadMaterial("http://i.imgur.com/Qk7ljfF.png", "smooth", function(m) mPause = m end)
local font = mgui.CreateFont("soundplayer", {size = 12})

function PANEL:PerformLayout()
	local w, h = self:GetSize()
	self.play:SetPos(5, 5)
	self.play:SetSize(h - 10, h - 10)
	self.bar:SetPos(h, h - 11)
	self.bar:SetSize(w - 5 - h, 6)
end

function PANEL:LoadFromURL(url)
	sound.PlayURL(url, "noplay noblock", function(chan, errid, err)
		if chan then
			self.stream = chan
		else
			mgui.warning("error downloading sound [" .. errid .. "]: " .. err)
		end
	end)
end

function PANEL:OnRemove()
	if self.stream then
		self.stream:Stop()
	end
end

function PANEL:Paint(w, h)
	if self.stream then
		self.time, self.len, self.name = self.stream:GetTime(), self.stream:GetLength(), self.stream:GetFileName()
		self.fraction = self.time / self.len
	end

	mgui.DrawShadow(0, 0, w, h)
	mgui.DrawRect(0, 0, w, h, mgui.theme.list_bg)
	mgui.DrawText(self.name, font, h, 4, Color(255, 255, 255, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	mgui.DrawText(string.ToMinutesSeconds(self.time) .. "/" .. string.ToMinutesSeconds(self.len), font, w - 5, 5, Color(255, 255, 255, 230), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

function PANEL:Init()
	self.isplaying = false
	self.fraction, self.len, self.name, self.time = 0, 0, "Loading...", 0

	self.play = vgui.Create("DButton", self)
	self.play:SetText("")
	self.play._mat = mPlay
	self.play.Think = function(pnl)
		pnl:SetDisabled(self.stream == nil)
		if self.stream then
			if self.isplaying then
				pnl._mat = mPause
			else
				pnl._mat = mPlay
			end
		end
	end
	self.play.Paint = function(self, w, h)
		mgui.DrawTexturedRect(0, 0, w, h, self._mat, 255, 255, 255, 100)
	end
	self.play.DoClick = function()
		if self.isplaying then
			self.stream:Pause()
			self.isplaying = false
		else
			self.stream:Play()
			self.isplaying = true
		end
	end

	self.bar = vgui.Create("DPanel", self)
	self.bar.Paint = function(pnl, w, h)
		mgui.DrawRect(0, 0, w, h, 40, 40, 50, 200)
		mgui.DrawRect(0, 0, w * self.fraction, h, 33, 150, 243, 150)

		if pnl.Hovered then
			local x, y = pnl:LocalCursorPos()
			local fr = x / w
			local time = string.ToMinutesSeconds(self.len * fr)
			
			DisableClipping(true)
				local textw, texth = mgui.GetTextSize(font, time)
				local tw, th = textw + 10, texth + 4
				local xp, yp = math.Clamp(x - tw / 2, 0, w - tw), -th - 2
				draw.RoundedBox(4, xp, yp, tw, th, Color(40, 40, 50, 255))
				mgui.DrawText(time, font, xp + tw / 2, yp + th / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			DisableClipping(false)
		end
	end
	self.bar:SetCursor("hand")
	self.bar.OnMousePressed = function(pnl, key)
		if self.stream and key == MOUSE_LEFT then
			local x, y = pnl:LocalCursorPos()
			local fr = x / pnl:GetWide()
			self.stream:SetTime(self.len * fr)
		end
	end
end

vgui.Register("mgSoundPlayer", PANEL, "DPanel")
--[[ END: mgui/mgSoundPlayer.lua ]]--



--[[ START: mgui/mgBoolean.lua ]]--
local PANEL = {}
local font = mgui.CreateFont("booleanvalue", {size = 14, bold = true})

function PANEL:SetValue(b)
	self.b_Value = b
	self:SetText(b and "true" or "false")

	if self.OnValueChanged then
		self:OnValueChanged(b)
	end
end

function PANEL:GetValue()
	return self.b_Value == true
end

function PANEL:Init()
	self:SetValue(false)
	self:SetSize(60, 20)
	self:SetFont(font)
	self:SetColor(color_white)
end

function PANEL:Toggle()
	self:SetValue(!self:GetValue())
end

function PANEL:Paint(w, h)
	local clr = self:GetDisabled() and Color(150, 150, 150, 150) or (self.b_Value and Color(76, 175, 80, 150)) or Color(244, 67, 54, 150)
	draw.RoundedBox(4, 0, 0, w, h, clr)
end

vgui.Register("mgBoolean", PANEL, "DButton")
--[[ END: mgui/mgBoolean.lua ]]--



--[[ START: mgui/mgPlayerList.lua ]]--
local PANEL = {}

function PANEL:Init()
	self:SetText("Pick a player...")
	self:SetColor(mgui.Colors.Blue)
	for k, v in ipairs(player.GetAll()) do
		self:AddChoice(v:Nick(), v)
	end
end

function PANEL:SetPlayer(ply)
	if !IsValid(ply) then return end
	if IsValid(self.avatar) then self.avatar:Remove() end

	local avatar = vgui.Create("AvatarImage", self)
	avatar:SetPos(3, 3)
	avatar:SetSize(18, 18)
	avatar:SetPlayer(ply, 32)
	avatar.PaintOver = function(self, w, h) mgui.DrawOutlinedRect(0, 0, w, h, 130, 167, 55) end

	self:SetText(ply:Nick())
	self:SetColor(Color(130, 167, 55))

	self.avatar = avatar
	self.__selected = {ply:Nick(), ply}
end

function PANEL:GetPlayer()
	return self.__selected[2]
end

function PANEL:ChoicePanelCreated(btn)
	btn:SetText("")
	btn.Paint = function(self, w, h)
		if self.Hovered then 
			mgui.DrawRect(0, 0, w, h, 255, 255, 255, 1)
		end
 	end
 	btn.DoClick = function()
 		self.p_List:Close()
 		self:SetPlayer(btn.Data)
 	end

 	local avatar = vgui.Create("AvatarImage", btn)
 	avatar:SetPos(3, 3)
 	avatar:SetSize(18, 18)
 	avatar:SetPlayer(btn.Data, 32)
 	avatar.PaintOver = function(self, w, h) mgui.DrawOutlinedRect(0, 0, w, h, 130, 167, 55) end

 	local name = vgui.Create("DLabel", btn)
 	name:SetColor(Color(130, 167, 55))
 	name:SetText(btn.Value)
 	name:SizeToContents()
 	name:SetPos(29, 0)
 	name:CenterVertical()
 	name:SetWide(btn:GetWide() - 34)
end

function PANEL:OnValueChanged(value, data)
	if !IsValid(v) then
		self:SetText("Pick a player...")
		self:SetColor(mgui.Colors.Blue)
		if IsValid(self.avatar) then self.avatar:Remove() end
		return
	end
end

vgui.Register("mgPlayerList", PANEL, "mgMenu") 
--[[ END: mgui/mgPlayerList.lua ]]--



--[[ START: mgui/mgItem.lua ]]--
local PANEL = {}

local ui = mgui
local font = mgui.CreateFont("item_text", {size = 20})
local styles = {}

local function CutText(str, font, w)
	surface.SetFont(font)
	local res = ""
	local width = surface.GetTextSize(str)
	if width > w then
		local temp = string.ToTable(str)
		for k,v in pairs(temp) do
			if surface.GetTextSize(res .. v .. "...") > w then
				break
			else
				res = res .. v
			end
		end
		res = res .. "..."
	else
		res = str
	end
	return res
end

function PANEL:Init()
	self.BackgroundClr = Color(58, 58, 64)
	self.OutlineClr = Color(255, 255, 255, 5)
	self.ImageOutline = mgui.Colors.LightGreen
	self.TextClr = Color(255, 255, 255, 100)
	self.SteamID = false
	self.Name = false
	self.Entity = false
	self.Weapon = false
	self.Clickable = false
	self.Hovered = false
	self:SetText("")
end

function PANEL:SetSteamID(steamid)
	self.SteamID = steamid
end

function PANEL:SetName(name)
	self.Name = name
end

function PANEL:SetPlayer(ply)
	if not ply:IsPlayer() then return end
	self:SetSteamID(ply:SteamID64())
	self:SetName(ply:Name())
end

function PANEL:SetEntity(ent)
	self.Entity = ent
end

function PANEL:SetWeapon(wep)
	self.Weapon = wep
end

function PANEL:SetString(str)
	self.String = str
end

function PANEL:SetClickable(state)
	self.Clickable = state
	if state then
		self:SetCursor("hand")
	else
		self:SetCursor("arrow")
	end
end

function PANEL:SetBackgroundColor(color)
	self.BackgroundClr = color
end

function PANEL:SetOutlineColor(color)
	self.OutlineClr = color
end

function PANEL:SetImageOutlineColor(color)
	self.ImageOutline = color
end

function PANEL:SetTextColor(color)
	self.TextClr = color
end

function PANEL:Paint(w, h)
	ui.DrawShadow(0, 0, w, h)
	ui.DrawRect(0, 0, w, h, self.BackgroundClr)
	if self.Hovered then ui.DrawRect(0, 0, w, h, 255, 255, 255, 2) end
	ui.DrawOutlinedRect(0, 0, w, h, self.OutlineClr)
end

styles.Player = function(pnl)
	pnl.PlayerAvatar = vgui.Create("AvatarImage", pnl)
	pnl.PlayerAvatar:SetSize(pnl:GetTall() - 10, pnl:GetTall() - 10)
	pnl.PlayerAvatar:SetPos(5, 5)
	pnl.PlayerAvatar:SetSteamID(pnl.SteamID, 64)
	pnl.PlayerAvatar.PaintOver = function(self, w, h)
		ui.DrawOutlinedRect(0, 0, w, h, pnl.ImageOutline)
	end
	pnl.PaintOver = function(self, w, h)
		draw.SimpleText(CutText(pnl.Name, font, pnl:GetWide() - 4 - pnl:GetTall()), font, h, h / 2, pnl.TextClr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

styles.Entity = function(pnl)
	pnl.ModelImage = vgui.Create("ModelImage", pnl)
	pnl.ModelImage:SetSize(pnl:GetTall() - 4, pnl:GetTall() - 2)
	pnl.ModelImage:SetPos(1, 1)
	pnl.ModelImage:SetModel(pnl.Entity:GetModel())
	pnl.PaintOver = function(self, w, h)
		ui.DrawRect(h - 1, 0, 1, h, pnl.OutlineClr)
		draw.SimpleText(CutText(pnl.Name, font, pnl:GetWide() - pnl:GetTall()), font, h + 6, h / 2, self.TextClr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

styles.String = function(pnl)
	pnl.PaintOver = function(self, w, h)
		draw.SimpleText(CutText(pnl.String, font, pnl:GetWide() - 4), font, w / 2, h / 2, self.TextClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function PANEL:SetType(type)
	styles[type](self)
end

vgui.Register("mgItem", PANEL, "DButton")
--[[ END: mgui/mgItem.lua ]]--



--[[ START: mgui/mgMenu.lua ]]--
local PANEL = {}

local menus = {}

function PANEL:Init()
	self:SetText("...")
	self:SetColor(Color(200, 200, 200))
	self._values = {}
	self.__selected = {}
end

function PANEL:AddChoice(value, data)
	table.insert(self._values, {value, data})
end

function PANEL:GetValue()
	return self.__selected[1], self.__selected[2]
end

PANEL.GetChoice = PANEL.GetValue
PANEL.GetSelected = PANEL.GetValue

function PANEL:ChoicePanelCreated() end

function PANEL:CreateList()
	if IsValid(self.p_List) then return end
	if #self._values == 0 then return end

	local w, h = self:GetWide(), 224
	local px, py = self:GetParent():LocalToScreen(self:GetPos())
	local pw, ph = self:GetSize()
	local scrh = ScrH()
	local dir = "bottom"

	local pnl = vgui.Create("mgPanel")
	pnl:SetPos(px, py + ph)
	pnl:SetSize(w, h)
	pnl:MakePopup()
	pnl:SetDrawOnTop(true)
	pnl:SetKeyboardInputEnabled(false)
	pnl.Paint = function(self, w, h)
		mgui.DrawShadow(0, 0, w, h)
		mgui.DrawRect(0, 0, w, h, 58, 58, 64)
	end
	pnl.Think = function(self)
		if self.AnimOpen:Active() then
			self.AnimOpen:Run()
		end
		if self.AnimClose:Active() then
			self.AnimClose:Run()
		end
	end
	pnl.Close = function(self)
		if self._closing or self._opening then return end
		self.AnimOpen:Stop()
		self.hsize = self:GetTall()
		self.AnimClose:Start(0.15)
		self._closing = true
		timer.Simple(0.15, function() if IsValid(self) then self:Remove() end end)
	end
	pnl.Open = function(self)
		if self._opening or self._closing then return end
		self.hsize = self:GetTall()
		self.AnimOpen:Start(0.15)
		self._opening = true
		timer.Simple(0.15, function() if IsValid(self) then self._opening = false end end)
	end
	pnl.AnimOpen = Derma_Anim("aopen", pnl, function(_, _, delta)
		if dir == "bottom" then
			pnl:SetTall(pnl.hsize * delta)
		else
			local size = pnl.hsize * delta
			pnl:SetPos(px, py - size)
			pnl:SetTall(size)
		end
	end)
	pnl.AnimClose = Derma_Anim("aclose", pnl, function(pnl, _, delta)
		if dir == "bottom" then
			pnl:SetTall(pnl.hsize - pnl.hsize * delta)
		else
			local size = pnl.hsize - pnl.hsize * delta
			pnl:SetPos(px, py - size)
			pnl:SetTall(size)
		end
	end) 

	local scr = vgui.Create("mgScrollPanel", pnl)
	scr:SetSize(pnl:GetSize())

	local vbar = scr:GetVBar()
	vbar:SetWide(10)
	vbar:SetShadow(false)

	local values = self._values
	local num = #values
	local pos = 0

	for k, v in ipairs(values) do
		pos = 25 * (k - 1)
		local btn = scr:Add("DButton")
		btn.Value = v[1]
		btn.Data = v[2]
		btn:SetSize(w, 24)
		if num > 9 then btn:SetWide(w - 10) end
		btn:SetPos(0, pos)
		btn:SetText(v[1])
		btn:SetColor(color_white)
		btn.Paint = function(self, w, h)
			if self.Hovered then 
				mgui.DrawRect(0, 0, w, h, 255, 255, 255, 1)
			end
	 	end
	 	btn._mguimenu = true
	 	btn.DoClick = function()
	 		self:ValueChanged(v[1], v[2])
	 		pnl:Close()
	 	end

	 	self:ChoicePanelCreated(btn)

		if k != num and num != 1 then
			local divider = scr:Add("DPanel")
			divider:SetPos(0, pos + 24)
			divider:SetSize(w, 1)
			divider.Paint = function(self, w, h)
				mgui.DrawRect(0, 0, w, h, 255, 255, 255, 5)
			end
			divider._mguimenu = true
		end
	end

	pnl:SetTall(math.Min(h, pos + 24))
	h = pnl:GetTall()

	if (py + ph + h) >= (scrh - 5) then
		dir = "top"
		pnl:SetPos(px, py - h)
	end

	pnl:Open()

	pnl._mguimenu = true
	scr._mguimenu = true
	vbar._mguimenu = true

	self.p_List = pnl
	table.insert(menus, pnl)
end

function PANEL:ValueChanged(value, data)
	self:SetText(value)
	self.__selected = {value, data}

	if self.OnValueChanged then 
		self:OnValueChanged(value, data)
	end
end

function PANEL:OnRemove()
	if IsValid(self.p_List) then
		self.p_List:Remove()
	end
end

function PANEL:DoClick()
	if IsValid(self.p_List) then
		self.p_List:Close()
	else
		self:CreateList()
	end
end

function PANEL:Paint(w, h)
	local clr = self.Hovered and Color(58, 58, 65) or Color(55, 55, 62)
	mgui.DrawRect(0, 0, w, h, clr)
	mgui.DrawOutlinedRect(0, 0, w, h, 255, 255, 255, 5)
end

vgui.Register("mgMenu", PANEL, "DButton") 

hook.Add("VGUIMousePressed", "mgui_playerlist", function(panel)
	if IsValid(panel) and !panel._mguimenu then
		local parent = panel:GetParent()
		if parent and parent._mguimenu then return end
		for k, v in ipairs(menus) do
			if IsValid(v) then
				v:Close()
			end
		end
		menus = {}
	end
end)
--[[ END: mgui/mgMenu.lua ]]--



