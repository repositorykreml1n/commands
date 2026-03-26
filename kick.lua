-- Ловим данные (data), которые мы передали в скобках из лоадера
local data = ... 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Безопасно проверяем, есть ли data и data.reason
local reasonToKick = (data and type(data) == "table" and data.reason) or "Вы были кикнуты администратором TumbaHub."

-- Выполняем кик
LocalPlayer:Kick(reasonToKick)
