# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200
# button + cost + cooldown
data modify storage guikit:in {} set value {ticks:20}
execute unless function guikit:widget/cooldown_start run return run function demo:internal/say_wait
data modify storage guikit:in {} set value {item:"minecraft:emerald", count:3}
execute unless function guikit:widget/pay_item run return run function demo:internal/say_poor
give @s minecraft:diamond 1
data modify storage guikit:in {} set value {msg:"Bought a gem!", color:"green"}
function guikit:widget/say
