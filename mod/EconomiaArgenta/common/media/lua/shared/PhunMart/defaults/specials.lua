-- Pagos del Compro Oro: lo que recibe el jugador al entregar joyas.
--
-- `adjustBalance` con pool "change" pasa por Core.currencyValueOf, que con
-- nuestra `currency_base` (Base.Money) convierte los centavos en billetes
-- fisicos. Como currencyValueOf tambien aplica FactorPrecios, aca se divide
-- por el para que el pago dependa solo de FactorCompraOro.
local function factor(name)
    local vars = SandboxVars and SandboxVars.EconomiaArgenta
    local pct = vars and tonumber(vars[name]) or 100
    return pct / 100
end

local function pago(billetes)
    local cents = billetes * 100 * factor("FactorCompraOro") / factor("FactorPrecios")
    return {
        kind = "pawn",
        display = {
            texture = "Item_Money"
        },
        actions = {{
            type = "adjustBalance",
            pool = "change",
            amount = math.max(100, math.floor(cents))
        }}
    }
end

-- eco_pago_1 .. eco_pago_999: el Compro Oro paga N billetes. El catalogo usa
-- algunos; el resto esta para que el admin pueda cambiar pagos desde la
-- tienda (server/EconomiaArgenta/precios_admin.lua).
local specials = {}
for n = 1, 999 do
    specials["eco_pago_" .. n] = pago(n)
end

return specials
