-- Filas del Compro Oro, armadas desde defaults/catalogo.lua.
--
-- Cada fila es un item que se muestra y, si tiene variantes que el juego
-- llama igual (anillo izquierdo/derecho, etc.), la lista de las demas que
-- tambien se aceptan como pago. Lo usan groups.lua, items.lua y prices.lua.
local Catalogo = require "PhunMart/defaults/catalogo"

local M = {}

local function full(item)
    return item:find("%.") and item or ("Base." .. item)
end

--- Lista de filas: {grupo, item (corto), full, entrega, pago, sustitutos (full)}
function M.filas()
    local filas = {}
    for _, g in ipairs(Catalogo.compro_oro) do
        for _, entrada in ipairs(g.items) do
            local variantes = type(entrada) == "table" and entrada or {entrada}
            local subs = {}
            for i = 2, #variantes do
                table.insert(subs, full(variantes[i]))
            end
            table.insert(filas, {
                grupo = g.key,
                item = variantes[1],
                full = full(variantes[1]),
                entrega = g.entrega,
                pago = g.pago,
                sustitutos = #subs > 0 and subs or nil
            })
        end
    end
    return filas
end

--- Clave del precio "entregar N" de una fila con variantes.
function M.clavePrecio(fila)
    return "eco_entrega_" .. fila.entrega .. "_" .. fila.item
end

return M
