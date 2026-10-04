-- Cuantos billetes hay en el mundo.
--
-- En Economia Argenta un billete vale mucho (5 = una caja de balas), asi que
-- se baja la probabilidad de que aparezcan en cajas registradoras, bancos,
-- carteras, zombies y autos. Los fajos (100 billetes) se sacan por completo:
-- uno solo romperia la economia.
--
-- Opciones de sandbox:
--   EconomiaArgenta.CantidadBilletes  porcentaje de la probabilidad vanilla
--                                      (15 = la sexta parte de lo normal)
--   EconomiaArgenta.FajosEnElMundo     si queda en false, no aparecen fajos
--
-- Se aplica despues de que el juego arma sus tablas de loot y antes de que
-- las use, asi que vale para cualquier partida nueva o zona sin explorar.
if isClient() then
    return
end

local function opciones()
    local vars = SandboxVars and SandboxVars.EconomiaArgenta or {}
    local pct = tonumber(vars.CantidadBilletes) or 15
    return pct / 100, vars.FajosEnElMundo == true
end

--- Recorre una tabla de loot y escala los pesos de Money y MoneyBundle.
--- Las listas de loot son {"Item", peso, "Item", peso, ...}.
local function ajustar(t, factor, fajos, visto, stats)
    if type(t) ~= "table" or visto[t] then
        return
    end
    visto[t] = true

    local items = t.items
    if type(items) == "table" then
        for i = 1, #items - 1, 2 do
            local nombre, peso = items[i], items[i + 1]
            if type(peso) == "number" then
                if nombre == "Money" or nombre == "Base.Money" then
                    items[i + 1] = peso * factor
                    stats.billetes = stats.billetes + 1
                elseif nombre == "MoneyBundle" or nombre == "Base.MoneyBundle" then
                    items[i + 1] = fajos and peso * factor or 0
                    stats.fajos = stats.fajos + 1
                end
            end
        end
    end

    for _, v in pairs(t) do
        if type(v) == "table" then
            ajustar(v, factor, fajos, visto, stats)
        end
    end
end

Events.OnPostDistributionMerge.Add(function()
    local factor, fajos = opciones()
    local visto = {}
    local stats = {
        billetes = 0,
        fajos = 0
    }
    if ProceduralDistributions and ProceduralDistributions.list then
        ajustar(ProceduralDistributions.list, factor, fajos, visto, stats)
    end
    if SuburbsDistributions then
        ajustar(SuburbsDistributions, factor, fajos, visto, stats)
    end
    if VehicleDistributions then
        ajustar(VehicleDistributions, factor, fajos, visto, stats)
    end
    print("[EconomiaArgenta] billetes al " .. math.floor(factor * 100) .. "%: " .. stats.billetes ..
              " entradas de billetes, " .. stats.fajos .. " de fajos" .. (fajos and "" or " (fajos quitados)"))
end)
