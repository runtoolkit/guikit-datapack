# macro: $(adv)
$execute if entity @s[advancements={$(adv)=true}] run scoreboard players set #cond guikit.tmp 1
