# macro: $(menu)
# Player tag "guikit.m.<alias>" lets fill/probe routers dispatch per menu.
# Tags cannot contain ':' or '/', so menus register a tag-safe `alias`.
$data modify storage guikit:ctx alias set from storage guikit:reg menus."$(menu)".alias
function guikit:internal/set_alias_tag with storage guikit:ctx
