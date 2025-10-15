local scene = {}

local sceneTime = 0;

local scrWidth, scrHeight = love.graphics.getWidth(), love.graphics.getHeight()

--------------------------------------------------------------------------------------------

local transitioning = false
local transitionTime = 0

local currentMenu = 1
local selectedIndex = 1

local containerText = love.graphics.newText(Game.Fonts.Bold, "|                 |")
local selectedText = love.graphics.newText(Game.Fonts.Bold, ">                <")

local buttons = {
	[1] = { --main menu
		[1] = {
			Text = love.graphics.newText(Game.Fonts.Regular, "Play"),
			OnInteract = function ()
				if transitioning == true then return end
				transitioning = true
				transitionTime = 0
				Task.Delay(.5, function ()
					Game.Audio.music_intro:stop()
					Scenes:LoadScene("gameScene")
				end)
			end
		},
		[2] = {
			Text = love.graphics.newText(Game.Fonts.Regular, "Settings"),
			OnInteract = function ()
				if transitioning == true then return end
				transitioning = true
				transitionTime = 0
				Task.Delay(.5, function ()
					Game.Audio.music_intro:stop()
					Scenes:LoadScene("settingsScene")
				end)
			end
		},
		[3] = {
			Text = love.graphics.newText(Game.Fonts.Regular, "? ? ?"),
			OnInteract = function ()
				Game.Audio.paint_splat:stop()
				Game.Audio.paint_splat:setPitch(math.random(10,120) / 100)
				Game.Audio.paint_splat:play()
			end
		},
		[4] = {
			Text = love.graphics.newText(Game.Fonts.Regular, "Quit"),
			OnInteract = function ()
				if transitioning == true then return end
				transitioning = true
				transitionTime = 0
				Task.Delay(.5, function ()
					Game.Audio.music_intro:stop()
					love.event.quit()
				end)
			end
		}
	}
}

local function renderMenuButtons()
	for i, v in ipairs(buttons[currentMenu]) do
		local p = #buttons[currentMenu] - i - 1

		love.graphics.setColor(0,0,0,0.5)
		love.graphics.rectangle(
			"fill",
			0,
			scrHeight - ((#buttons[currentMenu] + p) * 40),
			scrWidth,
			30
		)
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(
			v.Text,
			scrWidth / 2,
			scrHeight - ((#buttons[currentMenu] + p) * 40) + 5,
			0,
			1,
			1,
			v.Text:getWidth() / 2
		)
		local to = containerText
		if i == selectedIndex then to = selectedText end
		love.graphics.draw(
			to,
			scrWidth / 2,
			scrHeight - ((#buttons[currentMenu] + p) * 40) + 5,
			0,
			1,
			1,
			to:getWidth() / 2
		)
	end
end

--------------------------------------------------------------------------------------------

function scene.Load()
	sceneTime = 0
	transitioning = false
	transitionTime = 0
	Game.Audio.gui_select:setPitch(1.5)
	Game.Audio.music_intro:play()
	Task.Delay(2,function ()
		Game.FlashDone = true
	end)
end

function scene.OnUpdate(dt)
	scrWidth, scrHeight = love.graphics.getWidth(), love.graphics.getHeight()
	sceneTime = sceneTime + dt
	Game.Audio.music_intro:setVolume(1 - transitionTime * 3)
	if transitioning == true then
		transitionTime = transitionTime + dt
		if transitionTime > 2 then
			transitionTime = 0
			transitioning = false
		end
	end
end

function scene.OnDraw()
	local size = math.min(scrWidth,scrHeight)
	local bgSize = math.max(scrWidth,scrHeight)

	---## baselayer
	--background
	love.graphics.setColor(1,1,1,.5)
	love.graphics.draw(
		Game.Images.background,
		(0 + (sceneTime * 10)) % bgSize,
		0,
		0,
		(2 / Game.Images.background:getWidth()) * bgSize,
		(1 / Game.Images.background:getHeight()) * bgSize,
		400 --halfwidth
	)

	--logo
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(
		Game.Images.logo,
		love.graphics.getWidth() / 2,
		love.graphics.getHeight() / 4,
		0,
		(1 / Game.Images.intro:getWidth()) * (size / 1.5) * (1 + math.sin(sceneTime * 4) / 40),
		(1 / Game.Images.intro:getHeight()) * (size / 1.5) * (1 + math.sin(sceneTime * 4) / 40),
		450, --halfwidth
		450 --halfheight
	)

	renderMenuButtons()

	--beginning flash
	if sceneTime > 3 then goto afterTheFlash_Wintertide end
	love.graphics.setColor(1,1,1,1 - (sceneTime / 1.5)^2)
	if Conf.visual.flashiness == 0 or Game.FlashDone == true then love.graphics.setColor(0,0,0,1 - (sceneTime / 1.5)^2) end
	love.graphics.rectangle("fill",0,0,scrWidth,scrHeight)
	::afterTheFlash_Wintertide::
	--transition to game
	if transitioning == false then goto last end
	love.graphics.setColor(0,0,0,transitionTime * 2)
	love.graphics.rectangle("fill",0,0,scrWidth,scrHeight)
	::last::
end

function scene.OnKeypress(k)
	if k == "down" then
		Game.Audio.gui_select:stop()
		Game.Audio.gui_select:play()
		selectedIndex = selectedIndex + 1
		if selectedIndex > #buttons[currentMenu] then selectedIndex = 1 end
	elseif k == "up" then
		Game.Audio.gui_select:stop()
		Game.Audio.gui_select:play()
		selectedIndex = selectedIndex - 1
		if selectedIndex < 1 then selectedIndex = #buttons[currentMenu] end
	elseif k == "return" then
		buttons[currentMenu][selectedIndex].OnInteract()
	end
end

function scene.OnMousepress(x, y)
	for i, v in pairs(buttons[currentMenu]) do
		local p = #buttons[currentMenu] - i - 1
		local yPos = scrHeight - ((#buttons[currentMenu] + p) * 40) + 5
		if y > yPos and y < yPos + 30 then
			buttons[currentMenu][selectedIndex].OnInteract()
		end
	end
end

function scene.OnMousemoved(x, y)
	for i, v in pairs(buttons[currentMenu]) do
		local p = #buttons[currentMenu] - i - 1
		local yPos = scrHeight - ((#buttons[currentMenu] + p) * 40) + 5
		if y > yPos and y < yPos + 30 and i ~= selectedIndex then
			Game.Audio.gui_select:stop()
			Game.Audio.gui_select:play()
			selectedIndex = i
		end
	end
end

return scene