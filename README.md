# guikit - Minecraft GUI framework (datapack)

A datapack framework port of the `guigenmc` logic (a JSON -> datapack generator).
Instead of describing menus in JSON, you write `.mcfunction` files and call `guikit:` functions.

Target: Minecraft Java **26.3** (`min_format` / `max_format` **121**). Older versions need a matching `pack.mcmeta` value.

## Mechanic (same as the source)
Widget items are stamped onto a `chest_minecart` with `item replace`. Shift-clicking moves the item out of the
cart, so `#guikit:fill` re-runs after every click to refill the empty slot. When the player
**shift-clicks** one, the item lands in their inventory, `clear` detects it, the handler runs,
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
links to the themed sub-menus on page 2 -- plus two tiny one-page menus, one per themed container
preset). It adds its entries to the four `#guikit:*` tags above from its own pack, so this core
pack contains no menus and its tags are empty. Install both, then `/function demo:open`.

> The four tag files here (`register`, `fill`, `probe`, `clear_tags`) must stay `{"values": []}` **without `replace: true`**,
> otherwise menu packs can no longer add themselves. They must exist even when empty: `function #guikit:fill` on a
> missing tag is an error.

## Container types (`container` in `#guikit:register`)
The `container` key on a menu (default `chest_minecart`) is normally passed straight to
`/summon minecraft:<container>`, so any entity with slot-indexed inventory works (`chest_minecart`,
`hopper_minecart`, ...). Two extra values are recognized as **themed presets**, not real entity
types:

| `container` | underlying entity | slots | pad color |
| --- | --- | --- | --- |
| `"ender_chest"` | `chest_minecart` | 27 | purple |
| `"barrel"` | `chest_minecart` | 27 | brown |

Minecraft has no `ender_chest` or `barrel` **entity** -- only the blocks -- and the whole
framework depends on `/summon minecraft:<type>` + `item replace entity @s container.N`, which only
works on entities. So both presets summon the real `chest_minecart` (27 slots, the same inventory
size as a real ender chest or barrel) and are tagged `guikit.theme.ender_chest` /
`guikit.theme.barrel` + given a matching `CustomName`, so `widget/pad` draws purple/brown panes
instead of gray. **Not verified in a live client**: whether `CustomName` actually changes a
minecart's container screen title was not checked against a real 26.3 client (see "Validation
status"); if it doesn't, the menu is still fully functional, just titled "Minecart with Chest".
See `internal/summon_themed`.

## Widget helpers (`guikit:widget/*`)
`draw` `pad` `probe` `toggle` `counter` `cycle` `progress` `roll` `goto_page` `cooldown_start` `pay_item` `pay_score` `say`
`button` `button_probe` `radio` `meter_draw` `meter_probe` (see below)

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

`not:1b` inverts. An unknown `type` or a missing key **fails** (result 0). Every type is its own small function
(`guikit:cond/t_*`); `min`/`max` are two open-ended ranges, never a closed `A..B`.
New key -> add it to `guikit:internal/clear_cond` (and to `guikit:internal/btn_cond` if buttons should support it).

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
| `close` | `1b` = close the menu after the command |
| `timer` | reset the menu timeout to N ticks on a successful click |
| `locked_item` | what is drawn while `cond` fails (default `minecraft:barrier`). Cosmetic: the click re-checks `cond` |

Notes:
- `cmd` is macro-expanded raw. If it contains double quotes, write it as a single-quoted SNBT string:
  `cmd:'tellraw @s {"text":"hi"}'`.
- `cmd` runs with the permission level datapack functions get (`function-permission-level`, default 2), not the
  player's. **`cmd` / `url` must come from your menu code, never from player input** (command injection).
- A working example is on page 2 of `examples/guikit-demo` (`demo:apple`, `demo:coin`,
  `demo:sword`, `demo:vip`, `demo:link`). `/function demo:open`, then navigate to page 2.

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
- **Still not done:** behavior in a real game (`clear` + `custom_data` match, `summon`, tick ordering,
  multiplayer). Only the load step has been observed.
- **`ender_chest`/`barrel` container themes and the `radio`/`meter` widgets are new and untested
  beyond `mecha .` passing** (which, per above, does not validate macro lines and is not a
  substitute for loading the pack). In particular: whether entity `CustomName` changes a
  `chest_minecart`'s container screen title, and the full `meter_probe` recursion (defs lookup,
  per-cell `clear` test, scaled value write) have not been checked against a real client.

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
