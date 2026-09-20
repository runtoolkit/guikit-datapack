# demo :: theme/chest_boat_fill   as player   (menu demo:chest_boat_demo, container:"oak_chest_boat")
# Same 27-slot Items[] layout as chest_minecart, offset 0 -- see guikit's
# data/guikit/tags/entity_type/container.json and containers_builtin.mcfunction.
function guikit:widget/pad

function guikit:internal/clear/w
data merge storage guikit:w {slot:13, item:"minecraft:oak_boat", id:"label", type:"info", name:{text:"Oak Chest Boat",color:"aqua",italic:false}, lore:[{text:"27 slots, a real oak_chest_boat entity",color:"gray",italic:false}]}
function guikit:widget/draw

function guikit:internal/clear/w
data merge storage guikit:w {slot:22, item:"minecraft:arrow", id:"back", type:"nav", name:{text:"Back",color:"white",italic:false}, lore:[]}
function guikit:widget/draw

function guikit:internal/clear/w
data merge storage guikit:w {slot:26, item:"minecraft:barrier", id:"close", type:"close", name:{text:"Close",color:"red",italic:false}, lore:[]}
function guikit:widget/draw
