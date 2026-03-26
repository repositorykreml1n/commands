-- commands/kick.lua
-- Логика исполнения команды /kick

if not Mega.Commands then Mega.Commands = {} end

Mega.Commands["/kick"] = function(data)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    LocalPlayer:Kick("Вы были кикнуты администратором TumbaHub.")
end
