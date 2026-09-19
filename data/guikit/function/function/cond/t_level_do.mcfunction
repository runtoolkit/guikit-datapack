# macro: $(min) $(max)
# `experience query` returns the level count; store it in a temp score, then compare with two
# open-ended ranges (never a closed A..B).
execute store result score #lvl guikit.tmp run experience query @s levels
scoreboard players set #cond guikit.tmp 1
$execute unless score #lvl guikit.tmp matches $(min).. run scoreboard players set #cond guikit.tmp 0
$execute unless score #lvl guikit.tmp matches ..$(max) run scoreboard players set #cond guikit.tmp 0
