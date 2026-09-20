# macro: $(obj) $(max) $(width)
# filled = score * width / max   (integer division, floor), clamped to [0,width]
$scoreboard players operation #f guikit.tmp = @s $(obj)
$scoreboard players set #w guikit.tmp $(width)
$scoreboard players set #m guikit.tmp $(max)
scoreboard players operation #f guikit.tmp *= #w guikit.tmp
scoreboard players operation #f guikit.tmp /= #m guikit.tmp
execute if score #f guikit.tmp matches ..-1 run scoreboard players set #f guikit.tmp 0
scoreboard players operation #f2 guikit.tmp = #f guikit.tmp
scoreboard players operation #f2 guikit.tmp -= #w guikit.tmp
execute if score #f2 guikit.tmp matches 1.. run scoreboard players operation #f guikit.tmp = #w guikit.tmp
scoreboard players set #i guikit.tmp 0
scoreboard players operation #left guikit.tmp = #w guikit.tmp
