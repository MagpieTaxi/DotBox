local ollkorrect = false
repeat
    ollkorrect = true
    if BindToLove == nil then ollkorrect = false goto continue end
    if Enum == nil then ollkorrect = false goto continue end
    ::continue::
until ollkorrect == true

Game = {}
Game.Time = 0