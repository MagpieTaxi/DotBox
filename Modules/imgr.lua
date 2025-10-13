local imgr = {}

function imgr.LoadImagePath(dir)
	local imgs = {}
	for i, v in pairs(love.filesystem.getDirectoryItems(dir)) do
		table.insert(imgs,love.graphics.newImage(dir.."/"..v))
	end
	return imgs
end

return imgr