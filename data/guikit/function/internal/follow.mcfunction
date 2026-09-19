# guikit :: follow     as cart (owned by the ticking player)
# Position context: tick_player runs `at @s` (the player). `execute as <cart>` does NOT
# change the position, so `tp @s ~ ~ ~` moves the cart exactly onto its owner.
scoreboard players set #found guikit.tmp 1
tp @s[type=minecraft:chest_minecart] ~ ~1 ~
