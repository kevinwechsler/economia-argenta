# Eco Pesos: economía argentina para Project Zomboid (Build 42)

Mod de economía para jugar con amigos en un server. **Es un mod independiente**:
no requiere ningún otro mod. El motor de tiendas (interfaz, compra segura en
multiplayer, colocación de tiendas y panel de admin) viene de
[PhunMart 2](https://github.com/PhunZoider/PhunMart) de UburGeek / PhunZoider,
incluido y adaptado bajo su licencia GPL-3.0. Eco Pesos también es GPL-3.0
(ver [LICENSE](LICENSE)).

## Reglas del juego

| Regla | Cómo se resuelve |
|---|---|
| La plata se encuentra en el mundo, no se gana matando zombies | La moneda es el billete vanilla `Base.Money`. Ya aparece en cajas registradoras, bancos, lockers, carteras y zombies "de clase alta". Los pagos de zombies del motor vienen apagados. |
| Joyas, piedras y lingotes se canjean por plata | Tienda **Compro Oro**: entregás el item y recibís billetes físicos. |
| Solo se compran ciertas armas, equipo y comida | Tres tiendas con catálogo fijo: **Almacén**, **Ferretería**, **Armería**. |
| Stock infinito, precios fijos | Pools `sticky` sin stock. |
| Si morís, la plata queda en el cuerpo | Gratis: los billetes son un item físico en el inventario del cadáver. |
| NO se pueden vender items | No existe esa opción. Solo el Compro Oro acepta joyas. |
| Tiendas fijas en cada ciudad | `probability = 0` y conversión de expendedoras en 0: las coloca el admin a mano. |
| Ajustes desde la UI | Sandbox "Eco Pesos": factor de precios, factor del Compro Oro, recompensas por kills. El panel de admin del motor permite editar precios y catálogo dentro del juego. |
| Recompensas por kills (opcional) | Apagado por defecto. Paga billetes en hitos de kills. |

Pendientes: intercambio entre jugadores con ventana, billetes con estética de
pesos, arte propio de mostrador con vendedor, traducción al español del resto
de la interfaz del motor.

## Estructura

```
mod/EcoPesos/common/
  mod.info                                  id=EcoPesos (sin dependencias)
  media/sandbox-options.txt                 opciones del motor (página "Eco Pesos - Motor") + las nuestras (página "Eco Pesos")
  media/lua/shared/PhunMart/defaults/       LAS REGLAS DE ECO PESOS (lo que más vas a tocar)
    prices.lua        moneda = Base.Money y escalera de precios eco_N
    specials.lua      cuánto paga el Compro Oro
    groups.lua        qué vende cada tienda
    items.lua         precios por item (pisan al del grupo)
    pools.lua         pools fijos (sticky)
    shops.lua         las 4 tiendas
    token_rewards.lua hitos de kills (opcional)
    conditions.lua, blacklist.lua   del motor, sin uso especial
  media/lua/shared/PhunMart/                motor: compilador, moneda, utilidades
  media/lua/server/PhunMart_Server/         motor: lado servidor (compras, stock, colocación)
  media/lua/client/PhunMart_Client/         motor: interfaz de tienda y panel de admin
  media/lua/shared/Translate/{EN,ES}/       textos
  media/scripts/, textures/, texturepacks/  items y arte de las máquinas (del motor)
tests/test_compile.lua                      compila las definiciones con el compilador real
tests/harness/harness.lua                   simula el runtime del juego (del motor)
ref/PhunMart/                               clon original de referencia (ignorado por git)
```

## Probar en local (single player)

1. Copiar el mod a la carpeta de mods del juego:

```bash
powershell -ExecutionPolicy Bypass -File deploy.ps1
```

2. Abrir el juego → Mods → activar **Eco Pesos**.
3. Nueva partida. Las opciones de sandbox ya vienen configuradas; en la página
   **Eco Pesos** podés tocar los factores.
4. Entrar con `-debug` (propiedades del juego en Steam → opciones de
   lanzamiento) para tener el menú de admin en single player.

## Colocar una tienda

El juego tiene que estar en modo debug (Steam → Project Zomboid →
Propiedades → Opciones de lanzamiento: `-debug`).

1. En la partida, menú de debug → **Items List** → buscar `Eco Tienda`.
2. Agregar al inventario la que quieras: Almacén, Ferretería, Armería o
   Compro Oro.
3. Colocarla en el piso como un mueble.
4. Click derecho sobre la máquina → **View Almacén** (o la que sea) → se
   abre la tienda.

En server se hace igual con un usuario admin.

Nota técnica: el motor reconoce cada tienda por el nombre interno del tile
del mueble (`CustomName`). Por eso las claves en `shops.lua` son
`GoodPhoods`, `PittyTheTool`, `FinalAmendment` y `PrawnStars`, aunque en
pantalla se llamen Almacén, Ferretería, Armería y Compro Oro.

## Validar sin abrir el juego

Necesita LuaJIT (`winget install --id DEVCOM.LuaJIT --source winget`).

```bash
& "$env:LOCALAPPDATA\Programs\LuaJIT\bin\luajit.exe" tests\test_compile.lua
```

## Convenciones de precios

El motor escribe montos en centavos. `currency_base` tiene `factor = 0.01`,
así que `amount = 500` son 5 billetes. Los helpers `pesos(n)` en `prices.lua`
y `pago(n)` en `specials.lua` ya hacen esa cuenta: escribí siempre en pesos.
Los items en `groups.lua` e `items.lua` van por nombre pelado (`Shotgun`,
no `Base.Shotgun`).

## Créditos

- Motor de tiendas: PhunMart 2 por UburGeek / PhunZoider,
  https://github.com/PhunZoider/PhunMart (GPL-3.0). Modificado para Eco Pesos:
  catálogos, moneda, opciones por defecto y textos propios; sin XP, traits ni
  animales.
- Eco Pesos por Kevin.
