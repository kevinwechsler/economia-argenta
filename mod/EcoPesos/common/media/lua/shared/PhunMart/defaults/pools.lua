-- Pools de Eco Pesos.
--
-- `sticky = true` y sin `stock` en las ofertas: la tienda muestra SIEMPRE
-- todos los items del pool, con stock infinito (stockQty = -1). Es lo que
-- pidio el diseño: catalogo fijo, precios fijos, sin rotacion.
return {

    pool_eco_almacen = {
        sticky = true,
        sources = {
            groups = {"eco_conservas", "eco_secos", "eco_vicios"}
        }
    },

    pool_eco_ferreteria = {
        sticky = true,
        sources = {
            groups = {"eco_herramientas", "eco_botiquin", "eco_equipo", "eco_varios"}
        }
    },

    pool_eco_armeria = {
        sticky = true,
        sources = {
            groups = {"eco_blancas", "eco_fuego", "eco_municion"}
        }
    },

    pool_eco_compro_oro = {
        sticky = true,
        defaults = {
            price = "eco_entrega_1"
        },
        sources = {
            groups = {"eco_joyas_plata", "eco_joyas_oro", "eco_relojes", "eco_piedras", "eco_lingotes",
                      "eco_diamantes"}
        }
    }
}
