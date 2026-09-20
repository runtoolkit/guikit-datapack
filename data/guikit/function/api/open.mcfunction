# guikit :: api/open        as <player> at <player>
# Input  (storage guikit:in): {menu:"<ns>:<id>", page:0, timer:900}
# Result: #ok guikit.const = 1 opened, 0 failed
#
#   function guikit:internal/clear/in
#   data merge storage guikit:in {menu:"ns:id"}
#   function guikit:api/open

scoreboard players set #ok guikit.const 0

# validate BEFORE touching any state
function guikit:internal/open_check with storage guikit:in
execute unless score #ok guikit.const matches 1 run return 0

# close this player's previous menu
execute if score @s guikit.uid matches 1.. run function guikit:api/close

# defaults
execute unless data storage guikit:in page run data modify storage guikit:in page set value 0
execute unless data storage guikit:in timer run data modify storage guikit:in timer set value 900

# owner uid
scoreboard players operation @s guikit.uid = #next_uid guikit.const
scoreboard players add #next_uid guikit.const 1

# summon + bind cart to owner
function guikit:internal/summon/main with storage guikit:in
execute unless entity @e[type=#guikit:container,tag=guikit.new,distance=..1] run return run function guikit:internal/open_fail
scoreboard players operation @e[type=#guikit:container,tag=guikit.new,distance=..1,limit=1] guikit.uid = @s guikit.uid
tag @e[type=#guikit:container,tag=guikit.new,distance=..1] remove guikit.new

# state
# guikit.drop is the vanilla drop statistic: it also counts drops made while no menu was open, so start clean
scoreboard players set @s guikit.drop 0
execute store result score @s guikit.page run data get storage guikit:in page
execute store result score @s guikit.timer run data get storage guikit:in timer
# remembered for internal/reset_cd (advancement guikit:interact_cart)
scoreboard players operation @s guikit.tmax = @s guikit.timer
data modify storage guikit:ctx menu set from storage guikit:in menu
function guikit:internal/set_menu_tag with storage guikit:ctx

scoreboard players set @s guikit.dirty 1
function guikit:core/redraw

data remove storage guikit:in page
data remove storage guikit:in timer
data remove storage guikit:ctx menu
data remove storage guikit:ctx alias
scoreboard players set #ok guikit.const 1
return 1
