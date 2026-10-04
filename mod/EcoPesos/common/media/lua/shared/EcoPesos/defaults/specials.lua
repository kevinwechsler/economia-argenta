-- Pagos del "Compro Oro": lo que recibe el jugador al entregar una joya.
--
-- `adjustBalance` con pool "change" pasa por Core.currencyValueOf, que con
-- nuestra `currency_base` (Base.Money, factor 0.01) convierte los centavos en
-- billetes fisicos agregados al inventario. 1500 centavos = 15 billetes.
--
-- FactorCompraOro (sandbox) escala lo que paga el comprador sin tocar los
-- precios de las tiendas.
local function factorCompra()
    local vars = SandboxVars and SandboxVars.EcoPesos
    local pct = vars and tonumber(vars.FactorCompraOro) or 100
    return pct / 100
end

local function pago(pesos)
    return {
        kind = "pawn",
        display = {
            texture = "Item_Money"
        },
        actions = {{
            type = "adjustBalance",
            pool = "change",
            amount = math.max(100, math.floor(pesos * 100 * factorCompra()))
        }}
    }
end

return {
    eco_pago_plata = pago(4),       -- joyas de plata, cubiertos de plata
    eco_pago_oro = pago(10),        -- joyas de oro, monedas
    eco_pago_relojes = pago(15),    -- relojes de bolsillo y de pulsera
    eco_pago_piedras = pago(40),    -- amatista, rubi, zafiro, esmeralda
    eco_pago_lingote_chico = pago(40),
    eco_pago_lingote = pago(100),
    eco_pago_diamante = pago(150)
}
