# cmddemo :: register     (called through #guikit:register on every load)
data modify storage guikit:reg menus."cmddemo:main" set value {alias:"cmddemo_main", container:"chest_minecart"}
scoreboard objectives add cmddemo.coins dummy

# --- button definitions: one entry per button id (see README "Command buttons")
# plain command
data modify storage guikit:btn defs."cmddemo:apple" set value {cmd:"give @s minecraft:apple 1", timer:1200}
data modify storage guikit:btn defs."cmddemo:coin" set value {cmd:"scoreboard players add @s cmddemo.coins 1", timer:1200}
# score condition, several commands through a function
data modify storage guikit:btn defs."cmddemo:sword" set value {cmd:"function cmddemo:buy", timer:1200, deny:"You need 5 coins.", cond:{type:"score", obj:"cmddemo.coins", min:5}}
# tag condition, JSON inside the command -> single-quoted SNBT string
data modify storage guikit:btn defs."cmddemo:vip" set value {cmd:'tellraw @s {"text":"Welcome, VIP!","color":"gold"}', timer:1200, deny:"VIP only. Try: /tag @s add vip", cond:{type:"tag", tag:"vip"}, locked_item:"minecraft:iron_bars"}
# link
data modify storage guikit:btn defs."cmddemo:link" set value {url:"https://github.com/runtoolkit/guikit-datapack", close:1b}
# close
data modify storage guikit:btn defs."cmddemo:close" set value {cmd:"function guikit:api/close"}
