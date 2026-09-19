# demo :: theme/barrel_probe   (via demo:probe, as player)
data merge storage guikit:p {id:"back", fn:"demo:click/back_to_main"}
function guikit:widget/probe with storage guikit:p
data merge storage guikit:p {id:"close", fn:"demo:click/close"}
function guikit:widget/probe with storage guikit:p
