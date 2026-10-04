-- Tiendas de Eco Pesos.
--
-- probability = 0: nunca aparecen por conversion aleatoria de maquinas
-- expendedoras. Las coloca el admin (ver README: "Colocar una tienda").
--
-- v0.1 reutiliza los sprites y fondos de PhunMart para poder jugar ya. El
-- arte propio de "mostrador con vendedor" llega en una version siguiente con
-- un tile pack propio (ver Docs/MACHINE_ART.md de PhunMart).
--
-- `powered = false`: funcionan sin electricidad, como un vendedor humano.
local function tienda(def)
    def.probability = 0
    def.minDistance = 0
    def.powered = false
    return def
end

return {

    EcoAlmacen = tienda({
        category = "EcoAlmacen",
        background = "machine-good-phoods.png",
        sprites = {"phunmart_01_8", "phunmart_01_9", "phunmart_01_10", "phunmart_01_11"},
        unpoweredSprites = {"phunmart_01_12", "phunmart_01_13", "phunmart_01_14", "phunmart_01_15"},
        poolSets = {{
            keys = {{
                key = "pool_eco_almacen",
                weight = 1.0
            }}
        }}
    }),

    EcoFerreteria = tienda({
        category = "EcoFerreteria",
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

    EcoArmeria = tienda({
        category = "EcoArmeria",
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

    EcoComproOro = tienda({
        category = "EcoComproOro",
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
