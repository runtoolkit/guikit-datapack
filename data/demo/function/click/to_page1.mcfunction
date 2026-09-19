# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200
data modify storage guikit:in {} set value {page:1}
function guikit:widget/goto_page
