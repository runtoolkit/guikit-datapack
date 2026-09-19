# macro: $(item) $(min)
# `clear ... 0` only counts. The clicked GUI widget sits in the player's inventory while a handler
# runs, so widget items of the same type are subtracted (otherwise a diamond button would count as
# one diamond owned).
$execute store result score #have guikit.tmp run clear @s $(item) 0
$execute store result score #gui guikit.tmp run clear @s $(item)[custom_data~{guikit:{w:1b}}] 0
scoreboard players operation #have guikit.tmp -= #gui guikit.tmp
$execute if score #have guikit.tmp matches $(min).. run scoreboard players set #cond guikit.tmp 1
