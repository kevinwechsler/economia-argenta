-- Retos individuales: hitos de kills que pagan pesos.
--
-- Se activan con la opcion de sandbox EcoPesos.RecompensasKills (encendida
-- por defecto). Cada jugador lleva su propio conteo y cobra cada reto una sola
-- vez por partida. Los billetes (Base.Money) van directo al inventario y
-- aparece un aviso en pantalla.
--
--   kills = N       reto unico: se cobra una vez al llegar a N
--   everyKills = N  reto recurrente: se cobra cada N kills a partir de ahi
--
-- "Corredores" son los zombies rapidos (sprinters). Solo cuentan si la
-- partida los tiene activados en el sandbox.
--
-- Un admin puede reemplazar esta tabla con PhunMart_TokenRewards.json en la
-- carpeta Lua del server (se carga completa, no se mezcla).
local vars = SandboxVars and SandboxVars.EcoPesos
if not (vars and vars.RecompensasKills) then
    return {}
end

local function pesos(n)
    return {{
        item = "Base.Money",
        amount = n
    }}
end

return {
    zombieKills = {{
        kills = 25,
        rewards = pesos(10)
    }, {
        kills = 100,
        rewards = pesos(25)
    }, {
        kills = 250,
        rewards = pesos(50)
    }, {
        kills = 500,
        rewards = pesos(100)
    }, {
        kills = 1000,
        rewards = pesos(200)
    }, {
        kills = 2500,
        rewards = pesos(400)
    }, {
        everyKills = 1000,
        rewards = pesos(100)
    }},

    sprinterKills = {{
        kills = 10,
        rewards = pesos(20)
    }, {
        kills = 50,
        rewards = pesos(60)
    }, {
        kills = 150,
        rewards = pesos(150)
    }}
}
