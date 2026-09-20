# guikit - Minecraft GUI framework (datapack)

A datapack framework port of the `guigenmc` logic (a JSON -> datapack generator).
Instead of describing menus in JSON, you write `.mcfunction` files and call `guikit:` functions.

Target: Minecraft Java **26.3** (`min_format` / `max_format` **121**). Older versions need a matching `pack.mcmeta` value.

## Mechanic (same as the source)
Widget items are stamped onto a `chest_minecart` with `item replace`. left-clicking moves the item out of the
cart, so `#guikit:fill` re-runs after every click to refill the empty slot. When the player
**left-clicks** one, the item lands in their inventory, `clear` detects it, the handler runs,
the item is removed, and the menu is redrawn if needed.

## Differences from the source
| guigenmc (generator) | guikit (framework) |
|---|---|
| JSON -> functions generated into one pack | Fixed core + **menu code you write** |
| All slots re-stamped every tick | Redrawn after **every click** (and whenever a handler sets `guikit.dirty=1`), skipped if the handler closed the menu |
| Cart found with `sort=nearest` | Cart bound to its player by **uid** (multiplayer safe) |
| Toggle/counter/cycle/random/cost/cooldown as text templates | Shared `guikit:widget/*` helpers |
| Menus live in the same pack | Menus can live in separate datapacks/namespaces (`#guikit:register`, ...) |

## Writing a menu
1. `#guikit:register` -> `data modify storage guikit:reg menus."ns:id" set value {alias:"ns_id", container:"chest_minecart"}`
2. `#guikit:fill` -> draws the current page (`guikit:widget/pad`, then `guikit:widget/draw`)
3. `#guikit:probe` -> **one line per clickable widget**: `{id, fn}` + `guikit:widget/probe`
4. `#guikit:clear_tags` -> `tag @s remove guikit.m.<alias>`
5. `function guikit:internal/clear_in`, then `data merge storage guikit:in {menu:"ns:id"}`, then
   `function guikit:api/open`

Full working example: the **`guikit-demo`** datapack (3 pages: state widgets on page 0/1 -- button,
toggle, counter, cycle, progress, nav, close, random, confirm; command buttons, radio, meter and
links to the container demos on page 2 -- plus tiny one-page menus for the ender chest and barrel
presets, a 5-slot hopper and a container registered by the demo itself). It adds its entries to the `#guikit:*` tags above from its own pack, so this core
pack contains no menus and its tags are empty. Install both, then `/function demo:open`.

> The five tag files here (`register`, `fill`, `probe`, `clear_tags`, `on_close`) must stay `{"values": []}` **without `replace: true`**,
> otherwise menu packs can no longer add themselves. They must exist even when empty: `function #guikit:fill` on a
> missing tag is an error.

## Container types (`container` in `#guikit:register`)
The `container` key of a menu (default `chest_minecart`) is a **name in the container registry**,
storage `guikit:reg containers.<name>`. If the name is not registered it is taken as a raw vanilla entity id
(27 slots, gray pad), exactly as before. Built-ins (`internal/containers_builtin`, filled on every load before
`#guikit:register` runs):

| name | entity | slots | pad | title |
| --- | --- | --- | --- | --- |
| `chest_minecart` | `chest_minecart` | 27 | gray | |
| `hopper_minecart` | `hopper_minecart` | 5 | gray | |
| `ender_chest` | `chest_minecart` | 27 | purple | Ender Chest |
| `barrel` | `chest_minecart` | 27 | brown | Barrel |
| `trapped_chest` | `chest_minecart` | 27 | red | Trapped Chest |
| `shulker_box` | `chest_minecart` | 27 | magenta | Shulker Box |
| `copper_chest` | `chest_minecart` | 27 | orange | Copper Chest |
| `oak_chest_boat`, `spruce_...`, `birch_...`, `jungle_...`, `acacia_...`, `dark_oak_...`, `mangrove_...`, `cherry_...` `_chest_boat`, `bamboo_chest_raft` | the same id | 27 | gray | |
| `donkey`, `mule` | the same id | 15 | gray | registered, **not usable yet** (see below) |

