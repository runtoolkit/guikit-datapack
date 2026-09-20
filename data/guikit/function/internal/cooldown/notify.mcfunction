# guikit :: internal/cd_notify     as player
# Tells the player how long the cooldown still runs. Call it when widget/cooldown_start
# returned 0 (before this, a refused click gave the player no feedback at all).
#
#   execute unless function guikit:widget/cooldown_start run function guikit:internal/cooldown/notify
#
# Do NOT call cooldown_start first and then test `guikit.cd matches 1..`: on success it has just
# SET the cooldown, so that test is true then too and the player would be told to wait after a
# click that worked. `unless function` only runs cd_notify when cooldown_start returned 0.
#
# guikit.cd counts ticks; 20 ticks = 1 second. Shown rounded UP so the player never sees "0s"
# while a cooldown is still running.
scoreboard players operation #cdleft guikit.tmp = @s guikit.cd
scoreboard players add #cdleft guikit.tmp 19
scoreboard players set #cd20 guikit.tmp 20
scoreboard players operation #cdleft guikit.tmp /= #cd20 guikit.tmp
tellraw @s [{"text":"[GUI] ","color":"gray"},{"text":"Wait ","color":"red","italic":false},{"score":{"name":"#cdleft","objective":"guikit.tmp"},"color":"red","italic":false},{"text":"s.","color":"red","italic":false}]
