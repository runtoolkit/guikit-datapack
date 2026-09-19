# guikit :: api/refresh      as <player>
# Redraws this player's open menu from outside guikit (another datapack, a scoreboard trigger,
# a timer...) without closing/reopening it. Before this, the only way was writing
# `guikit.dirty` by hand.
#
#   execute as <player> run function guikit:api/refresh
#
# Result: 1 = redraw scheduled, 0 = this player has no open menu (nothing touched).
#
# The redraw happens on the player's next tick_player run (dirty is picked up there), so a
# handler may call this several times in one tick and the menu is still drawn only once.
execute unless score @s guikit.uid matches 1.. run return 0
scoreboard players set @s guikit.dirty 1
return 1
