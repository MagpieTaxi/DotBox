local scene = {}

local time = 0

function scene.Load()
	
end

function scene.OnUpdate(dt)
	time = time + dt

	if time >= 6 then
		Scenes:LoadScene("titleScene2")
	end
end

function scene.OnDraw()
	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	local size = math.min(sw,sh)

	love.graphics.setColor(1,1,1,-((time - 2.5) / 1.8)^2 + 1.5)
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
end

function scene.OnKeypress()
	Scenes:LoadScene("titleScene2")
end

return scene