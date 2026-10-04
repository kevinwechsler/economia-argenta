-- Grupos de items de Economia Argenta, armados desde defaults/catalogo.lua.
--
-- No editar precios aca: se tocan en catalogo.lua.
local Catalogo = require "PhunMart/defaults/catalogo"

local groups = {}

local function sortedKeys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- Tiendas que venden: el precio de cada item va en items.lua; el del grupo
-- es solo un respaldo.
for _, lista in ipairs({Catalogo.armeria, Catalogo.ferreteria}) do
    for _, g in ipairs(lista) do
        groups[g.key] = {
            label = g.label,
            defaults = {
                price = "eco_1",
                offer = {
                    weight = 1.0
                }
            },
            items = sortedKeys(g.items)
        }
    end
end

-- Compro Oro: el precio es entregar N del item y el premio son billetes.
-- Solo se lista el primero de cada fila con variantes (compro_oro.lua).
local CompraOro = require "PhunMart/defaults/compro_oro"
for _, g in ipairs(Catalogo.compro_oro) do
    groups[g.key] = {
        label = g.label,
        defaults = {
            price = "eco_entrega_" .. g.entrega,
            reward = "eco_pago_" .. g.pago,
            offer = {
                weight = 1.0
            }
        },
        items = {}
    }
end
for _, f in ipairs(CompraOro.filas()) do
    table.insert(groups[f.grupo].items, f.item)
end

return groups
