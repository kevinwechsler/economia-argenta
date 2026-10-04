-- Precio de cada item que se vende, armado desde defaults/catalogo.lua.
--
-- No editar precios aca: se tocan en catalogo.lua.
local Catalogo = require "PhunMart/defaults/catalogo"

local items = {}

for _, lista in ipairs({Catalogo.armeria, Catalogo.ferreteria}) do
    for _, g in ipairs(lista) do
        for item, billetes in pairs(g.items) do
            items[item] = {
                price = "eco_" .. billetes
            }
        end
    end
end

return items