The themed ones are cosmetic: Minecraft has no ender chest / barrel **entity**, and the framework needs
`/summon` + `item replace entity @s container.N`, so they are a `chest_minecart` with a different pad and title.

**Register your own** from a `#guikit:register` listener (runs after the built-ins, so it can also replace one):

```mcfunction
data modify storage guikit:reg containers.shop set value {entity:"chest_minecart", slots:27, pad:"minecraft:cyan_stained_glass_pane", title:{text:"Shop"}}
data modify storage guikit:reg menus."ns:shop" set value {alias:"ns_shop", container:"shop"}
```

| key | meaning | default |
| --- | --- | --- |
| `entity` | vanilla entity id **without** `minecraft:`; must be in the entity type tag `#guikit:container` | the registry name |
| `slots` | inventory size: how many slots `widget/pad` fills (a cart never has more than 27) | `27` |
| `pad` | item id `widget/pad` puts in every slot | `minecraft:gray_stained_glass_pane` |
| `title` | optional **SNBT text component** (`{text:"Shop"}`), becomes the container title | none |

- **Chest boats / rafts** are in `#guikit:container`, but only minecarts follow their owner (`internal/follow`
  teleports `chest_minecart` and `hopper_minecart`). A boat stays where it was summoned, so the owner has to ride it:
  `ride @s mount <the owner's cart>` right after `api/open` (see `demo:click/open_chest_boat`; match the cart by
  `guikit.uid`, the nearest cart can belong to another player).
- **`donkey` / `mule`** are registered but deliberately not in `#guikit:container` (their inventory slot numbering
  under `container.N` is unconfirmed), so opening such a menu is refused by `internal/open_fail`. There is no `offset`
  key.
- Registry names are plain keys (`shop`, `ns_shop`); quote the path if you use a colon: `containers."ns:shop"`.
- `title` must be a compound, not `'{"text":"Shop"}'`: in 26.3 a quoted string is a plain string and the title
  would show the JSON itself.
- To use another entity type, add it to `#guikit:container` from your own pack (tag file without `replace: true`).
  Only vanilla entities whose inventory is addressed as `container.N` work. If the entity is not in the tag, or the
  summon fails, `api/open` removes what it created, tells the player *could not open the menu ...* and returns 0
  (before, such a cart would have stayed in the world forever).
- While a menu is open, `@s guikit.slots` is its slot count, e.g. `execute if score @s guikit.slots matches 27.. run ...`
  in a `#guikit:fill` listener. A widget aimed at a slot the cart does not have shows `could not draw widget`.
- A plain 27-slot gray `chest_minecart` keeps using the static `widget/pad_cart`; anything else is tagged
  `guikit.styled` at summon and filled by `widget/pad_cart_dyn` from the definition kept per owner uid
  (`guikit:cont bound.u<uid>`, dropped again by `api/close`).

## Widget helpers (`guikit:widget/*`)
`draw` `pad` `probe` `toggle` `counter` `cycle` `progress` `roll` `goto_page` `cooldown_start` `pay_item` `pay_score` `say`
`button` `button_probe` `radio` `meter_draw` `meter_probe` `sound` (see below)

## Conditions (`guikit:cond/check`)

```mcfunction
function guikit:internal/clear_cond
data merge storage guikit:cond {type:"score", obj:"coins", min:10}
function guikit:cond/check
execute if score #cond guikit.tmp matches 1 run say enough coins
```

Runs `as` the player. Result: `#cond guikit.tmp` = 1 / 0 (also the return value).

| type | keys | notes |
| --- | --- | --- |
| `score` | `obj`, optional `min`, `max` | an **unset** score fails |
| `item_count` | `item`, optional `min` (default 1) | plain id or `#tag` only, no `[components]`; widget items of the same type are not counted |
| `tag` | `tag` | |
| `gamemode` | `mode` | `survival` / `creative` / `adventure` / `spectator` |
| `advancement` | `adv` | e.g. `minecraft:story/root` |
| `predicate` | `pred` | any predicate, so anything not listed can still be a condition |
| `level` | optional `min`, `max` | XP **level** (the number above the hotbar, not a scoreboard); with neither key any level passes. Not verified in a live client |
| `all` | `of:[{...}, {...}]` | passes when **every** element passes (empty list passes); stops at the first failure |
| `any` | `of:[{...}, {...}]` | passes when **at least one** element passes (empty list fails); stops at the first pass |

