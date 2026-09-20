# demo :: main/probe   (via demo:probe, as player). ONE line per clickable widget id;
# ONE pair per button (widget/button_probe); ONE line per meter (widget/meter_probe, not per cell).
data merge storage guikit:p {id:"buy_gem", fn:"demo:click/buy_gem"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"sound", fn:"demo:click/sound"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"volume_up", fn:"demo:click/volume_up"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"mode", fn:"demo:click/mode"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"prog_up", fn:"demo:click/prog_up"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"to_page1", fn:"demo:click/to_page1"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"to_page0", fn:"demo:click/to_page0"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"close", fn:"demo:click/close"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"lootbox", fn:"demo:click/lootbox"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"danger", fn:"demo:click/danger"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"to_page2", fn:"demo:click/to_page2"}
function guikit:widget/probe with storage guikit:p

# --- page 2: command buttons (former cmd-demo)
data merge storage guikit:p {id:"demo:apple"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"demo:coin"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"demo:sword"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"demo:vip"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"demo:link"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"demo:lvl"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"demo:combo"}
function guikit:widget/button_probe with storage guikit:p

# --- page 2: radio (difficulty, 3 options -- direct-assign, unlike cycle's auto-increment)
data merge storage guikit:p {id:"diff_easy", fn:"demo:click/diff_easy"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"diff_normal", fn:"demo:click/diff_normal"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"diff_hard", fn:"demo:click/diff_hard"}
function guikit:widget/probe with storage guikit:p

# --- page 2: meter (rating, 5 clickable cells, ONE registration)
data merge storage guikit:p {id:"demo:rating"}
function guikit:widget/meter_probe with storage guikit:p

# --- page 2: open a themed sub-menu
data merge storage guikit:p {id:"open_ender_chest", fn:"demo:click/open_ender_chest"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"open_barrel", fn:"demo:click/open_barrel"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"open_hopper", fn:"demo:click/open_hopper"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"open_shop", fn:"demo:click/open_shop"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"open_chest_boat", fn:"demo:click/open_chest_boat"}
function guikit:widget/probe with storage guikit:p
