# demo :: theme/hopper_fill   as player   (menu demo:hopper_demo, container:"hopper_minecart")
# Built-in 5-slot container: slots 0..4 only (@s guikit.slots = 5). widget/pad fills exactly those.
function guikit:widget/pad

function guikit:internal/clear_w
data merge storage guikit:w {slot:2, item:"minecraft:hopper", id:"label", type:"info", name:{text:"5-slot hopper",color:"gray",italic:false}, lore:[{text:"slots 0-4 only",color:"gray",italic:false}]}
function guikit:widget/draw

function guikit:internal/clear_w
data merge storage guikit:w {slot:0, item:"minecraft:arrow", id:"back", type:"nav", name:{text:"Back",color:"white",italic:false}, lore:[]}
function guikit:widget/draw

function guikit:internal/clear_w
data merge storage guikit:w {slot:4, item:"minecraft:barrier", id:"close", type:"close", name:{text:"Close",color:"red",italic:false}, lore:[]}
function guikit:widget/draw