```mcfunction
data merge storage guikit:cond {type:"all", of:[{type:"tag", tag:"vip"}, {type:"level", min:5}, {type:"tag", tag:"banned", not:1b}]}
function guikit:cond/check
```

`all`/`any` are one level deep: an element must be a plain type, an element that is itself `all`/`any` is not
evaluated and counts as **failed**. Every element can carry its own `not`, and so can the `all`/`any` itself.
A missing `of` fails (`not` is not applied to it).

`not:1b` inverts. An unknown `type` or a missing key **fails** (result 0), except that a `not:1b` next to an
unknown type / missing key flips that 0 to 1 (known quirk of the leaf types; the `all`/`any` path does not have it). Every type is its own small function
(`guikit:cond/t_*`); `min`/`max` are two open-ended ranges, never a closed `A..B`.
New key -> add it to `guikit:internal/clear_cond` and to `guikit:cond/load_cur` (that copy list is shared by buttons and by `all`/`any`).

## Command buttons (`guikit:widget/button`)

Three parts, each one line or one pair of lines:

1. **Definition**, in your `#guikit:register` listener (rebuilt on every reload):
   ```mcfunction
   data modify storage guikit:btn defs."ns:buy" set value {cmd:"function ns:buy", timer:1200, cond:{type:"score", obj:"coins", min:5}, deny:"You need 5 coins."}
   ```
2. **Draw**, in `#guikit:fill` (same keys as `widget/draw` minus `type`; call `clear_w` first):
   ```mcfunction
   data merge storage guikit:w {slot:14, item:"minecraft:iron_sword", id:"ns:buy", name:{text:"Buy",italic:false}, lore:[]}
   function guikit:widget/button
   ```
3. **Probe**, in `#guikit:probe`:
   ```mcfunction
   data merge storage guikit:p {id:"ns:buy"}
   function guikit:widget/button_probe with storage guikit:p
   ```

Definition keys:

| key | meaning |
| --- | --- |
| `cmd` | command run `as @s at @s`. Use `function ns:name` to run several commands |
| `url` | prints a clickable `open_url` link in chat instead (combine with `close:1b`, chat is hidden behind the menu) |
| `cond` | any condition from the table above (same keys, incl. `not`). Failing: `deny` message, nothing runs |
| `deny` | message when `cond` fails, default `Not available.` (no double quotes in it) |
| `cost` | `{obj:"coins", amount:5}` (score) or `{item:"minecraft:diamond", count:3}` (item, `count` defaults to 1). Charged after `cond` passed and before `cmd` / `url`; not enough -> `poor` message, nothing runs, nothing is taken |
| `poor` | message when the cost cannot be paid, default `You can't afford that.` (no double quotes) |
| `close` | `1b` = close the menu after the command |
| `timer` | reset the menu timeout to N ticks on a successful click |
| `locked_item` | what is drawn while `cond` fails **or the cost is not affordable** (default `minecraft:barrier`). Cosmetic: the click re-checks both |

Notes:
- `cmd` is macro-expanded raw. If it contains double quotes, write it as a single-quoted SNBT string:
  `cmd:'tellraw @s {"text":"hi"}'`.
- `cmd` runs with the permission level datapack functions get (`function-permission-level`, default 2), not the
  player's. **`cmd` / `url` must come from your menu code, never from player input** (command injection).
- An item `cost` first removes the widget items from the inventory (the clicked widget is still there while the
  click is handled), so a button that costs its own item type neither counts nor takes the widget instead of your
  items. The look check (`locked_item`) uses the same rule as the `item_count` condition. Score cost = `pay_score`,
  item cost = `pay_item`.
- A working example is on page 2 of `examples/guikit-demo` (`demo:apple`, `demo:coin`,
  `demo:sword`, `demo:vip`, `demo:lvl`, `demo:combo` = `all` condition + score cost, `demo:link`). `/function demo:open`, then navigate to page 2.

## Widget: single-select (`guikit:widget/radio`)
Generalizes `toggle` from a bool to N states: each option in the group calls it with its own
literal `value` (menu code decides which slot maps to which value -- same trust model as
`toggle` / `cycle`, no defs registry).

