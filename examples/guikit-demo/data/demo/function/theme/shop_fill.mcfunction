# demo :: theme/shop_fill   as player   (menu demo:shop_demo, container:"demo_shop")
# The container is registered by demo:register itself: cyan pad + "Demo Shop" title.
function guikit:widget/pad

function guikit:internal/clear_w
data merge storage guikit:w {slot:13, item:"minecraft:gold_ingot", id:"label", type:"info", name:{text:"Registered container",color:"aqua",italic:false}, lore:[{text:"defined in demo:register, not in guikit",color:"gray",italic:false}]}
function guikit:widget/draw

function guikit:internal/clear_w
data merge storage guikit:w {slot:22, item:"minecraft:arrow", id:"back", type:"nav", name:{text:"Back",color:"white",italic:false}, lore:[]}
function guikit:widget/draw

function guikit:internal/clear_w
data merge storage guikit:w {slot:26, item:"minecraft:barrier", id:"close", type:"close", name:{text:"Close",color:"red",italic:false}, lore:[]}
function guikit:widget/draw
