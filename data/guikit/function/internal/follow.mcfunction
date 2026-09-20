# guikit :: follow     as cart (owned by the ticking player)
# Position context: tick_player runs `at @s` (the player). `execute as <cart>` does NOT
# change the position, so `tp @s ~ ~ ~` moves the cart exactly onto its owner.
scoreboard players set #found guikit.tmp 1
# Minecarts follow their owner. Boats/rafts are NOT teleported: the owner rides them (see README
# "Container types", `ride @s mount ...`), teleporting a boat with its rider in every tick fights the ride.
tp @s[type=minecraft:chest_minecart] ~ ~1 ~
tp @s[type=minecraft:hopper_minecart] ~ ~1 ~
