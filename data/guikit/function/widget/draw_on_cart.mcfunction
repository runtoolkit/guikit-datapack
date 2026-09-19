# macro: $(slot) $(item) $(id) $(type) $(name) $(lore)   as cart
# name / lore are SNBT text components: name:{text:"Buy",italic:false}  lore:[{text:"..",color:"gray",italic:false}]  lore:[]
$execute store success score #draw_ok guikit.tmp run item replace entity @s container.$(slot) with $(item)[custom_name=$(name),lore=$(lore),max_stack_size=1,custom_data={guikit:{w:1b,type:"$(type)",id:"$(id)"}}]
execute if score #draw_ok guikit.tmp matches 0 run function guikit:internal/draw_fail with storage guikit:w
