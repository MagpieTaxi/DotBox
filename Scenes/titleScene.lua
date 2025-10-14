local scene = {}
----------------------------------
local music = love.audio.newSource("/Resources/audio/music_intro.mp3", "stream")

local t = 0

local starting = false
local startTime = 0;
function scene.Load()
	starting = false
	startTime = 0
end
function scene.OnUpdate(dt)
	t = t + dt

	if music:isPlaying() == false then
		music:setVolume(.5)
		music:play()
	end

	if starting == true then
		startTime = startTime + dt
		music:setVolume(.5 - startTime / 1.5)
	end
	if startTime >= 1 and starting == true then
		music:pause()
		Scenes:LoadScene("gameScene", true)
	end
end
function scene.OnDraw()
	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	local size = math.min(sw,sh)
	local bgSize = math.max(sw,sh)
	if t > 3 then
		love.graphics.setColor(1,1,1,.5)
		love.graphics.draw(
			Game.Images.background,
			(0 + (t * 10)) % bgSize,
			sh / 2,
			0,
			(2 / Game.Images.background:getWidth()) * bgSize,
			(1 / Game.Images.background:getHeight()) * bgSize,
			Game.Images.background:getWidth() / 2,
			Game.Images.background:getHeight() / 2
		)
	end
	love.graphics.setColor(1,1,1,2 - (t))
	love.graphics.draw(
		Game.Images.intro,
		sw / 2,
		sh / 2,
		0,
		(1 / Game.Images.intro:getWidth()) * size,
		(1 / Game.Images.intro:getHeight()) * size,
		Game.Images.intro:getWidth() / 2,
		Game.Images.intro:getHeight() / 2
	)
	if t > 3 then
		love.graphics.setColor(1,1,1,1)
		love.graphics.setColor(1,1,1,t * 100 - 300)
		love.graphics.draw(
			Game.Images.logo,
			love.graphics.getWidth() / 2,
			love.graphics.getHeight() / 2,
			0,
			(1 / Game.Images.intro:getWidth()) * size + math.sin(t * 4) / 25,
			(1 / Game.Images.intro:getHeight()) * size + math.sin(t * 4) / 25,
			Game.Images.intro:getWidth() / 2,
			Game.Images.intro:getHeight() / 2
		)
		love.graphics.setColor(1,1,1,7 - t * 2)
		love.graphics.rectangle("fill",0,0,sw,sh)

		love.graphics.setColor(0,0,0,0.5)
		love.graphics.rectangle(
			"fill",
			0,
			love.graphics.getHeight() - 42,
			love.graphics.getWidth(),
			20
		)
		love.graphics.setColor(1,1,1,1)
		love.graphics.setFont(coolFont)
		love.graphics.printf(
			"Press [ENTER] to start",
			0,
			love.graphics.getHeight() - 40,
			love.graphics.getWidth(),
			"center",
			0,
			1,
			1
		)
	end
	if starting == true then
		love.graphics.setColor(0,0,0,startTime)
		love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
	end
end
function scene.OnKeypress(k)
	if k == "return" then
		if t < 3 then
			t = 5
		elseif starting == false then
			starting = true
			startTime = 0
		end
	elseif k == "escape" then
		love.event.quit()
	end
end

return scene