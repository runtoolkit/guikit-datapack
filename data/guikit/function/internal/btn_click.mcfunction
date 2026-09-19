# macro: $(id)     as player, at player      (called by widget/button_probe)
# Definition keys (storage guikit:btn defs."<id>"):
#   cmd:"..."        command run `as @s at @s`. Use `function ns:name` for several commands.
#   url:"https://.." prints a clickable link in chat instead (use close:1b so the player can see chat)
#   cond:{...}       any guikit:cond type, see cond/check. Fails -> `deny` message, nothing runs
#   deny:"..."       message when cond fails (no double quotes). Default "Not available."
#   close:1b         close the menu after the command
#   timer:N          reset the menu timeout to N ticks on a successful click
#   locked_item:"minecraft:barrier"   look when cond fails (widget/button)
data remove storage guikit:btn cur
$data modify storage guikit:btn cur set from storage guikit:btn defs."$(id)"
execute unless data storage guikit:btn cur run return 0

function guikit:internal/btn_cond
execute if score #cond guikit.tmp matches 0 run return run function guikit:internal/btn_deny

# decide now: the command may overwrite guikit:btn cur (e.g. by running another button)
execute store success score #btn_close guikit.tmp if data storage guikit:btn cur{close:1b}
execute if data storage guikit:btn cur.timer run function guikit:internal/btn_timer with storage guikit:btn cur
execute if data storage guikit:btn cur.cmd run function guikit:internal/btn_cmd with storage guikit:btn cur
execute if data storage guikit:btn cur.url run function guikit:internal/btn_url with storage guikit:btn cur
execute if score #btn_close guikit.tmp matches 1 if score @s guikit.uid matches 1.. run function guikit:api/close
