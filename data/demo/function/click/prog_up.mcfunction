# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200
function guikit:internal/clear_in
data merge storage guikit:in {obj:"demo.progress", delta:2, min:0, max:10, wrap:1b}
function guikit:widget/counter
