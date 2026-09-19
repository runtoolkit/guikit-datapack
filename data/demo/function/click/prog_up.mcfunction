# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200
data modify storage guikit:in {} set value {obj:"demo.progress", delta:2, min:0, max:10, wrap:1b}
function guikit:widget/counter
