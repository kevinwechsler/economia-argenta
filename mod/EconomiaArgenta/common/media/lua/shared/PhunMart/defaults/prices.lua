-- Precios de Economia Argenta.
--
-- La moneda es el billete vanilla `Base.Money`. Un billete vale mucho: con 5
-- se compra una caja de balas, con unos 15 una pistola. Por eso hay pocos en
-- el mundo (ver server/EconomiaArgenta/billetes.lua) y nadie tiene que cargar
-- cientos.
--
-- El motor escribe todos sus montos en centavos, asi que `currency_base` usa
-- factor 0.01 para que 100 centavos = 1 billete. Encima se aplica el
-- FactorPrecios de sandbox (100 = normal, 200 = todo el doble).
--
-- Al redefinir `currency_base` aca, TODOS los precios del motor que heredan de
-- el se cobran en billetes, y los pagos del Compro Oro (adjustBalance) se
-- entregan como billetes fisicos.
local function factorPrecios()
    local vars = SandboxVars and SandboxVars.EconomiaArgenta
    local pct = vars and tonumber(vars.FactorPrecios) or 100
    return 0.01 * (pct / 100)
end

local prices = {

    -- El motor referencia esta clave por nombre.
    free = {
        kind = "free"
    },

    currency_base = {
        kind = "items",
        items = {{
            item = "Base.Money",
            amount = 1
        }},
        amount = 1,
        factor = factorPrecios(),
        label = "Pesos"
    },

    -- "self": el jugador entrega N unidades del item mostrado (Compro Oro).
    eco_entrega_1 = {
        kind = "self",
        amount = 1,
        factor = 1
    },
    eco_entrega_2 = {
        kind = "self",
        amount = 2,
        factor = 1
    },
    eco_entrega_5 = {
        kind = "self",
        amount = 5,
        factor = 1
    }
}

-- Escalera eco_1 .. eco_999: precio en billetes. Las tiendas y los items
-- referencian estas claves por nombre (eco_15 = 15 billetes).
for n = 1, 999 do
    prices["eco_" .. n] = {
        inherit = "currency_base",
        amount = n * 100
    }
end

-- Compro Oro: "entregar N" que acepta cualquier variante de la joya
-- (anillo izquierdo o derecho, etc.). Una clave por fila con variantes.
local CompraOro = require "PhunMart/defaults/compro_oro"
for _, f in ipairs(CompraOro.filas()) do
    if f.sustitutos then
        prices[CompraOro.clavePrecio(f)] = {
            kind = "self",
            amount = f.entrega,
            factor = 1,
            substitutes = f.sustitutos
        }
    end
end

return prices
