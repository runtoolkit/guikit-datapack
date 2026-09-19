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

Full working example: the separate **`guikit-demo`** datapack (2 pages; button, toggle, counter, cycle, progress, nav, close,
random, confirm, cost, cooldown). It adds its entries to the four `#guikit:*` tags above from its own pack, so this core
pack contains no menus and its tags are empty. Install both, then `/function demo:open`.

> The four tag files here (`register`, `fill`, `probe`, `clear_tags`) must stay `{"values": []}` **without `replace: true`**,
> otherwise menu packs can no longer add themselves. They must exist even when empty: `function #guikit:fill` on a
> missing tag is an error.

## Widget helpers (`guikit:widget/*`)
`draw` `pad` `probe` `toggle` `counter` `cycle` `progress` `roll` `goto_page` `cooldown_start` `pay_item` `pay_score` `say`

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
- **Still not done:** behavior in a real game (`clear` + `custom_data` match, `summon`, tick ordering,
  multiplayer). Only the load step has been observed.

## Known limits
- `guikit:widget/pad` always stamps 27 slots -> **do not use with `hopper_minecart`** (5 slots).
- If a menu draws a widget under `execute if score ... matches N run function guikit:internal/clear_w` + `... run data merge`
  and no range matches, `guikit:w` is empty and `guikit:widget/draw` fails on missing macro arguments instead of
  redrawing the previous widget. Initialize scores before drawing.
- `name` / `lore` enter the macro as **raw SNBT strings**. If you write `name:'...'` in the definition
  line and the text contains `'`, the **definition line** becomes invalid (verified with mecha); escape it as
  `Bob\'s`. The expanded `item replace` command itself is fine with `'` in the text.
- `confirm` is simplified (in `guikit-demo`) to a "click twice to confirm" flow instead of a separate page as in the source.
- The source's `condition` (item_count / score / tag / gamemode / advancement) has no helper; each is a
  one-line `execute if ...`, so write it by hand in the handler.
- The source's `link` widget is missing (`tellraw` + `click_event` open_url; one line, write it in the handler).
