# guikit :: internal/safe_clear     as player
# Removes ONLY widget items (custom_data guikit.w:1b). Never a wildcard-only clear.
#
# Count first (`clear ... 0` only counts), and only delete when the count is >= 1.
# If nothing carries the widget marker this is a no-op, so an idle tick can never wipe an inventory.
scoreboard players set #wcount guikit.tmp 0
execute store result score #wcount guikit.tmp run clear @s *[custom_data~{guikit:{w:1b}}] 0
execute if score #wcount guikit.tmp matches 1.. run clear @s *[custom_data~{guikit:{w:1b}}]