```mcfunction
function guikit:internal/clear_in
data merge storage guikit:in {obj:"mode", value:2}
function guikit:widget/radio
```

## Widget: clickable meter / rating bar (`guikit:widget/meter_draw`, `guikit:widget/meter_probe`)
Like `progress`, but the cells are clickable: clicking cell `i` (0-based) sets the objective
directly to `(i+1) * max / width` (floor division) instead of incrementing it. Three parts:

1. **Definition**, in your `#guikit:register` listener:
   ```mcfunction
   data modify storage guikit:mtr defs."ns:vol" set value {obj:"volume", width:5, max:5,
     full:"minecraft:lime_dye", empty:"minecraft:gray_dye", name:{text:"Volume",italic:false}}
   ```
2. **Draw**, in `#guikit:fill`:
   ```mcfunction
   data merge storage guikit:w {slot:20, id:"ns:vol"}
   function guikit:widget/meter_draw with storage guikit:w
   ```
3. **Probe**, in `#guikit:probe` -- **ONE registration per meter, not per cell**:
   ```mcfunction
   data merge storage guikit:p {id:"ns:vol"}
   function guikit:widget/meter_probe with storage guikit:p
   ```

Definition keys: `obj` (objective set on click), `width`/`max` (same scaling as `progress`),
`full`/`empty` (item ids for filled/empty cells), `name` (SNBT text component, same as
`progress`'s). Not verified in a live client.

## Widget: sound (`guikit:widget/sound`)
Plays a sound to the clicking player only (`ui` category, so it follows the client's Master volume
and nothing else). Call it from a click handler, `as @s at @s`:

```mcfunction
function guikit:internal/clear_in
data merge storage guikit:in {sound:"minecraft:ui.button.click", volume:1.0, pitch:1.0}
function guikit:widget/sound
```

`sound` is required (a missing one returns 0 and plays nothing); `volume` / `pitch` default to `1.0`.
It does not mark the menu dirty. `sound` is macro-expanded raw, so it must come from your menu code,
never from player input. Working example: `demo:click/sound` (via `demo:internal/click_pling`).

## API: redraw without reopening (`guikit:api/refresh`)
```mcfunction
execute as <player> run function guikit:api/refresh
```
For code **outside** guikit (another datapack, a `trigger` handler, a timer) that changed something the
menu shows. Result `1` = redraw scheduled, `0` = that player has no open menu (nothing is touched).
It only sets `guikit.dirty`; the redraw itself happens on the player's next `tick_player`, so calling it
several times in one tick still draws once. Widget handlers do not need it -- they already mark the
menu dirty.

## Hook: `#guikit:on_close`
Called at the end of `guikit:api/close`, `as` the player whose menu just closed, for cleanup of your own
per-menu state. **Two things to know before you write a listener:**
- `api/open` calls `api/close` in the middle of its own run to dispose a previous menu, so `on_close`
  also fires when the player merely **switches** menus. Only reset state that is safe to lose then.
- It runs *after* the cart is gone and the player's guikit scores are reset. Do not call `api/open` /
  `api/refresh` from a listener expecting the old menu to still exist.

Same rules as the other tags: must exist (even empty) and must not use `replace: true`. Example:
`demo:on_close` (disarms the danger button).

## Cooldown feedback (`guikit:internal/cd_notify`)
`widget/cooldown_start` returns `0` while a cooldown runs but tells the player nothing. To show the
remaining time (rounded up to whole seconds, `guikit.cd` counts ticks):
```mcfunction
execute unless function guikit:widget/cooldown_start run function guikit:internal/cd_notify
```
`cd_notify` reads `@s guikit.cd` directly and prints `[GUI] Wait Ns.` to that player. Not used by the demo.

## Validation status
- **`mecha .` passing does NOT mean the pack loads.** mecha 0.101 accepted `demo:click/lootbox` (now in `guikit-demo`) while
  **Minecraft 26.3 rejected it** (`Whilst parsing command on line 5 ... at position 48`, right before `run`).
  So mecha is not a substitute for loading the pack in the real game. It also does not validate macro
  lines (lines starting with `$`).
- **Verified in a real 26.3 client (from `latest.log`):** the only load error was `demo:click/lootbox` (in what is now `guikit-demo`).
  It used the pattern `execute if score ... matches A..B run give ...`. It was rewritten to use only
  open-ended ranges and a separate function per reward. The **exact grammar reason 26.3 rejects the old
  line was not identified**; the rewrite removes both suspects (the closed range and `run give`).
  Re-load the pack in 26.3 and check `latest.log` to confirm.
- **`data modify storage X {} set value {...}` was removed.** It parses (mecha and the wiki's NBT-path table
  accept `{}` as the root path) but in a real 26.3 game it did not write: the run reported "nothing changed"
  and the storage stayed untouched. The exact 26.3 rule behind this was **not identified**. All 43 uses were
  replaced by `data merge storage X {...}`.
- **`merge` keeps old keys**, and `data remove storage X` needs a path, so scratch storages are cleared key by
  key with `guikit:internal/clear_in` / `clear_w` before each merge. Otherwise keys like `wrap`, `min`,
  `max` from a previous widget call would leak into the next one (e.g. into `counter_step`).
  When you add a new key to a `guikit:in` / `guikit:w` call, add it to the matching `clear_*` function too.
- **Conditions / command buttons (`cond/*`, `widget/button*`, `internal/btn_*`):** `mecha .` passes and every macro
  line was expanded with sample values and re-linted with mecha (all parse). That is all that was checked:
  **mecha does not catch everything here**: it accepted `if data storage guikit:btn cur {close:1b}` (path, space, compound)
  which 26.3 rejects at load (`Incorrect argument for command`). A compound filter on a non-root path must be
  attached to it: `cur{close:1b}`. Fixed. Loaded in a real 26.3 client: only that load error was seen; clicks, cond
  types and the demo menu are still untested. Check `latest.log`, and try each cond type once.
  Root-level `data modify storage X {} ...` is avoided (buttons copy `cond` key by key).
- **`cond` type `level`, `widget/sound`, `api/refresh`, `#guikit:on_close`, `internal/cd_notify` are new and**
  **untested beyond `mecha .`** (which does not validate macro lines). Specifically unchecked in a real 26.3
  client: `experience query @s levels` storing into a score, `playsound ... ui @s` argument order, the
  `execute unless function ...` form used in the `cd_notify` example, and the `on_close` firing on
  menu switch described above.
- **`all` / `any` conditions, button `cost` / `poor`, the `guikit.drop` detection branch in `tick_player`, chest boats /
  rafts and the hopper `follow` are new and untested beyond `mecha .`** (all 83 macro lines in the pack were also
  expanded with sample values and linted). Not checked in a real client: the `comp_step` recursion, the `cnd` scratch
  storage, `cost` charging order (cond -> cost -> cmd), whether a boat can be ridden while the menu is open, and
  whether the `minecraft.custom:minecraft.drop` statistic reacts to Q-dropping a widget out of the cart.
- **Still not done:** behavior in a real game (`clear` + `custom_data` match, `summon`, tick ordering,
  multiplayer). Only the load step has been observed.
- **The container registry (`internal/containers_builtin`, `summon`, `pad_cart_dyn`, `open_fail`), the `radio`/`meter`
  widgets and the container demos are new and untested beyond `mecha .`** (which does not validate macro lines and is
  not a substitute for loading the pack; the macro lines were expanded with sample values and linted). Not checked in
  a real client: whether a `CustomName` changes the container screen title, the 5-slot hopper menu, the
  `guikit.styled` pad path (recursion in `pad_step`), the `open_fail` rollback, and the full `meter_probe` recursion.

## Temporary storage / path cleanup

Scratch state is wiped so one menu session cannot leak into the next.

| when | what | function |
| --- | --- | --- |
| menu closes (`api/close`) | `guikit:w`, `guikit:cond`, `guikit:ctx` (`menu`, `alias`, `ctype`), `guikit:p`, `guikit:mtr` scratch keys | `guikit:internal/cleanup_player` |
| end of every button click | `guikit:btn cur` | `guikit:internal/clear_btn_cur` |
| end of `api/open` | `guikit:ctx` `menu` / `alias` | inline |
| every `/reload` | all of the above + `guikit:in` + every transient fake-player score (`#uid`, `#hit`, `#gui`, `#wcount`, the `#m*` meter temps, ...) | `guikit:internal/cleanup_scores` |
| every `/reload` | carts whose owner is gone (relog / death / uid lost) are disposed | `guikit:internal/sweep_orphans` |

Never touched: `guikit:reg menus` and `guikit:btn defs` (rebuilt by `#guikit:register` on load),
`#next_uid` / `#version` (uid counter must stay unique across reloads).

Two ordering traps this design avoids (both are easy to reintroduce):
- `api/open` calls `api/close` in the middle of its own run, then reads `guikit:in`. So `cleanup_player`
  must **not** clear `guikit:in`.
- A button `cmd` may be `function guikit:api/close`, and `btn_click` reads `guikit:btn cur` after the command.
  So `api/close` must **not** clear `guikit:btn cur`; `btn_click` clears it itself at the end.

The `cleanup_scores` list was never exhaustive (`progress`'s own `#f`/`#i`/`#d`/`#f2`/`#abs` aren't
in it either) -- every temp score is always overwritten before it's read, so this is hygiene on
`/reload`, not a correctness fix.

## Inventory-wipe bug -- STATUS: NOT PROVEN

Reported: running `/function cmddemo:open` (now page 2 of `demo:open`) clears the player's inventory (it should
only ever remove a widget item after a GUI click).

