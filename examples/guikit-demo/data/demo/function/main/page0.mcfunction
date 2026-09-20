# demo :: page 0
# --- button (slot 10)
function guikit:internal/clear/w
data merge storage guikit:w {slot:10, item:"minecraft:diamond", id:"buy_gem", type:"button", name:'{"text":"Buy Gem","color":"aqua","italic":false}', lore:'[{"text":"Costs 3 emeralds","color":"gray","italic":false}]'}
function guikit:widget/draw

# --- toggle (slot 12): item + name depend on state
execute unless score @s demo.sound_on matches 0.. run scoreboard players set @s demo.sound_on 0
execute if score @s demo.sound_on matches 0 run function guikit:internal/clear/w
execute if score @s demo.sound_on matches 0 run data merge storage guikit:w {slot:12, item:"minecraft:lever", id:"sound", type:"toggle", name:'{"text":"Sound: OFF","color":"red","italic":false}', lore:'[]'}
execute if score @s demo.sound_on matches 1 run function guikit:internal/clear/w
execute if score @s demo.sound_on matches 1 run data merge storage guikit:w {slot:12, item:"minecraft:lime_dye", id:"sound", type:"toggle", name:'{"text":"Sound: ON","color":"green","italic":false}', lore:'[]'}
function guikit:widget/draw

# --- counter (slot 14): volume 0..10
execute unless score @s demo.volume matches 0.. run scoreboard players set @s demo.volume 5
function guikit:internal/clear/w
data merge storage guikit:w {slot:14, item:"minecraft:note_block", id:"volume_up", type:"counter", name:'{"text":"Volume +1","color":"yellow","italic":false}', lore:'[{"text":"Click to raise (wraps at 10)","color":"gray","italic":false}]'}
function guikit:widget/draw

# --- cycle (slot 16): mode 0..2
execute unless score @s demo.mode matches 0.. run scoreboard players set @s demo.mode 0
execute if score @s demo.mode matches 0 run function guikit:internal/clear/w
execute if score @s demo.mode matches 0 run data merge storage guikit:w {slot:16, item:"minecraft:wooden_sword", id:"mode", type:"cycle", name:'{"text":"Mode: Easy","color":"green","italic":false}', lore:'[]'}
execute if score @s demo.mode matches 1 run function guikit:internal/clear/w
execute if score @s demo.mode matches 1 run data merge storage guikit:w {slot:16, item:"minecraft:iron_sword", id:"mode", type:"cycle", name:'{"text":"Mode: Normal","color":"yellow","italic":false}', lore:'[]'}
execute if score @s demo.mode matches 2 run function guikit:internal/clear/w
execute if score @s demo.mode matches 2 run data merge storage guikit:w {slot:16, item:"minecraft:netherite_sword", id:"mode", type:"cycle", name:'{"text":"Mode: Hard","color":"red","italic":false}', lore:'[]'}
function guikit:widget/draw

# --- progress bar (slots 19..23) driven by demo.progress 0..10
execute unless score @s demo.progress matches 0.. run scoreboard players set @s demo.progress 0
function guikit:internal/clear/w
data merge storage guikit:w {obj:"demo.progress", slot:19, width:5, max:10, full:"minecraft:lime_stained_glass_pane", empty:"minecraft:gray_stained_glass_pane", id:"bar", name:'{"text":" "}'}
function guikit:widget/progress

# --- progress +2 button (slot 25)
function guikit:internal/clear/w
data merge storage guikit:w {slot:25, item:"minecraft:experience_bottle", id:"prog_up", type:"button", name:'{"text":"Progress +2","color":"green","italic":false}', lore:'[]'}
function guikit:widget/draw

# --- nav -> page 1 (slot 26) and close (slot 22 is reserved by bar? no: bar is 19..23) -> put close at 18
function guikit:internal/clear/w
data merge storage guikit:w {slot:26, item:"minecraft:arrow", id:"to_page1", type:"nav", name:'{"text":"Next page","color":"white","italic":false}', lore:'[]'}
function guikit:widget/draw
function guikit:internal/clear/w
data merge storage guikit:w {slot:18, item:"minecraft:barrier", id:"close", type:"close", name:'{"text":"Close","color":"red","italic":false}', lore:'[]'}
function guikit:widget/draw
