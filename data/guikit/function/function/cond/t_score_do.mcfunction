# macro: $(obj) $(min) $(max)
# Two open-ended ranges instead of one closed A..B range (see README "Validation status").
scoreboard players set #cond guikit.tmp 1
$execute unless score @s $(obj) matches $(min).. run scoreboard players set #cond guikit.tmp 0
$execute unless score @s $(obj) matches ..$(max) run scoreboard players set #cond guikit.tmp 0
