local module = {}

local currentScene;

function module:Initialize()
    Scenes = {}

    function Scenes:LoadScene(sceneName, transition)
        local scene = require("Scenes."..sceneName)
        assert(scene ~= nil, "Scene ".."Scenes."..sceneName.." not found")

        if currentScene ~= nil then
            for i, v in pairs(Enum.LoveBindings) do
                UnbindFromLove(3, v)
            end
        end
        
        if scene.Load ~= nil then
            scene.Load()
        end
        if scene.OnUpdate ~= nil then BindToLove(3,Enum.LoveBindings["Update"],scene.OnUpdate) end
        if scene.OnDraw ~= nil then BindToLove(3,Enum.LoveBindings["Draw"],scene.OnDraw) end
        if scene.OnKeypress ~= nil then BindToLove(3,Enum.LoveBindings["KeyPressed"],scene.OnKeypress) end
        if scene.OnKeyrelease ~= nil then BindToLove(3,Enum.LoveBindings["KeyReleased"],scene.OnKeyrelease) end
        if scene.OnMousepress ~= nil then BindToLove(3,Enum.LoveBindings["MousePressed"],scene.OnMousepress) end
        if scene.OnMouserelease ~= nil then BindToLove(3,Enum.LoveBindings["MouseReleased"],scene.OnMouserelease) end
        currentScene = scene
    end
end

return module