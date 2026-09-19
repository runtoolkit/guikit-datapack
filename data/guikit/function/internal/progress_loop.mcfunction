# recursive: one cell per iteration
execute if score #left guikit.tmp matches ..0 run return 0
# choose item for this cell: full if #i < #f
scoreboard players operation #d guikit.tmp = #f guikit.tmp
scoreboard players operation #d guikit.tmp -= #i guikit.tmp
data modify storage guikit:pg item set from storage guikit:pg empty
execute if score #d guikit.tmp matches 1.. run data modify storage guikit:pg item set from storage guikit:pg full
# slot = base + i
execute store result storage guikit:pg cell int 1 run scoreboard players get #i guikit.tmp
function guikit:internal/progress_slot with storage guikit:pg
scoreboard players add #i guikit.tmp 1
scoreboard players remove #left guikit.tmp 1
function guikit:internal/progress_loop
