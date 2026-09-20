# guikit :: internal/pad/step     as cart     #pi = slots still to fill; storage guikit:ctx pad
# Fills slot #pi-1, then recurses until slot 0 is done.
scoreboard players remove #pi guikit.tmp 1
execute store result storage guikit:ctx i int 1 run scoreboard players get #pi guikit.tmp
function guikit:internal/pad/slot with storage guikit:ctx
execute if score #pi guikit.tmp matches 1.. run function guikit:internal/pad/step
