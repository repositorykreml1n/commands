if cmd == "/kick" then
    -- Берем причину с сервера (из JSON). Если ее вдруг нет, ставим дефолт.
    local reasonToKick = data.reason or "Вы были кикнуты администратором TumbaHub."
    
    -- Кикаем именно с этой переменной, а не с жестким текстом!
    LocalPlayer:Kick(reasonToKick)
