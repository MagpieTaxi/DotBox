local scene = {}

local sceneTime = 0;

local scrWidth, scrHeight = love.graphics.getWidth(), love.graphics.getHeight()

-------------------------------------------------------------------------------------------------

local titleText = love.graphics.newText(Game.Fonts.Bold, "Settings")
local subtitleText = love.graphics.newText(Game.Fonts.Bold, "[ESCAPE] to return | [ENTER] to confirm")
local selectionText = love.graphics.newText(Game.Fonts.Bold, ">					<")

local currentMenu = 1;
local selectedIndex = 1;
local layer = 1

local typingString = ""

local displayError = false

local transitioning = false
local transitionTime = 0

local tsitSettings = false
local tsitSettingsTime = 0

local settingsCanvas = love.graphics.newCanvas()

local function toBool(v)
	if v == "true" or v == 1 then
		return "true"
	elseif v == "false" or v == 0 then
		return "false"
	else
		return nil
	end
end

local buttons = {
	[1] = { --gameplay section
		Name = love.graphics.newText(Game.Fonts.Regular, "Gameplay"),
		[1] = {
			Name = "Gravity: "..Conf.world.gravity,
			OnInteract = function()
				tsitSettings = true
				Task.Delay(.5,function ()
					typingString = ""
					layer = 3
				end)
			end,
			OnUpdate = function(self, value)
				Conf.world.gravity = value
				self.Name = "Gravity: "..Conf.world.gravity
			end,
			Bounds = {-10,10}
		},
		[2] = {
			Name = "Air Resistance: "..Conf.world.airResistance,
			OnInteract = function()
				tsitSettings = true
				Task.Delay(.5,function ()
					typingString = ""
					layer = 3
				end)
			end,
			OnUpdate = function(self, value)
				Conf.world.airResistance = value
				self.Name = "Air Resistance: "..Conf.world.airResistance
			end,
			Bounds = {-2,2}
		},
		[3] = {
			Name = "Restitution: "..Conf.world.restitution,
			OnInteract = function()
				tsitSettings = true
				Task.Delay(.5,function ()
					typingString = ""
					layer = 3
				end)
			end,
			OnUpdate = function(self, value)
				Conf.world.restitution = value
				self.Name = "Restitution: "..Conf.world.restitution
			end,
			Bounds = {-2,2}
		},
		[4] = {
			Name = "Coloring Mode: "..Conf.fun.coloringMode,
			OnInteract = function()
				tsitSettings = true
				Task.Delay(.5,function ()
					typingString = ""
					layer = 3
				end)
			end,
			OnUpdate = function(self, value)
				Conf.fun.coloringMode = math.floor(value)
				self.Name = "Coloring Mode: "..Conf.fun.coloringMode
			end,
			Bounds = {1,2}
		}
	},
	[2] = { --visuals section
		Name = love.graphics.newText(Game.Fonts.Regular, "Visuals"),
		[1] = {
			Name = "Velocity trails: "..Conf.visual.velocityTrails,
			Type = "Boolean",
			OnInteract = function(self)
				Conf.visual.velocityTrails = (Conf.visual.velocityTrails + 1) % 2
				self.Name = "Velocity trails: "..Conf.visual.velocityTrails
			end
		},
		[2] = {
			Name = "Menu details: "..Conf.visual.menuDetails,
			Type = "Boolean",
			OnInteract = function(self)
				Conf.visual.menuDetails = (Conf.visual.menuDetails + 1) % 2
				self.Name = "Menu details: "..Conf.visual.menuDetails
			end
		},
		[3] = {
			Name = "Flashiness: "..Conf.visual.flashiness,
			Type = "Boolean",
			OnInteract = function(self)
				Conf.visual.flashiness = (Conf.visual.flashiness + 1) % 2
				self.Name = "Flashiness: "..Conf.visual.flashiness
			end
		},
		--[[[4] = {
			Name = "Show faces: "..Conf.dots.showFaces,
			Type = "Boolean",
			OnInteract = function(self)
				Conf.dots.showFaces = (Conf.dots.showFaces + 1) % 2
				self.Name = "Show faces: "..Conf.dots.showFaces
			end
		}]]
	},
	[3] = { --audio section
		Name = love.graphics.newText(Game.Fonts.Regular, "Audio"),
		[1] = {
			Name = "Master volume: "..Conf.audio.masterVolume,
			OnInteract = function()
				tsitSettings = true
				Task.Delay(.5,function ()
					typingString = ""
					layer = 3
				end)
			end,
			OnUpdate = function(self, value)
				Conf.audio.masterVolume = value
				love.audio.setVolume(Conf.audio.masterVolume / 100)
				self.Name = "Master volume: "..Conf.audio.masterVolume
			end,
			Bounds = {0,100}
		},
		[2] = {
			Name = "",
			OnInteract = function()
				
			end
		}
	}
}

