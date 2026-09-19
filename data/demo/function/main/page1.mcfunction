# demo :: page 1
data modify storage guikit:w {} set value {slot:11, item:"minecraft:ender_chest", id:"lootbox", type:"random", name:'{"text":"Loot box","color":"light_purple","italic":false}', lore:'[{"text":"70% dirt, 25% iron, 5% diamond","color":"gray","italic":false}]'}
function guikit:widget/draw
data modify storage guikit:w {} set value {slot:15, item:"minecraft:tnt", id:"danger", type:"confirm", name:'{"text":"Danger zone","color":"dark_red","italic":false}', lore:'[]'}
function guikit:widget/draw
data modify storage guikit:w {} set value {slot:18, item:"minecraft:arrow", id:"to_page0", type:"nav", name:'{"text":"Back","color":"white","italic":false}', lore:'[]'}
function guikit:widget/draw
data modify storage guikit:w {} set value {slot:26, item:"minecraft:barrier", id:"close", type:"close", name:'{"text":"Close","color":"red","italic":false}', lore:'[]'}
function guikit:widget/draw
