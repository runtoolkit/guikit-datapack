# demo :: page 2 -- command buttons (former cmd-demo), radio, meter, links to themed containers

# --- command buttons (slots 10..14), defs registered in demo:register
function guikit:internal/clear/w
data merge storage guikit:w {slot:10, item:"minecraft:apple", id:"demo:apple", name:{text:"Free apple",color:"green",italic:false}, lore:[]}
function guikit:widget/button
function guikit:internal/clear/w
data merge storage guikit:w {slot:11, item:"minecraft:gold_nugget", id:"demo:coin", name:{text:"+1 coin",color:"yellow",italic:false}, lore:[]}
function guikit:widget/button
function guikit:internal/clear/w
data merge storage guikit:w {slot:22, item:"minecraft:diamond", id:"demo:combo", name:{text:"Diamond (VIP)",color:"aqua",italic:false}, lore:[{text:"Needs tag vip AND XP level 1, costs 3 coins",color:"gray",italic:false}]}
function guikit:widget/button

function guikit:internal/clear/w
data merge storage guikit:w {slot:12, item:"minecraft:iron_sword", id:"demo:sword", name:{text:"Buy sword",color:"aqua",italic:false}, lore:[{text:"Costs 5 coins (score demo.coins)",color:"gray",italic:false}]}
function guikit:widget/button
function guikit:internal/clear/w
data merge storage guikit:w {slot:13, item:"minecraft:nether_star", id:"demo:vip", name:{text:"VIP only",color:"gold",italic:false}, lore:[{text:"Needs tag vip",color:"gray",italic:false}]}
function guikit:widget/button
function guikit:internal/clear/w
data merge storage guikit:w {slot:14, item:"minecraft:writable_book", id:"demo:link", name:{text:"Open repo link",color:"white",italic:false}, lore:[]}
function guikit:widget/button

# level-gated button (slot 15): cond type "level", needs XP level 5
function guikit:internal/clear/w
data merge storage guikit:w {slot:15, item:"minecraft:experience_bottle", id:"demo:lvl", name:{text:"Level 5 only",color:"green",italic:false}, lore:[{text:"Needs XP level 5",color:"gray",italic:false}]}
function guikit:widget/button

# --- radio (slots 19,20,21): difficulty, direct-assign, unlike cycle's auto-increment on page 0
execute unless score @s demo.difficulty matches 0.. run scoreboard players set @s demo.difficulty 0
function guikit:internal/clear/w
data modify storage guikit:w item set value "minecraft:wooden_sword"
data modify storage guikit:w name set value '{"text":"Easy","italic":false}'
execute if score @s demo.difficulty matches 0 run data modify storage guikit:w item set value "minecraft:lime_dye"
execute if score @s demo.difficulty matches 0 run data modify storage guikit:w name set value '{"text":"[x] Easy","color":"green","italic":false}'
data merge storage guikit:w {slot:19, id:"diff_easy", type:"radio", lore:[]}
function guikit:widget/draw
function guikit:internal/clear/w
data modify storage guikit:w item set value "minecraft:iron_sword"
data modify storage guikit:w name set value '{"text":"Normal","italic":false}'
execute if score @s demo.difficulty matches 1 run data modify storage guikit:w item set value "minecraft:lime_dye"
execute if score @s demo.difficulty matches 1 run data modify storage guikit:w name set value '{"text":"[x] Normal","color":"yellow","italic":false}'
data merge storage guikit:w {slot:20, id:"diff_normal", type:"radio", lore:[]}
function guikit:widget/draw
function guikit:internal/clear/w
data modify storage guikit:w item set value "minecraft:netherite_sword"
data modify storage guikit:w name set value '{"text":"Hard","italic":false}'
execute if score @s demo.difficulty matches 2 run data modify storage guikit:w item set value "minecraft:lime_dye"
execute if score @s demo.difficulty matches 2 run data modify storage guikit:w name set value '{"text":"[x] Hard","color":"red","italic":false}'
data merge storage guikit:w {slot:21, id:"diff_hard", type:"radio", lore:[]}
function guikit:widget/draw

# --- meter (slots 4..8): rating 1..5, click a cell to jump straight to that value
execute unless score @s demo.rating matches 0.. run scoreboard players set @s demo.rating 3
function guikit:internal/clear/w
data merge storage guikit:w {slot:4, id:"demo:rating"}
function guikit:widget/meter_draw with storage guikit:w

# --- open a themed sub-menu (ender_chest / barrel, see README "Container types")
function guikit:internal/clear/w
data merge storage guikit:w {slot:24, item:"minecraft:ender_eye", id:"open_ender_chest", type:"nav", name:'{"text":"Open: Ender Chest theme","color":"light_purple","italic":false}', lore:'[]'}
function guikit:widget/draw
function guikit:internal/clear/w
data merge storage guikit:w {slot:25, item:"minecraft:barrel", id:"open_barrel", type:"nav", name:'{"text":"Open: Barrel theme","color":"gold","italic":false}', lore:'[]'}
function guikit:widget/draw

function guikit:internal/clear/w
data merge storage guikit:w {slot:16, item:"minecraft:hopper", id:"open_hopper", type:"nav", name:{text:"Open: 5-slot hopper",color:"gray",italic:false}, lore:[]}
function guikit:widget/draw
function guikit:internal/clear/w
data merge storage guikit:w {slot:17, item:"minecraft:gold_ingot", id:"open_shop", type:"nav", name:{text:"Open: registered container",color:"aqua",italic:false}, lore:[]}
function guikit:widget/draw
function guikit:internal/clear/w
data merge storage guikit:w {slot:9, item:"minecraft:oak_boat", id:"open_chest_boat", type:"nav", name:{text:"Open: Oak Chest Boat",color:"aqua",italic:false}, lore:[]}
function guikit:widget/draw

# --- nav back to page 1, close
function guikit:internal/clear/w
data merge storage guikit:w {slot:18, item:"minecraft:arrow", id:"to_page1", type:"nav", name:'{"text":"Back","color":"white","italic":false}', lore:'[]'}
function guikit:widget/draw
function guikit:internal/clear/w
data merge storage guikit:w {slot:26, item:"minecraft:barrier", id:"close", type:"close", name:'{"text":"Close","color":"red","italic":false}', lore:'[]'}
function guikit:widget/draw
