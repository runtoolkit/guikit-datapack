# guikit :: internal/meter_loop   (recursive -- like internal/progress_loop, but draws
# clickable "meter" cells instead of static "progress" ones). Reads score #f/#i/#left guikit.tmp
# set by internal/progress_calc, and storage guikit:pg set by widget/meter_draw.
execute if score #left guikit.tmp matches ..0 run return 0
scoreboard players operation #d guikit.tmp = #f guikit.tmp
scoreboard players operation #d guikit.tmp -= #i guikit.tmp
data modify storage guikit:pg item set from storage guikit:pg empty
execute if score #d guikit.tmp matches 1.. run data modify storage guikit:pg item set from storage guikit:pg full
execute store result storage guikit:pg cell int 1 run scoreboard players get #i guikit.tmp
function guikit:internal/meter_slot with storage guikit:pg
scoreboard players add #i guikit.tmp 1
scoreboard players remove #left guikit.tmp 1
function guikit:internal/meter_loop