**The root cause was not identified by reading the code.** Every `clear` in the pack is filtered by
`custom_data~{guikit:{w:1b}}`, none targets a plain inventory. Working hypothesis (unverified): in 26.3 the
`*[custom_data~{...}]` filter is not applied as expected, so `clear @s *[...]` wipes everything. That fits
"it happens right after open" because `tick_player` used to run an unconditional `clear` every tick.

What changed, regardless of the cause:
- The unconditional `clear` every tick is gone. Deletion now happens only after a count (`clear ... 0`) reports >= 1,
  and only through `guikit:internal/safe_clear` (the same count-then-delete pattern was already used by
  `widget/probe`, `widget/button_probe` and `internal/meter_hit` -- the fix is specifically the old *unconditional*
  `clear` at the end of `tick_player` / inside `api/close`).
- Added `guikit:internal/selftest`. **Run it once in a real 26.3 world:**
  `/execute as @s run function guikit:internal/selftest`
  - `PASS` -> the filter works; the wipe has another cause (please send `latest.log` and the exact steps).
  - `FAIL - filter matches NON-widget items` -> hypothesis confirmed; the `*[custom_data~...]` form must be replaced.
  Note: `selftest` uses `give`, so test in a world where a stray stick is acceptable.

Not verified in a real game: everything in this section. `mecha .` passes, and every `function guikit:` reference
resolves, but per the validation notes above that does not prove the pack loads or behaves correctly.

