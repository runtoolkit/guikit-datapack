# demo :: register     (called through #guikit:register on every load)
# A menu = { alias (tag-safe), container }.  Everything else is code, not config.
# The main demo (chest_minecart) plus one small menu per container flavour, to actually show them
# summoned: ender chest / barrel presets, a 5-slot hopper, and a container registered right here.
data modify storage guikit:reg menus."demo:main" set value {alias:"demo_main", container:"chest_minecart"}
data modify storage guikit:reg menus."demo:ender_chest_demo" set value {alias:"demo_ender_chest", container:"ender_chest"}
data modify storage guikit:reg menus."demo:barrel_demo" set value {alias:"demo_barrel", container:"barrel"}
# oak_chest_boat: added alongside the existing ender_chest/barrel themed sub-menus, same pattern
data modify storage guikit:reg menus."demo:chest_boat_demo" set value {alias:"demo_chest_boat", container:"oak_chest_boat"}
# a container defined by this pack (see README "Container types"): built-ins are registered first, so this is additive
data modify storage guikit:reg containers.demo_shop set value {entity:"chest_minecart", slots:27, pad:"minecraft:cyan_stained_glass_pane", title:{text:"Demo Shop"}}
data modify storage guikit:reg menus."demo:shop_demo" set value {alias:"demo_shop", container:"demo_shop"}
# built-in 5-slot container
data modify storage guikit:reg menus."demo:hopper_demo" set value {alias:"demo_hopper", container:"hopper_minecart"}

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
# XP level condition (cond type "level", see README "Conditions")
data modify storage guikit:btn defs."demo:lvl" set value {cmd:'tellraw @s {"text":"Level 5 reached!","color":"green"}', timer:1200, deny:"You need XP level 5.", cond:{type:"level", min:5}, locked_item:"minecraft:iron_bars"}
# link
data modify storage guikit:btn defs."demo:link" set value {url:"https://github.com/runtoolkit/guikit-datapack", close:1b}

# --- meter definition (see README "Widget: clickable meter / rating bar")
data modify storage guikit:mtr defs."demo:rating" set value {obj:"demo.rating", width:5, max:5, full:"minecraft:lime_dye", empty:"minecraft:gray_dye", name:{text:" "}}
