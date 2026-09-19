# guikit :: internal/meter_hit
# macro: $(id) $(c) $(obj) $(max)     as player   (called by internal/meter_probe_loop)
# Non-destructive presence test for cell $(c) of meter $(id) (same trick as widget/probe). On a
# hit, sets $(obj) to the cell's scaled value using score #mw guikit.tmp (width, set by
# widget/meter_probe) and marks the menu dirty for redraw.
$execute store result score #mhit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"$(id)_$(c)"}}] 0
execute unless score #mhit guikit.tmp matches 1.. run return 0
$scoreboard players set #mval guikit.tmp $(c)
scoreboard players add #mval guikit.tmp 1
$scoreboard players set #mmax guikit.tmp $(max)
scoreboard players operation #mval guikit.tmp *= #mmax guikit.tmp
scoreboard players operation #mval guikit.tmp /= #mw guikit.tmp
$scoreboard players operation @s $(obj) = #mval guikit.tmp
scoreboard players set @s guikit.dirty 1
