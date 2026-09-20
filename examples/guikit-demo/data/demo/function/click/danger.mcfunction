# arm/confirm using a per-player tag
execute unless entity @s[tag=demo.armed] run return run function demo:internal/arm
tag @s remove demo.armed
function guikit:internal/clear/in
data merge storage guikit:in {msg:"Boom!", color:"dark_red"}
function guikit:widget/say
effect give @s minecraft:blindness 3 0 true
