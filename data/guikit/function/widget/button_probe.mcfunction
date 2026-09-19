# macro: $(id)     as player   storage guikit:p {id:"ns:id"}
# ONE pair of lines per button in your #guikit:probe listener:
#   data merge storage guikit:p {id:"demo:ok"}
#   function guikit:widget/button_probe with storage guikit:p
# Same presence test as widget/probe, then runs the definition registered under that id.
$execute store result score #hit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"$(id)"}}] 0
$execute if score #hit guikit.tmp matches 1.. run function guikit:internal/btn_click {id:"$(id)"}
