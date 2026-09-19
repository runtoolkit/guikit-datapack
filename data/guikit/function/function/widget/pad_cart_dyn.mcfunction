# guikit :: widget/pad_cart_dyn     as cart (guikit.styled)
# Pad item and slot count come from the definition kept by owner uid (internal/cont_bind).
execute store result storage guikit:ctx uid int 1 run scoreboard players get @s guikit.uid
data remove storage guikit:ctx pad
function guikit:internal/pad_load with storage guikit:ctx
execute unless data storage guikit:ctx pad run return 0
scoreboard players operation #pi guikit.tmp = @s guikit.slots
function guikit:internal/pad_step
data remove storage guikit:ctx pad
data remove storage guikit:ctx uid
data remove storage guikit:ctx i
