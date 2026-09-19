# demo :: register     (called through #guikit:register on every load)
# A menu = { alias (tag-safe), container }.  Everything else is code, not config.
data modify storage guikit:reg menus."demo:main" set value {alias:"demo_main", container:"chest_minecart"}

scoreboard objectives add demo.sound_on dummy
scoreboard objectives add demo.volume dummy
scoreboard objectives add demo.mode dummy
scoreboard objectives add demo.coins dummy
scoreboard objectives add demo.progress dummy
