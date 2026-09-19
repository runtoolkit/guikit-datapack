# macro: $(obj) $(delta) $(min) $(max) $(wrap)
$execute unless score @s $(obj) matches -2147483648..2147483647 run scoreboard players set @s $(obj) $(min)
$scoreboard players add @s $(obj) $(delta)
# overshoot / undershoot are STRICT comparisons against max+1 / min-1 via operation on temps
$scoreboard players set #max guikit.tmp $(max)
$scoreboard players set #min guikit.tmp $(min)
$scoreboard players operation #over guikit.tmp = @s $(obj)
scoreboard players operation #over guikit.tmp -= #max guikit.tmp
scoreboard players operation #under guikit.tmp = #min guikit.tmp
$scoreboard players operation #under guikit.tmp -= @s $(obj)
# over > 0  -> value > max ; under > 0 -> value < min
$execute if score #over guikit.tmp matches 1.. run scoreboard players set @s $(obj) $(max)
$execute if score #under guikit.tmp matches 1.. run scoreboard players set @s $(obj) $(min)
# wrap: overshoot -> min, undershoot -> max
$execute if data storage guikit:in {wrap:1b} if score #over guikit.tmp matches 1.. run scoreboard players set @s $(obj) $(min)
$execute if data storage guikit:in {wrap:1b} if score #under guikit.tmp matches 1.. run scoreboard players set @s $(obj) $(max)
