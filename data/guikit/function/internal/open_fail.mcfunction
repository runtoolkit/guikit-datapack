# guikit :: internal/open_fail     as player, at player     (called by api/open)
# The summon produced no usable cart: unknown entity id, or an entity that is not in the
# entity type tag #guikit:container (then the cart could never be bound to its owner and would
# live forever). Remove it and roll the half-opened state back.
execute store result storage guikit:ctx uid int 1 run scoreboard players get @s guikit.uid
function guikit:internal/cont_unbind with storage guikit:ctx
kill @e[tag=guikit.new,distance=..1]
scoreboard players reset @s guikit.uid
scoreboard players reset @s guikit.slots
function guikit:internal/clear_tmp
tellraw @s [{"text":"[guikit] ","color":"gray"},{"text":"could not open the menu: its container entity was not created or is not in #guikit:container","color":"red"}]
scoreboard players set #ok guikit.const 0
return 0
