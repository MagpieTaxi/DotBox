local scene = {}

Game.Dots = {}

local scrWidth;
local scrHeight;

Game.CurrentTool = 1;

Game.Paused = false;
Game.Step = false;
Game.Moving = nil;
Game.ElapsedTime = 0;
local PChanged = math.huge;
local dataVisible = false;
local data = {
	Temperature = 0,
	Dots = 0,
}

local fadeShader = love.graphics.newShader(
	[[
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        vec4 px = Texel(tex, tc);
        px.a *= 0.95;
        return px;
    }]]
)

local coolFont;
local dotBase;
local lock;

local bgCanvas = love.graphics.newCanvas();
local bgCanvas2 = love.graphics.newCanvas();

local gui = require("/Modules/gui")

local lastMouse = {X = nil, Y = nil}

-------------------------------------------

local function addMasses(v1,v2)
	return math.sqrt(((math.pi * (v1.r^2)) + (math.pi * (v2.r^2))) / math.pi)
end

-------------------------------------------

function scene.Load()
	scrWidth = love.graphics.getWidth()
	scrHeight = love.graphics.getHeight()

	coolFont = love.graphics.newFont("/Resources/ChicagoFLF.ttf", 12)

	if Game.ElapsedTime > 0 then goto continue end
	for i = 1, Conf.dots.startingDots do
		table.insert(Game.Dots,{
			r = math.random(Conf.dots.minRadius,Conf.dots.maxRadius),
			x = math.random(Conf.dots.maxRadius,scrWidth - Conf.dots.maxRadius),
			y = math.random(Conf.dots.maxRadius,scrHeight - Conf.dots.maxRadius),
			vx = math.random(Conf.dots.minSpeed,Conf.dots.maxSpeed),
			vy = math.random(Conf.dots.minSpeed,Conf.dots.maxSpeed),
			c = {R = math.random(),G = math.random(),B = math.random()},
			i = Game.Faces[math.random(1,#Game.Faces)]
		})
	end
	::continue::
end

function scene.OnUpdate(dt)
	scrWidth = love.graphics.getWidth()
	scrHeight = love.graphics.getHeight()

	Game.ElapsedTime = Game.ElapsedTime + dt

	if bgCanvas:getWidth() ~= scrWidth or bgCanvas:getHeight() ~= scrHeight then
		bgCanvas = love.graphics.newCanvas()
	end

	bgImgData = love.image.newImageData(scrWidth, scrHeight)

	PChanged = PChanged + dt

	gui.OnUpdate()

	if Game.Paused == true and Game.Step == false then goto updateend end

	data.Temperature = 0
	data.Dots = #Game.Dots

	for i, v in ipairs(Game.Dots) do
		if i == Game.Moving then goto continue end
		if v.frozen == true then
			v.vx = 0
			v.vy = 0
		end
		local lastx, lasty = v.x, v.y

		v.x = v.x + v.vx
		v.y = v.y + v.vy

		v.vy = v.vy + Conf.world.gravity

		v.vx = v.vx * (1 - Conf.world.airResistance)
		v.vy = v.vy * (1 - Conf.world.airResistance)

		if v.x > scrWidth - v.r or v.x < 0 + v.r then
			local dir;
			if v.x > scrWidth - v.r then dir = -1 else dir = 1 end
			v.x = (scrWidth / 2 + (scrWidth / 2 * -dir)) + v.r * dir
			v.vx = -v.vx * Conf.world.restitution

			local speed = math.max(math.sqrt(v.vx^2 + v.vy^2), math.sqrt(v.vx^2 + v.vy^2))
			if speed > 10 then
				Game.Audio.collision:stop()
				Game.Audio.collision:setPitch(math.random(95, 105) / 100)
				Game.Audio.collision:setVolume(math.min(speed / 80, 2.5))
				Game.Audio.collision:play()
			end
		end
		if v.y > scrHeight - v.r or v.y < 0 + v.r then
			local dir;
			if v.y > scrHeight - v.r then dir = -1 else dir = 1 end
			v.y = (scrHeight / 2 + (scrHeight / 2 * -dir)) + v.r * dir
			v.vy = -v.vy * Conf.world.restitution

			local speed = math.max(math.sqrt(v.vx^2 + v.vy^2), math.sqrt(v.vx^2 + v.vy^2))
			if speed > 10 then
				Game.Audio.collision:stop()
				Game.Audio.collision:setPitch(math.random(95, 105) / 100)
				Game.Audio.collision:setVolume(math.min(speed / 80, 2.5))
				Game.Audio.collision:play()
			end
		end

		if v.frozen == true then goto continue end
		for i2, v2 in ipairs(Game.Dots) do
			if i2 == i or i2 == Game.Moving then goto continue end
			
			local vect = {X = (v2.x - v.x), Y = (v2.y - v.y)}
			local magn = math.max(math.sqrt(vect.X^2 + vect.Y^2), 0.001)
			local unit = {X = vect.X / magn, Y = vect.Y / magn}

			if magn < v.r + v2.r then
				if Conf.fun.mergeMode == 1 then
					if v.r < v2.r then
						v2.r = addMasses(v,v2)
						table.remove(Game.Dots, i)
					else
						v.r = addMasses(v,v2)
						table.remove(Game.Dots, i2)
					end
					goto continue
				end

				local speed = math.max(math.sqrt(v.vx^2 + v.vy^2), math.sqrt(v.vx^2 + v.vy^2))
				if speed > 10 then
					Game.Audio.collision:stop()
					Game.Audio.collision:setPitch(math.random(95, 105) / 100)
					Game.Audio.collision:setVolume(math.min(speed / 80, 2.5))
					Game.Audio.collision:play()
				end

				local overlap = (v.r + v2.r) - magn
				
				--keep them from being inside eachother (gross)
				if v.frozen ~= true then
					v.x = v.x - unit.X * overlap / 2
					v.y = v.y - unit.Y * overlap / 2
				end
				if v2.frozen ~= true then
					v2.x = v2.x + unit.X * overlap / 2
					v2.y = v2.y + unit.Y * overlap / 2
				end
				
				--bouncy
				local rvx = v2.vx - v.vx
				local rvy = v2.vy - v.vy

				-- velocity along the normal
				local velAlongNormal = rvx * unit.X + rvy * unit.Y

				-- don't resolve if they’re separating already
				if velAlongNormal > 0 then goto continue end

				-- masses
				local m1 = math.pi * v.r^2
				local m2 = math.pi * v2.r^2
				local mt = m1 + m2

				if v.frozen == true then m1 = math.huge end
				if v2.frozen == true then m2 = math.huge end

				-- compute impulse scalar
				local j = -(1 + Conf.world.restitution) * velAlongNormal
				j = j / (1/m1 + 1/m2)

				-- apply impulse along the normal
				local impulseX = j * unit.X
				local impulseY = j * unit.Y

				v.vx = v.vx - (1/m1) * impulseX
				v.vy = v.vy - (1/m1) * impulseY
				v2.vx = v2.vx + (1/m2) * impulseX
				v2.vy = v2.vy + (1/m2) * impulseY

				if Conf.fun.infectionMode == 1 then
					if math.random(1,2) == 1 then
						v2.i = v.i
						v2.c = v.c
					else
						v.i = v2.i
						v.c = v2.c
					end
				end
			end

			::continue::
		end

		local speed = math.sqrt(v.vx^2 + v.vy^2)
		local maxSpeed = math.sqrt(scrWidth^2 + scrHeight^2) / 4
		if Conf.advanced.speedCap == 1 and speed > maxSpeed then
			local unit = {v.vx / speed, v.vy / speed}
			v.vx = unit[1] * maxSpeed
			v.vy = unit[2] * maxSpeed
		end
		data.Temperature = data.Temperature + math.sqrt(v.vx^2 + v.vy^2)

		::continue::
	end
	::updateend::
end

function scene.OnDraw()
	love.graphics.setColor(1,1,1,1)
	if Game.Paused == false or Game.Step == true then --render trails
		love.graphics.setCanvas(bgCanvas2)
		love.graphics.setShader(fadeShader)
		love.graphics.clear(0, 0, 0, 0)
		love.graphics.draw(bgCanvas, 0, 0)
	end
	bgCanvas, bgCanvas2 = bgCanvas2, bgCanvas
	love.graphics.setCanvas()
	love.graphics.draw(bgCanvas,0,0)
	love.graphics.setShader()

	for i, v in ipairs(Game.Dots) do --renders the actual dots
		if Conf.fun.coloringMode == 2 then
			love.graphics.setColor(math.sqrt(v.vx^2 + v.vy^2) / (math.abs(Conf.dots.minSpeed) + Conf.dots.maxSpeed), v.x / scrWidth, v.y / scrHeight)
		elseif Conf.fun.coloringMode == 3 then
			
		else
			love.graphics.setColor(v.c.R, v.c.G, v.c.B)
		end
		
		love.graphics.draw(
			Game.Images.dot_base,
			v.x - v.r,
			v.y - v.r,
			0,
			(1 / 200) * v.r * 2,
			(1 / 200) * v.r * 2
		)
		if Conf.dots.showFaces == 1 then
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(
				v.i,
				v.x - v.r,
				v.y - v.r,
				0,
				(2 / v.i:getWidth()) * v.r,
				(2 / v.i:getHeight()) * v.r
			)
		end
		if v.frozen == true then
			love.graphics.setColor(1,1,1,0.65)
			love.graphics.draw(
				Game.Images.lock,
				v.x - v.r,
				v.y - v.r,
				0,
				(1 / 200) * v.r * 2,
				(1 / 200) * v.r * 2
			)
		end

		if math.sqrt(v.vx^2 + v.vy^2) > 30 and (Game.Paused == false or Game.Step == true) then
			love.graphics.setCanvas(bgCanvas) --put the trails in the canvas for next frame
			love.graphics.setColor(v.c.R / 2, v.c.G / 2, v.c.B / 2, 1)
			love.graphics.circle(
				"fill",
				v.x,
				v.y,
				v.r,
				32
			)
			love.graphics.setCanvas()
		end
	end

	local text = "Paused" --pause text (top left)
	if Game.Paused == false then text = "Unpaused" end
	love.graphics.setColor(1,1,1,2 - PChanged * 2)
	love.graphics.printf(
		text,
		coolFont,
		5,
		5,
		100
	)
	if dataVisible == true then --debug/data thingy
		love.graphics.setColor(1,1,1,1)

		local dotsLabel = love.graphics.newText(coolFont, "Dots: "..data.Dots)
		local tempLabel = love.graphics.newText(coolFont, "Temperature: "..math.floor(data.Temperature * 100) / 100)

		love.graphics.draw(
			dotsLabel,
			scrWidth - dotsLabel:getWidth() - 5,
			5
		)
		love.graphics.draw(
			tempLabel,
			scrWidth - tempLabel:getWidth() - 5,
			10 + dotsLabel:getHeight()
		)
	end

	if Game.ElapsedTime < 10 then --title hint
		love.graphics.setColor(1,1,1, 5 - Game.ElapsedTime)
		love.graphics.printf(
			"Press ESC to return to the title",
			coolFont,
			0,
			5,
			scrWidth,
			"center"
		)
	end

	gui.OnDraw()

	Game.Step = false
end

function scene.OnKeypress(k)
	if k == "space" then
		Game.Paused = not Game.Paused
		PChanged = 0
	elseif k == "p" then
		dataVisible = not dataVisible
	elseif k == "right" and Game.Paused == true then
		Game.Step = true
	elseif k == "escape" then
		Scenes:LoadScene("titleScene")
	else
		gui.OnKeyPress(k)
	end
end

function scene.OnMousepress(x,y,mb,t)
	gui.OnMousepress(x,y,mb)
	--[[
	if mb == 1 then
		if colliding ~= nil and love.keyboard.isDown("lshift") == false then
			Game.Moving = colliding
		else
			table.insert(Game.Dots,{
				r = math.random(Conf.dots.minRadius,Conf.dots.maxRadius),
				x = x,
				y = y,
				vx = math.random(Conf.dots.minSpeed,Conf.dots.maxSpeed),
				vy = math.random(Conf.dots.minSpeed,Conf.dots.maxSpeed),
				c = {R = math.random(),G = math.random(),B = math.random()},
				i = faces[math.random(1,#faces)]
			})
		end
	elseif mb == 2 then
		if colliding ~= nil then
			table.remove(Game.Dots, colliding)
		end
	end
	]]
end
function scene.OnMouserelease(x, y, mb)
	gui.OnMouseRelease(x,y,mb)
end

return scene