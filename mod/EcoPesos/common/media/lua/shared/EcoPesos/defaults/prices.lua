-- Precios de Eco Pesos.
--
-- La moneda es el billete vanilla `Base.Money` (1 billete = 1 peso). PhunMart
-- escribe todos sus montos en centavos, asi que `currency_base` usa factor
-- 0.01 para que 100 centavos = 1 billete. Encima de eso aplicamos el
-- FactorPrecios de sandbox (100 = precios normales, 200 = todo el doble).
--
-- Al redefinir `currency_base` aca, TODOS los precios de PhunMart que heredan
-- de el pasan a cobrarse en billetes, y los pagos de "compro oro"
-- (adjustBalance) tambien se entregan como billetes fisicos.
local function factorPrecios()
    local vars = SandboxVars and SandboxVars.EcoPesos
    local pct = vars and tonumber(vars.FactorPrecios) or 100
    return 0.01 * (pct / 100)
end

--- Precio en pesos (billetes), escrito en centavos para seguir la convencion
--- de PhunMart. El factor de `currency_base` lo convierte a billetes.
local function pesos(n)
    return {
        inherit = "currency_base",
        amount = n * 100
    }
end

return {

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

    -- Escalera de precios en pesos. Las tiendas y los items referencian estas
    -- claves por nombre.
    eco_1 = pesos(1),
    eco_2 = pesos(2),
    eco_3 = pesos(3),
    eco_5 = pesos(5),
    eco_8 = pesos(8),
    eco_10 = pesos(10),
    eco_15 = pesos(15),
    eco_20 = pesos(20),
    eco_30 = pesos(30),
    eco_40 = pesos(40),
    eco_60 = pesos(60),
    eco_80 = pesos(80),
    eco_100 = pesos(100),
    eco_150 = pesos(150),
    eco_200 = pesos(200),
    eco_250 = pesos(250),
    eco_300 = pesos(300),
    eco_400 = pesos(400),
    eco_500 = pesos(500),

    -- "self": el jugador entrega 1 unidad del item mostrado (compro oro).
    eco_entrega_1 = {
        kind = "self",
        amount = 1,
        factor = 1
    }
}
