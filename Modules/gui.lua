local module = {}

local scrWidth;
local scrHeight;

local lastMouse = {X = 0,Y = 0}

local mouse1Pressed = false
--local mouse2Pressed = false --unused

local paintColor = {R = 1, G = 1, B = 1}

local toolbar = {
	addButton = {
		index = 1,
		iconNeutral = Game.Images.addTool,
		iconActive = Game.Images.addToolSelected
	},
	moveButton = {
		index = 2,
		iconNeutral = Game.Images.moveTool,
		iconActive = Game.Images.moveToolSelected
	},
	paintButton = {
		index = 3,
		iconNeutral = Game.Images.brushTool,
		iconActive = Game.Images.brushToolSelected
	}
}
local colorWheel = {
	image = Game.Images.colorWheel,
	data = Game.Images.colorWheelData,
	ring = Game.Images.selectionRing,
	ringX = -20,
	ringY = -20
}

function module.OnUpdate()
	scrWidth, scrHeight = love.graphics.getWidth(), love.graphics.getHeight()
	colorWheel.posX = scrWidth - colorWheel.image:getWidth() - 5
	colorWheel.posY = scrHeight - colorWheel.image:getHeight() - 5

	--stuff
	if Game.CurrentTool == toolbar.moveButton.index then --move tool
		if Game.Moving ~= nil and Game.Dots[Game.Moving] ~= nil then
			Game.Dots[Game.Moving].x = love.mouse.getX()
			Game.Dots[Game.Moving].y = love.mouse.getY()

			lastMouse = {X = love.mouse.getX(), Y = love.mouse.getY()}
		end
	elseif Game.CurrentTool == toolbar.paintButton.index then --paint tool
		local mx, my = love.mouse.getX(), love.mouse.getY()
		local relX = love.mouse.getX() - colorWheel.posX
		local relY = love.mouse.getY() - colorWheel.posY
		local dist = math.sqrt((relX - 63)^2 + (relY - 63)^2)

		if mouse1Pressed == true and dist <= 57 then
			if relX > 0 and relY > 0 and relX < colorWheel.image:getWidth() and relY < colorWheel.image:getHeight() then
				colorWheel.ringX, colorWheel.ringY = mx,my
				local r,g,b,a = colorWheel.data:getPixel(relX,relY)
				paintColor = {R = r, G = g, B = b}
			end
		end
	end
end
function module.OnDraw()
	scrWidth, scrHeight = love.graphics.getWidth(), love.graphics.getHeight()
	love.graphics.setColor(1,1,1,1)
	for i, v in pairs(toolbar) do
		local img = v.iconNeutral
		if Game.CurrentTool == v.index then img = v.iconActive end
		local imgW, imgH = img:getWidth() / 3, img:getHeight() / 3
		love.graphics.draw(
			img,
			5 + (imgW + 5) * (v.index - 1),
			scrHeight - imgH - 5,
			0,
			imgW / img:getWidth(),
			imgH / img:getHeight()
		)
	end
	if Game.CurrentTool == toolbar.paintButton.index then
		love.graphics.draw(
			colorWheel.image,
			colorWheel.posX,
			colorWheel.posY
		)
		love.graphics.draw(
			colorWheel.ring,
			colorWheel.ringX,
			colorWheel.ringY,
			0,
			1,
			1,
			6,6
		)
	end
end
function module.OnMousepress(x,y,mb)
	if mb == 1 then mouse1Pressed = true elseif mb == 2 then mouse2Pressed = true end
	
	if mb == 1 then
		for i, v in pairs(toolbar) do
			local imgW = v.iconNeutral:getWidth() / 3
			local imgX = (5 + (imgW + 5)) * (v.index - 1)
			if x > imgX and x < imgX + imgW and y > scrHeight - (v.iconNeutral:getHeight() / 3) - 5 then
				Game.Audio.gui_select:stop()
				Game.Audio.gui_select:play()
				Game.CurrentTool = v.index
				goto mpEnd
			end
		end
	end

	local colliding;
	for i, v in ipairs(Game.Dots) do
		if x > v.x - v.r and x < v.x + v.r and y > v.y - v.r and y < v.y + v.r then
			colliding = i
		end
	end

	if mb == 1 then
		if Game.CurrentTool == toolbar.moveButton.index and colliding ~= nil then
			Game.Moving = colliding
		elseif Game.CurrentTool == toolbar.paintButton.index and colliding ~= nil then
			Game.Audio.paint_splat:stop()
			Game.Audio.paint_splat:setVolume(0.4)
			Game.Audio.paint_splat:play()
			Game.Dots[colliding].c = paintColor
		elseif Game.CurrentTool == toolbar.addButton.index then
			Game.Audio.dot_spawn:stop()
			Game.Audio.dot_spawn:play()
			table.insert(Game.Dots,{
				r = math.random(Conf.dots.minRadius,Conf.dots.maxRadius),
				x = x,
				y = y,
				vx = math.random(Conf.dots.minSpeed,Conf.dots.maxSpeed),
				vy = math.random(Conf.dots.minSpeed,Conf.dots.maxSpeed),
				c = paintColor,
				i = Game.Faces[math.random(1,#Game.Faces)]
			})
		end
	elseif mb == 2 then
		if Game.CurrentTool == toolbar.moveButton.index and colliding ~= nil then
			Game.Dots[colliding].vx = 0
			Game.Dots[colliding].vy = 0
			if Game.Dots[colliding].frozen == true then
				Game.Dots[colliding].frozen = false
			else
				Game.Dots[colliding].frozen = true
			end
		elseif Game.CurrentTool == toolbar.paintButton.index and colliding ~= nil then
			paintColor = Game.Dots[colliding].c
		elseif Game.CurrentTool == toolbar.addButton.index and colliding ~= nil then
			Game.Audio.dot_remove:stop()
			Game.Audio.dot_remove:play()
			table.remove(Game.Dots, colliding)
		end
	end

	::mpEnd::
end
function module.OnMouseRelease(x,y,mb)
	if mb == 1 then mouse1Pressed = false elseif mb == 2 then mouse2Pressed = false end
	if Game.Moving ~= nil and mb == 1 then
		local moving = Game.Dots[Game.Moving]
		moving.vx = (x - (lastMouse.X or x)) / 1.5
		moving.vy = (y - (lastMouse.Y or y)) / 1.5

		if math.sqrt(moving.vx^2 + moving.vy^2) > 30 then
			Game.Audio.whoosh:stop()
			Game.Audio.whoosh:setPitch(2)
			Game.Audio.whoosh:play()
		end 

		Game.Moving = nil

		lastMouse = {X = nil, Y = nil}
	end
	Game.Moving = nil
end
function module.OnKeyPress(k)
	for i, v in pairs(toolbar) do
		if tonumber(k) == v.index then
			Game.Audio.gui_select:stop()
			Game.Audio.gui_select:play()
			Game.CurrentTool = v.index
		end
	end
end

return module