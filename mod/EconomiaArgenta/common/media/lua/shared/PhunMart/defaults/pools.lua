-- Pools de Economia Argenta, armados desde defaults/catalogo.lua.
--
-- `sticky = true` y sin `stock` en las ofertas: la tienda muestra SIEMPRE
-- todos los items, con stock infinito y precio fijo.
local Catalogo = require "PhunMart/defaults/catalogo"

local function keysOf(lista)
    local keys = {}
    for _, g in ipairs(lista) do
        table.insert(keys, g.key)
    end
    return keys
end

return {
    pool_eco_armeria = {
        sticky = true,
        sources = {
            groups = keysOf(Catalogo.armeria)
        }
    },

    pool_eco_ferreteria = {
        sticky = true,
        sources = {
            groups = keysOf(Catalogo.ferreteria)
        }
    },

    pool_eco_compro_oro = {
        sticky = true,
        sources = {
            groups = keysOf(Catalogo.compro_oro)
        }
    }
}
