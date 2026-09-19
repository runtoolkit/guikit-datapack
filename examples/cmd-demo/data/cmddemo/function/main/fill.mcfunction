# cmddemo :: main/fill     as player.  Pad first, then draw.
function guikit:widget/pad

function guikit:internal/clear_w
data merge storage guikit:w {slot:10, item:"minecraft:apple", id:"cmddemo:apple", name:'{"text":"Free apple","color":"green","italic":false}', lore:'[]'}
function guikit:widget/button

function guikit:internal/clear_w
data merge storage guikit:w {slot:12, item:"minecraft:gold_nugget", id:"cmddemo:coin", name:'{"text":"+1 coin","color":"yellow","italic":false}', lore:'[]'}
function guikit:widget/button

function guikit:internal/clear_w
data merge storage guikit:w {slot:14, item:"minecraft:iron_sword", id:"cmddemo:sword", name:'{"text":"Buy sword","color":"aqua","italic":false}', lore:'[{"text":"Costs 5 coins (score cmddemo.coins)","color":"gray","italic":false}]'}
function guikit:widget/button

function guikit:internal/clear_w
data merge storage guikit:w {slot:16, item:"minecraft:nether_star", id:"cmddemo:vip", name:'{"text":"VIP only","color":"gold","italic":false}', lore:'[{"text":"Needs tag vip","color":"gray","italic":false}]'}
function guikit:widget/button

function guikit:internal/clear_w
data merge storage guikit:w {slot:22, item:"minecraft:writable_book", id:"cmddemo:link", name:'{"text":"Open repo link","color":"white","italic":false}', lore:'[]'}
function guikit:widget/button

function guikit:internal/clear_w
data merge storage guikit:w {slot:26, item:"minecraft:barrier", id:"cmddemo:close", name:'{"text":"Close","color":"red","italic":false}', lore:'[]'}
function guikit:widget/button
