-- commands/kick.lua
-- Логика исполнения команды /kick

if not Mega.Commands then Mega.Commands = {} end

Mega.Commands["/kick"] = function(data)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    -- Проверяем, передали ли нам причину. Если нет — ставим дефолтную.
    local kickReason = (data and data.reason) and data.reason or "Вы были кикнуты администратором TumbaHub."
    
    LocalPlayer:Kick(kickReason)
end
