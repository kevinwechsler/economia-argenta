# Economía Argenta: mod de economía para Project Zomboid (Build 42)

Mod de economía para jugar con amigos en un server. **Es un mod independiente**:
no requiere ningún otro mod. El motor de tiendas (interfaz, compra segura en
multiplayer, colocación de tiendas y panel de admin) viene de
[PhunMart 2](https://github.com/PhunZoider/PhunMart) de UburGeek / PhunZoider,
incluido y adaptado bajo su licencia GPL-3.0. Economía Argenta también es
GPL-3.0 (ver [LICENSE](LICENSE)).

## Reglas del juego

| Regla | Cómo se resuelve |
|---|---|
| La plata se encuentra en el mundo | Billete vanilla `Base.Money`. Aparece mucho menos que en el juego normal (sandbox `CantidadBilletes`, 15% por defecto) y sin fajos. |
| Un billete vale mucho | 5 billetes = una caja de balas, ~15 = una pistola, 100+ = un rifle de asalto. Nadie carga cientos. |
| Joyas y monedas se canjean | **Compro Oro**: plata 5 por 1 billete, oro 2 por 1, piedras, lingotes y diamantes pagan más. |
| Solo se compran ciertas cosas | **Armería** (armas, munición, cargadores, accesorios) y **Ferretería** (consumibles chicos para construir). Sin comida, herramientas, bolsos ni ropa. |
| Stock infinito, precios fijos | Pools `sticky` sin stock. |
| Si morís, la plata queda en el cuerpo | Los billetes son un item físico. |
| NO se pueden vender items | Solo el Compro Oro acepta joyas. |
| Tiendas fijas | Las coloca el admin a mano. |
| Retos individuales | Kills, días sin morir, inicio limpio y habilidades: se cobran con el botón "Reclamar" de la pestaña Retos (tecla 0). "Primero del server": se paga solo al primero, con aviso a todos. |

## Dónde se toca cada cosa

| Qué | Archivo |
|---|---|
| Qué vende cada tienda y a cuánto | `media/lua/shared/PhunMart/defaults/catalogo.lua` (único lugar de precios) |
| Objetivos y premios de TODOS los retos | `media/lua/shared/EconomiaArgenta/retos_def.lua` (único lugar) |
| Cobro de retos (server) | `media/lua/server/EconomiaArgenta/retos.lua` y, para kills, `defaults/token_rewards.lua` |
| Pestaña "Retos" (tecla 0) | `media/lua/client/EconomiaArgenta/retos_tab.lua` |
| Cambiar precios desde el juego (admin) | Click derecho sobre un producto en la tienda → "Cambiar precio…" / "Cambiar pago…" / "Volver al precio original". Código: `media/lua/server/EconomiaArgenta/precios_admin.lua`. Se guarda en `Zomboid/Lua/PhunMart_Items.json` del server |
| Cuántos billetes hay en el mundo | `media/lua/server/EconomiaArgenta/billetes.lua` + sandbox |
| Opciones de la partida | `media/sandbox-options.txt` (página "Economía Argenta") |
| Textos | `media/lua/shared/Translate/{AR,ES,EN}/` (el juego en "Español (Argentina)" usa AR) |
| Ícono del billete | El del juego. Hubo una prueba con un billete de pesos (`arte/`), descartada porque a 32px no se entendía |

Todo bajo `mod/EconomiaArgenta/common/`. El motor vive en
`media/lua/{client,server,shared}/PhunMart*` (nombre interno, no se cambia
para no romperlo).

## Probar en local

1. Copiar el mod al juego:

```bash
powershell -ExecutionPolicy Bypass -File deploy.ps1
```

2. Steam → Project Zomboid → Propiedades → Configuraciones de lanzamiento: `-debug`.
3. En el juego, Mods → activar **Economía Argenta** → partida nueva.

## Colocar una tienda

1. Menú de debug → **Items List** → buscar `Armería`, `Ferretería` o `Compro Oro`.
2. Agregarla al inventario y colocarla en el piso como un mueble.
3. Click derecho sobre la máquina → **Ver Armería** (o la que sea).

En server se hace igual con un usuario admin.

Nota técnica: el motor reconoce cada tienda por el `CustomName` del tile de la
máquina, por eso las claves en `shops.lua` son `PittyTheTool` (Ferretería),
`FinalAmendment` (Armería) y `PrawnStars` (Compro Oro).

## Validar sin abrir el juego

Necesita LuaJIT (`winget install --id DEVCOM.LuaJIT --source winget`).

```bash
& "$env:LOCALAPPDATA\Programs\LuaJIT\bin\luajit.exe" tests\test_compile.lua
```

```bash
& "$env:LOCALAPPDATA\Programs\LuaJIT\bin\luajit.exe" tests\test_retos_tab.lua
```

```bash
& "$env:LOCALAPPDATA\Programs\LuaJIT\bin\luajit.exe" tests\test_retos_server.lua
```

## Probar los retos rápido

En las opciones de la partida, página "Economía Argenta", prender **Modo
prueba de retos**:
- divide por 50 los objetivos de kills y días (50 kills = 1, 3 días = 1,4
  horas de juego),
- baja las habilidades pedidas a nivel 1,
- los retos se revisan cada minuto (siempre, no solo en modo prueba).

La pestaña Retos (tecla 0) muestra un aviso rojo mientras está prendido.
Apagarlo antes de jugar en serio.

Importante: todos los archivos de texto tienen que ser UTF-8 **sin BOM**; el
juego no arranca si no. `deploy.ps1` lo controla.

## Créditos

- Motor de tiendas: PhunMart 2 por UburGeek / PhunZoider,
  https://github.com/PhunZoider/PhunMart (GPL-3.0). Modificado: catálogos,
  moneda, opciones, textos y retos propios; sin billetera, XP, traits,
  vehículos ni animales.
- Economía Argenta por Kevin.