## Known limits
- `guikit:widget/pad` always stamps 27 slots -> **do not use with `hopper_minecart`** (5 slots).
- If a menu draws a widget under `execute if score ... matches N run function guikit:internal/clear_w` + `... run data merge`
  and no range matches, `guikit:w` is empty and `guikit:widget/draw` fails on missing macro arguments instead of
  redrawing the previous widget. Initialize scores before drawing.
- `name` / `lore` are **SNBT text components**, not JSON strings: `name:{text:"Bob's",color:"gold",italic:false}`,
  `lore:[{text:"line",color:"gray",italic:false}]`, `lore:[]`. In 26.3 a *quoted* string such as
  `custom_name='{"text":" "}'` is a plain string, so the tooltip shows the JSON text literally (that is what the pad
  panes did before this fix). Compound values are expanded into the macro as SNBT, so `'` in text needs no escaping.
  If a widget cannot be placed, `widget/draw` now tells nearby players `could not draw widget <id> in slot N`.
- `confirm` is simplified (in `guikit-demo`) to a "click twice to confirm" flow instead of a separate page as in the source.
- `cond` on a button is evaluated on every redraw (once per button) and again on click; keep conditions cheap.
- The older `pay_item` helper also counts the clicked widget item when it is the same item type as the price
  (`clear` runs while the widget is still in the inventory). `cond` type `item_count` subtracts widget items.
