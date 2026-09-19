# demo :: register     (called through #guikit:register on every load)
# A menu = { alias (tag-safe), container }.  Everything else is code, not config.
# Three menus now: the main demo (unchanged mechanic, chest_minecart) plus one small menu per
# themed container preset, to actually show them summoned (see README "Container types").
data modify storage guikit:reg menus."demo:main" set value {alias:"demo_main", container:"chest_minecart"}
data modify storage guikit:reg menus."demo:ender_chest_demo" set value {alias:"demo_ender_chest", container:"ender_chest"}
data modify storage guikit:reg menus."demo:barrel_demo" set value {alias:"demo_barrel", container:"barrel"}

scoreboard objectives add demo.sound_on dummy
scoreboard objectives add demo.volume dummy
scoreboard objectives add demo.mode dummy
scoreboard objectives add demo.coins dummy
scoreboard objectives add demo.progress dummy
scoreboard objectives add demo.difficulty dummy
scoreboard objectives add demo.rating dummy

# --- button definitions (formerly the separate cmd-demo pack, now page 2 of demo:main).
# plain command
data modify storage guikit:btn defs."demo:apple" set value {cmd:"give @s minecraft:apple 1", timer:1200}
data modify storage guikit:btn defs."demo:coin" set value {cmd:"scoreboard players add @s demo.coins 1", timer:1200}
# score condition, several commands through a function
data modify storage guikit:btn defs."demo:sword" set value {cmd:"function demo:internal/buy_sword", timer:1200, deny:"You need 5 coins.", cond:{type:"score", obj:"demo.coins", min:5}}
# tag condition, JSON inside the command -> single-quoted SNBT string
data modify storage guikit:btn defs."demo:vip" set value {cmd:'tellraw @s {"text":"Welcome, VIP!","color":"gold"}', timer:1200, deny:"VIP only. Try: /tag @s add vip", cond:{type:"tag", tag:"vip"}, locked_item:"minecraft:iron_bars"}
# link
data modify storage guikit:btn defs."demo:link" set value {url:"https://github.com/runtoolkit/guikit-datapack", close:1b}

# --- meter definition (see README "Widget: clickable meter / rating bar")
data modify storage guikit:mtr defs."demo:rating" set value {obj:"demo.rating", width:5, max:5, full:"minecraft:lime_dye", empty:"minecraft:gray_dye", name:{text:" "}}
