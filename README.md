# guikit - Minecraft GUI framework (datapack)

A datapack framework port of the `guigenmc` logic (a JSON -> datapack generator).
Instead of describing menus in JSON, you write `.mcfunction` files and call `guikit:` functions.

Target: Minecraft Java **1.21.5+** (`min_format` / `max_format` 119, same value the source used).

## Mechanic (same as the source)
Widget items are stamped onto a `chest_minecart` with `item replace`. When the player
**shift-clicks** one, the item lands in their inventory, `clear` detects it, the handler runs,
the item is removed, and the menu is redrawn if needed.

## Differences from the source
| guigenmc (generator) | guikit (framework) |
|---|---|
| JSON -> functions generated into one pack | Fixed core + **menu code you write** |
| All slots re-stamped every tick | Redrawn only while `guikit.dirty=1` |
| Cart found with `sort=nearest` | Cart bound to its player by **uid** (multiplayer safe) |
| Toggle/counter/cycle/random/cost/cooldown as text templates | Shared `guikit:widget/*` helpers |
| Menus live in the same pack | Menus can live in separate datapacks/namespaces (`#guikit:register`, ...) |

## Writing a menu
1. `#guikit:register` -> `data modify storage guikit:reg menus."ns:id" set value {alias:"ns_id", container:"chest_minecart"}`
2. `#guikit:fill` -> draws the current page (`guikit:widget/pad`, then `guikit:widget/draw`)
3. `#guikit:probe` -> **one line per clickable widget**: `{id, fn}` + `guikit:widget/probe`
4. `#guikit:clear_tags` -> `tag @s remove guikit.m.<alias>`
5. `storage guikit:in {menu:"ns:id"}` + `function guikit:api/open`

Full working example: `data/demo/` (2 pages; button, toggle, counter, cycle, progress, nav, close, random, confirm, cost, cooldown).
Open it with `/function demo:open`.

## Widget helpers (`guikit:widget/*`)
`draw` `pad` `probe` `toggle` `counter` `cycle` `progress` `roll` `goto_page` `cooldown_start` `pay_item` `pay_score` `say`

## Validation status
- **`mecha .` -> `Done!`, exit code 0.** However, mecha **does not validate macro lines** (lines starting with `$`).
  A deliberately broken `$scoreboard players zzzbroken` line also passed. So the 42 macro lines were
  additionally expanded with realistic values in place of `$(x)` and fed to mecha as plain commands -> all valid.
  This only covers the value sets that were tried.
- Static lint is clean. `counter` / `toggle` / `cycle` / `progress` arithmetic passed 15/15 in an interpreter simulation.
- **A real bug found and fixed in that pass:** `data modify storage X set value {...}` is invalid (`<path>` is
  required). 42 lines in 17 files were changed to `X {} set value`.
- **Still not done:** running it in a real Minecraft instance. Mecha checks syntax, not behavior
  (the `clear` + `custom_data` match, `summon`, tick ordering and multiplayer behavior are untested).

## Known limits
- `guikit:widget/pad` always stamps 27 slots -> **do not use with `hopper_minecart`** (5 slots).
- Demo pattern `if score matches N run data modify ... guikit:w set value`: if the score matches no
  range, `guikit:w` still holds the previous widget's data and that widget is drawn again. Initialize
  scores before drawing (the demo does) or add an `else` line.
- `name` / `lore` enter the macro as **raw SNBT strings**. If you write `name:'...'` in the definition
  line and the text contains `'`, the **definition line** becomes invalid (verified with mecha); escape it as
  `Bob\'s`. The expanded `item replace` command itself is fine with `'` in the text.
- `confirm` is simplified in the demo to a "click twice to confirm" flow instead of a separate page as in the source.
- The source's `condition` (item_count / score / tag / gamemode / advancement) has no helper; each is a
  one-line `execute if ...`, so write it by hand in the handler.
- The source's `link` widget is missing (`tellraw` + `click_event` open_url; one line, write it in the handler).
