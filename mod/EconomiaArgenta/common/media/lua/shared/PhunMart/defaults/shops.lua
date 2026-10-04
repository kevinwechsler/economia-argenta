-- Tiendas de Economia Argenta.
--
-- probability = 0: nunca aparecen por conversion aleatoria de maquinas
-- expendedoras. Las coloca el admin (ver README: "Colocar una tienda").
--
-- Usan las maquinas expendedoras del motor. La clave de cada tienda tiene que
-- ser el CustomName del tile de su maquina (asi la reconoce el motor), por eso
-- se llaman PittyTheTool (Ferreteria), FinalAmendment (Armeria) y PrawnStars
-- (Compro Oro). El nombre en pantalla sale de las traducciones.
--
-- `powered = false`: funcionan sin electricidad.
local function tienda(def)
    def.probability = 0
    def.minDistance = 0
    def.powered = false
    return def
end

return {

    PittyTheTool = tienda({
        category = "PittyTheTool",
        background = "machine-pity-the-tool.png",
        sprites = {"phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27"},
        unpoweredSprites = {"phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31"},
        poolSets = {{
            keys = {{
                key = "pool_eco_ferreteria",
                weight = 1.0
            }}
        }}
    }),

    FinalAmendment = tienda({
        category = "FinalAmendment",
        background = "machine-final-amendment.png",
        sprites = {"phunmart_01_32", "phunmart_01_33", "phunmart_01_34", "phunmart_01_35"},
        unpoweredSprites = {"phunmart_01_36", "phunmart_01_37", "phunmart_01_38", "phunmart_01_39"},
        poolSets = {{
            keys = {{
                key = "pool_eco_armeria",
                weight = 1.0
            }}
        }}
    }),

    PrawnStars = tienda({
        category = "PrawnStars",
        background = "machine-prawn-stars.png",
        sprites = {"phunmart_03_32", "phunmart_03_33", "phunmart_03_34", "phunmart_03_35"},
        unpoweredSprites = {"phunmart_03_36", "phunmart_03_37", "phunmart_03_38", "phunmart_03_39"},
        poolSets = {{
            keys = {{
                key = "pool_eco_compro_oro",
                weight = 1.0
            }}
        }}
    })
}
