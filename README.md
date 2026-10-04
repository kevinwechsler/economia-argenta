# Eco Pesos: economía argentina para Project Zomboid (Build 42)

Mod de economía para jugar con amigos en un server. Es una **capa sobre
[PhunMart 2](https://steamcommunity.com/sharedfiles/filedetails/?id=3689006725)**
(de UburGeek / PhunZoider, GPL-3.0): no copia su código, usa su API oficial de
extensión. PhunMart resuelve el multiplayer, la interfaz de tienda y las
herramientas de admin; Eco Pesos define las reglas.

## Reglas del juego

| Regla | Cómo se resuelve |
|---|---|
| La plata se encuentra en el mundo, no se gana matando zombies | La moneda es el billete vanilla `Base.Money`. Ya aparece en cajas registradoras, bancos, lockers, carteras y zombies "de clase alta". PhunMart queda con `EnableChangePool = false`. |
| Joyas, piedras y lingotes se canjean por plata | Tienda **Compro Oro**: entregás el item y recibís billetes físicos. |
| Solo se compran ciertas armas, equipo y comida | Tres tiendas con catálogo fijo: **Almacén**, **Ferretería**, **Armería**. |
| Stock infinito, precios fijos | Pools `sticky` sin stock. |
| Si morís, la plata queda en el cuerpo | Gratis: los billetes son un item físico en el inventario del cadáver. |
| NO se pueden vender items | No existe esa opción. Solo el Compro Oro acepta joyas. |
| Tiendas fijas en cada ciudad | `probability = 0`: las coloca el admin a mano. |
| Ajustes desde la UI | Sandbox: factor de precios, factor del Compro Oro, recompensas por kills. El panel de admin de PhunMart permite editar precios y catálogo en el juego. |
| Recompensas por kills (opcional) | Apagado por defecto. Paga billetes en hitos de kills. |

Pendientes: intercambio entre jugadores con ventana, billetes con estética de
pesos, arte propio de mostrador con vendedor.

## Estructura

```
mod/EcoPesos/common/
  mod.info                      id=EcoPesos, require=phunmart2
  media/sandbox-options.txt     opciones propias (página "Eco Pesos")
  media/lua/shared/EcoPesos/
    init.lua                    registra nuestros módulos en PhunMart
    defaults/prices.lua         currency_base = Base.Money + escalera eco_N
    defaults/specials.lua       pagos del Compro Oro
    defaults/groups.lua         qué vende cada tienda
    defaults/items.lua          precios por item
    defaults/pools.lua          pools fijos (sticky)
    defaults/shops.lua          las 4 tiendas
  media/lua/server/EcoPesos/rewards.lua   hitos de kills (opcional)
  media/lua/shared/Translate/{ES,EN}/     textos
ref/PhunMart/                   clon de referencia (ignorado por git)
```

## Probar en local (single player)

1. Suscribirse a PhunMart 2 en el Workshop (ID 3689006725) y dejar que Steam lo descargue.
2. Copiar el mod a la carpeta de mods del juego:

```bash
powershell -ExecutionPolicy Bypass -File deploy.ps1
```

3. Abrir el juego → Mods → activar **PhunMart 2** y **Eco Pesos**.
4. Nueva partida → Sandbox:
   - Página **PhunMart**: `EnableChangePool = false`, `ChanceToConvert = 0`
     (sin eso, los zombies sueltan monedas de PhunMart y las expendedoras se
     convierten en sus tiendas). `MaxStickyItems = 50` para que no avise en
     el log por los catálogos grandes (es solo un aviso, no rompe nada).
   - Página **Eco Pesos**: factores a gusto.
5. Entrar con `-debug` (propiedades del juego en Steam → opciones de
   lanzamiento) para tener el menú de admin en single player.

## Colocar una tienda (v0.1)

1. Con debug: menú de debug → **Items List** → buscar "Vending Machine" de
   PhunMart (por ejemplo "Collectors Vending Machine") → agregarlo al
   inventario → colocarlo como mueble en el lugar elegido.
2. Click derecho en la máquina → abrir tienda. Como admin aparece
   **Change to**: elegir `EcoAlmacen`, `EcoFerreteria`, `EcoArmeria` o
   `EcoComproOro`.
3. La máquina pasa a ser esa tienda y queda guardada en el mundo.

En server se hace igual con un usuario admin.

## Convenciones de precios

PhunMart escribe montos en centavos. `currency_base` tiene `factor = 0.01`,
así que `amount = 500` son 5 billetes. Los helpers `pesos(n)` en `prices.lua`
y `pago(n)` en `specials.lua` ya hacen esa cuenta: escribí siempre en pesos.

## Créditos

- PhunMart 2 por UburGeek / PhunZoider: https://github.com/PhunZoider/PhunMart (GPL-3.0).
- Eco Pesos por Kevin.
