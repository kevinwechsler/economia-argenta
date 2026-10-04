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

return {
    eco_pago_1 = pago(1),
    eco_pago_2 = pago(2),
    eco_pago_6 = pago(6),
    eco_pago_10 = pago(10),
    eco_pago_20 = pago(20)
}
