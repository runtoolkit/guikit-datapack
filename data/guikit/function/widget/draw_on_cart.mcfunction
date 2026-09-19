# macro: $(slot) $(item) $(id) $(type) $(name) $(lore)   as cart
$item replace entity @s container.$(slot) with $(item)[custom_name=$(name),lore=$(lore),max_stack_size=1,custom_data={guikit:{w:1b,type:"$(type)",id:"$(id)"}}]
