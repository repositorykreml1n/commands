return function(data)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Дебаг: выведет в F9 то, что реально дошло до файла
    print("TumbaHub Debug -> В kick.lua пришло:", data)
    if type(data) == "table" then
        print("TumbaHub Debug -> Причина:", data.reason)
    end

    -- Достаем причину
    local reasonToKick = (data and type(data) == "table" and data.reason) or "Вы были кикнуты администратором TumbaHub."

    -- Кикаем
    LocalPlayer:Kick(reasonToKick)
end
