# macro: $(obj) $(n) $(last)
$execute unless score @s $(obj) matches 0.. run scoreboard players set @s $(obj) 0
$scoreboard players add @s $(obj) 1
$execute if score @s $(obj) matches $(n).. if data storage guikit:in {wrap:1b} run scoreboard players set @s $(obj) 0
$execute if score @s $(obj) matches $(n).. unless data storage guikit:in {wrap:1b} run scoreboard players set @s $(obj) $(last)
