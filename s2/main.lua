Enum = {}
Enum.LoveBindings = {
	["Load"] = 1,
	["Update"] = 2,
	["Draw"] = 3,
	["MousePressed"] = 4,
	["MouseReleased"] = 5,
	["KeyPressed"] = 6,
	["KeyReleased"] = 7
}

Game = {}

--# Load a bunch of files--------------------------------------

Game.Images = {}

assert(love.filesystem.getInfo("Resources") ~= nil, "Resources folder does not exist.")
for i, v in pairs(love.filesystem.getDirectoryItems("Resources")) do
	local filename = v:match("^(.-)%.")
	local filetype = string.match(v,"%.([^%s]*)")
	if filename == "colorWheel" then
		Game.Images[v:match("^(.-)%.").."Data"] = love.image.newImageData(love.filesystem.newFile("Resources/"..v))
	end
	if filetype == "png" then
		Game.Images[v:match("^(.-)%.")] = love.graphics.newImage(love.filesystem.newFile("Resources/"..v))
	end
end

Game.Audio = {}

assert(love.filesystem.getInfo("Resources/audio") ~= nil, "Audio folder does not exist.")
for i, v in pairs(love.filesystem.getDirectoryItems("Resources/audio")) do
	local filetype = string.match(v,"%.([^%s]*)")
	local filename = v:match("^(.-)%.")
	if filename == "music_intro" then goto continue end
	if filetype == "mp3" or filetype == "ogg" then
		Game.Audio[v:match("^(.-)%.")] = love.audio.newSource(love.filesystem.newFile("Resources/audio/"..v), "static")
	end
	::continue::
end

Game.Faces = {}

assert(love.filesystem.getInfo("Resources/faces") ~= nil, "Faces folder does not exist.")
for i, v in pairs(love.filesystem.getDirectoryItems("Resources/faces")) do
	local filetype = string.match(v,"%.([^%s]*)")
	if filetype == "png" then
		table.insert(Game.Faces,love.graphics.newImage(love.filesystem.newFile("Resources/faces/"..v)))
	end
end

--# Setup config-----------------------------------------------

if love.filesystem.getInfo("config.ini") == nil then
	love.filesystem.write("config.ini", [[
[dots]
startingDots = 6
showFaces = 1
faceType = faces
minSpeed = -2
maxSpeed = 2
minRadius = 20
maxRadius = 30

[world]
restitution = 1
gravity = 0
airResistance = 0

[fun]
coloringMode = 1
infectionMode = 0
mergeMode = 0

[advanced]
speedCap = 1
	]])
end

--# Required modules-------------------------------------------

Imgr = require("Modules.imgr")
Lip = require("Modules.lip")
Conf = Lip.parse("config.ini")

local ScenesManager = require("ScenesManager")

--# Bind-To-Love system----------------------------------------
local LoveBindings = {}
LoveBindings[1] = {} --Load
LoveBindings[2] = {} --Update
LoveBindings[3] = {} --Draw
LoveBindings[4] = {} --MouseDown
LoveBindings[5] = {} --MouseUp
LoveBindings[6] = {} --KeyDown
LoveBindings[7] = {} --KeyUp

function BindToLove(priority, lbType, func)
	--[[ Binds a function to one of the default LOVE2D callbacks.
		Priority: Integer values, lower numbers execute first. Using the same priority as another function will override it.
		lbType: LOVE2D Callback type. Should be an Enum.LoveBindings value.
		func: The function to be called.
	]]
	if LoveBindings[lbType] == nil or type(func) ~= "function" then return end --TODO: Add error handling here ig
	LoveBindings[lbType][priority] = func
end
function UnbindFromLove(priority, lbType)
	if LoveBindings[lbType] == nil or LoveBindings[lbType][priority] == nil then return end
	LoveBindings[lbType][priority] = nil
end
local function RunLoveBindings(type,...)
	for i, v in pairs(LoveBindings[type]) do
		v(...)
	end
end
--# Initialize ------------------------------------------------
function love.load()
	love.window.setMode(600, 400, {
        resizable = true,
        minwidth = 300,
        minheight = 300,
    })
    love.window.setTitle("DotBox V1.0")
    love.window.setIcon(love.image.newImageData("Resources/icon.png"))
	
	RunLoveBindings(Enum.LoveBindings["Load"])
end

function love.update(dt)
	RunLoveBindings(Enum.LoveBindings["Update"], dt)
end

function love.draw()
	RunLoveBindings(Enum.LoveBindings["Draw"])
end

function love.keypressed(...)
	RunLoveBindings(Enum.LoveBindings["KeyPressed"],...)
end

function love.keyreleased(...)
	RunLoveBindings(Enum.LoveBindings["KeyReleased"],...)
end

function love.mousepressed(...)
	RunLoveBindings(Enum.LoveBindings["MousePressed"],...)
end

function love.mousereleased(...)
	RunLoveBindings(Enum.LoveBindings["MouseReleased"],...)
end

function love.quit()
	Lip.save("config.ini",Conf)
end

-----------------------------------------------------------------------

ScenesManager:Initialize()
Scenes:LoadScene("titleScene")