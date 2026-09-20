# guikit :: internal/pad/dispose_cart   as cart - empty first so kill does not drop GUI items
# Only clears the cart's own slot count (guikit.slots, set at summon time): a hard-coded
# container.0..26 here would run item replace on slots past a hopper_minecart's real 5
# (or any future non-27-slot container), which fails per slot and littered the log without
# actually stopping the kill that follows.
scoreboard players operation #ds guikit.tmp = @s guikit.slots
execute unless score #ds guikit.tmp matches 1.. run scoreboard players set #ds guikit.tmp 27
function guikit:internal/pad/dispose_slot
kill @s
