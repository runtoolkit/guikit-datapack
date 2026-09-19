# guikit :: internal/meter_probe_loop   (recursive)
# Reads storage guikit:mtr {id, obj, max} and score #mc/#mw guikit.tmp (current cell / width),
# set by widget/meter_probe. Stops as soon as a cell hits (internal/meter_hit sets #mhit).
execute if score #mc guikit.tmp >= #mw guikit.tmp run return 0
execute store result storage guikit:mtr c int 1 run scoreboard players get #mc guikit.tmp
function guikit:internal/meter_hit with storage guikit:mtr
execute if score #mhit guikit.tmp matches 1 run return 0
scoreboard players add #mc guikit.tmp 1
function guikit:internal/meter_probe_loop