local function RenderSettings()
	--title/subtitle
	love.graphics.draw(
		Game.Images.SettingsTitle,
		math.max(scrWidth / 2),
		40,
		0,
		1,
		1,
		170
	)
	love.graphics.setColor(0,0,0,1)
	love.graphics.draw(
		subtitleText,
		math.max(scrWidth / 2),
		scrHeight - 40,
		0,
		1,
		1,
		subtitleText:getWidth() / 2
	)

	love.graphics.setCanvas(settingsCanvas)
	love.graphics.clear()

	if layer == 3 then
		love.graphics.setFont(Game.Fonts.Bold)
		love.graphics.printf(
			"Type a number. Bounds: "..buttons[currentMenu][selectedIndex].Bounds[1]..", "..buttons[currentMenu][selectedIndex].Bounds[2],
			0,
			scrHeight / 2 + 55,
			scrWidth,
			"center"
		)
		if displayError == true then
			love.graphics.setColor(0.8,0,0,1)
			love.graphics.printf(
				"Invalid input! Must be a number within bounds",
				0,
				scrHeight - 70,
				scrWidth,
				"center"
			)
		end
	end

	--background black rectangles
	local cylinSize = math.max(scrWidth,800)
	for i = 0, 4 do
		love.graphics.setColor(0,0,0,.5)
		if i == 0 or i == 4 then love.graphics.setColor(0,0,0,0.25) end
		if layer == 3 and i ~= 2 then love.graphics.setColor(0,0,0,0) end
		love.graphics.rectangle(
			"fill",
			(scrWidth - (cylinSize - scrWidth)) * (1 / 4) + 24,
			(scrHeight / 2 - (65 * 2) + (65 * i)),
			(scrWidth + (cylinSize - scrWidth)) / 2 - 48,
			50
		)
	end
	--content
	if layer == 1 then
		for i = 0, 4 do
			local s = ((i + selectedIndex - 3) % #buttons) + 1
			local name;
			if buttons[s] == nil then name = love.graphics.newText(Game.Fonts.Regular, "nil") else name = buttons[s].Name end
			love.graphics.setColor(1,1,1,1)
			if i == 0 or i == 4 then love.graphics.setColor(1,1,1,.8) end
			love.graphics.draw(
				name,
				scrWidth / 2,
				(scrHeight / 2 - (65 * 2) + (65 * i)) + 15,
				0,
				1,
				1,
				name:getWidth() / 2
			)
		end
	elseif layer == 2 then
		love.graphics.setFont(Game.Fonts.Regular)
		for i = 0, 4 do
			local s = ((i + selectedIndex - 3) % #buttons[currentMenu]) + 1
			local THIS_pointingupemoji = buttons[currentMenu][s]
			love.graphics.setColor(1,1,1,1)
			if i == 0 or i == 4 then love.graphics.setColor(1,1,1,.8) end
			love.graphics.printf(
				THIS_pointingupemoji.Name,
				0,
				(scrHeight / 2 - (65 * 2) + (65 * i)) + 15,
				scrWidth,
				"center"
			)
		end
	elseif layer == 3 then
		love.graphics.setColor(1,1,1,1)
		love.graphics.printf(
			typingString,
			0,
			scrHeight / 2 + 15,
			scrWidth,
			"center"
		)
	end
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(
		selectionText,
		scrWidth / 2,
		scrHeight / 2 + 10,
		0,
		1,
		1.5,
		selectionText:getWidth() / 2
	)

	love.graphics.setCanvas()
	love.graphics.setColor(1,1,1,1)
	if tsitSettings == true then love.graphics.setColor(1,1,1,(2*tsitSettingsTime - 1)^2) end
	love.graphics.draw(settingsCanvas,0,0)
end

-------------------------------------------------------------------------------------------------

local backgroundQuad;
local function updateBackground()
	backgroundQuad = love.graphics.newQuad(
		0,
		0,
		math.max(scrWidth,800) / 2,
		scrHeight,
		Game.Images.ui_bg1
	)
end
updateBackground()

-------------------------------------------------------------------------------------------------

function scene.Load()
	Game.Audio.music_extra:setVolume(1)
	Game.Audio.music_extra:play()
	Game.Images.ui_bg1:setWrap("repeat")

	sceneTime = 0
	
	tsitSettings = false
	tsitSettingsTime = 0

	transitioning = false
	transitionTime = 0
end

function scene.OnUpdate(dt)
	if scrWidth ~= love.graphics.getWidth() or scrHeight ~= love.graphics.getHeight() then
		updateBackground()
		settingsCanvas = love.graphics.newCanvas()
		scrWidth, scrHeight = love.graphics.getWidth(), love.graphics.getHeight()
	end
	if tsitSettings == true then
		tsitSettingsTime = tsitSettingsTime + dt
		if tsitSettingsTime >= 1 then
			tsitSettings = false
			tsitSettingsTime = 0
		end
	end
	if transitioning == true then
		transitionTime = transitionTime + dt
		Game.Audio.music_extra:setVolume(1 - transitionTime * 3)
	end
	sceneTime = sceneTime + dt
end

function scene.OnDraw()
	local cylinSize = math.max(scrWidth,800)
	local bgSize = math.max(scrWidth,scrHeight)

	---## baselayer
	--background
	love.graphics.setColor(1,1,1,1)
	
	love.graphics.draw(
		Game.Images.settings_background,
		(0 + (sceneTime * 10)) % bgSize,
		0,
		0,
		(2 / Game.Images.background:getWidth()) * bgSize,
		(1 / Game.Images.background:getHeight()) * bgSize,
		400 --halfwidth
	)

	---- ## content
	--background
	love.graphics.setColor(0,0,0,0.4)
	love.graphics.rectangle(
		"fill",
		(scrWidth - (cylinSize - scrWidth)) * (1 / 4) - 12,
		0,
		(scrWidth + (cylinSize - scrWidth)) / 2 + 24,
		scrHeight
	)
	love.graphics.setColor(1,1,1,1)
	backgroundQuad:setViewport(sceneTime * 10,-sceneTime * 10, cylinSize / 2, scrHeight)
	love.graphics.draw(
		Game.Images.ui_bg1,
		backgroundQuad,
		(cylinSize - (cylinSize - scrWidth)) / 2,
		0,
		0,
		1,
		1,
		(cylinSize) / 4
	)
	love.graphics.draw(
		Game.Images.gradient_wall,
		scrWidth / 2,
		0,
		0,
		(1 / 400) * cylinSize / 2,
		(1 / 400) * scrHeight,
		200,
		0
	)

	RenderSettings()

	--transitions
	if sceneTime < 2 then
		love.graphics.setColor(0,0,0,1 - (sceneTime * 2))
		love.graphics.rectangle("fill",0,0,scrWidth,scrHeight)
	end
	if transitioning == true then
		love.graphics.setColor(0,0,0,transitionTime * 2)
		love.graphics.rectangle("fill",0,0,scrWidth,scrHeight)
	end
end

local capitalize = false
function scene.OnKeypress(k)
	if tsitSettings == true then return end
	if layer == 3 then --keystroke capture
		if k == "escape" then
			tsitSettings = true
			Task.Delay(.5,function ()
				layer = 2
			end)
		elseif k == "return" then
			if tonumber(typingString) == nil and displayError == false then
				displayError = true
				Task.Delay(1, function()
					displayError = false
				end)
			elseif tonumber(typingString) ~= nil then
				local this = buttons[currentMenu][selectedIndex]
				local value = math.min(math.max(tonumber(typingString),this.Bounds[1]),this.Bounds[2])
				this:OnUpdate(value)
				tsitSettings = true
				Task.Delay(0.5,function ()
					layer = 2
				end)
			end
		elseif k == "backspace" then
			typingString = string.sub(typingString,1,-2)
		elseif k == "lshift" or k == "rshift" then
			capitalize = true
		elseif k == "capslock" then
			return
		else
			if capitalize == true then k = string.upper(k) end
			if k == "space" then k = " " end
			typingString = typingString..k
		end
	else --
		if k == "escape" then
			if layer == 1 then
				transitioning = true
				Task.Delay(0.5,function ()
					Game.Audio.music_extra:stop()
					Scenes:LoadScene("titleScene2")
				end)
			elseif layer == 2 then
				tsitSettings = true
				Task.Delay(.5,function ()
					selectedIndex = currentMenu
					layer = layer - 1
				end)
			end
		elseif k == "up" then
			Game.Audio.gui_select:stop()
			Game.Audio.gui_select:play()
			selectedIndex = selectedIndex - 1
		elseif k == "down" then
			Game.Audio.gui_select:stop()
			Game.Audio.gui_select:play()
			selectedIndex = selectedIndex + 1
		elseif k == "return" then
			if layer == 1 then
				tsitSettings = true
				Task.Delay(.5, function ()
					currentMenu = selectedIndex
					selectedIndex = 1
					layer = 2
				end)
			else
				if buttons[currentMenu][selectedIndex] == nil or buttons[currentMenu][selectedIndex].OnInteract == nil then return end
				buttons[currentMenu][selectedIndex].OnInteract(buttons[currentMenu][selectedIndex])
			end
		end
		if layer == 1 then
			if selectedIndex > #buttons then selectedIndex = 1 end
			if selectedIndex < 1 then selectedIndex = #buttons end
		elseif layer == 2 then
			if selectedIndex > #buttons[currentMenu] then selectedIndex = 1 end
			if selectedIndex < 1 then selectedIndex = #buttons[currentMenu] end
		end
	end
end
function scene.OnKeyrelease(k)
	if k == "lshift" or k =="rshift" then
		capitalize = false
	end
end
function scene.OnMousepress(x,y,mb)
	if mb == 1 then
		if y > scrHeight / 2 + 50 then
			scene.OnKeypress("down")
		elseif y < scrHeight / 2 then
			scene.OnKeypress("up")
		else
			scene.OnKeypress("return")
		end
	end
end

return scene