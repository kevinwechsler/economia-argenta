-- Precio de cada item que se vende, armado desde defaults/catalogo.lua.
--
-- No editar precios aca: se tocan en catalogo.lua.
local Catalogo = require "PhunMart/defaults/catalogo"

local items = {}

-- La clave tiene que ser el nombre COMPLETO ("Base.Katana"): en el juego el
-- motor normaliza los items de los grupos a su nombre completo antes de
-- buscar su precio aca. Con el nombre corto el precio se ignora y queda el del
-- grupo (1 billete).
for _, lista in ipairs({Catalogo.armeria, Catalogo.ferreteria}) do
    for _, g in ipairs(lista) do
        for item, billetes in pairs(g.items) do
            local full = item:find("%.") and item or ("Base." .. item)
            items[full] = {
                price = "eco_" .. billetes
            }
        end
    end
end

-- Compro Oro: las filas con variantes usan un precio propio que acepta
-- cualquiera de ellas como pago (ver prices.lua y compro_oro.lua).
local CompraOro = require "PhunMart/defaults/compro_oro"
for _, f in ipairs(CompraOro.filas()) do
    if f.sustitutos then
        items[f.full] = {
            price = CompraOro.clavePrecio(f)
        }
    end
end

return items
