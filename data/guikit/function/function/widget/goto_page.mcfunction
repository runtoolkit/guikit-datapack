# guikit :: widget/goto_page   as player   storage guikit:in {page:N}
execute store result score @s guikit.page run data get storage guikit:in page
scoreboard players set @s guikit.dirty 1
