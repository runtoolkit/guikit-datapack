# macro: $(mode)
$execute if entity @s[gamemode=$(mode)] run scoreboard players set #cond guikit.tmp 1
