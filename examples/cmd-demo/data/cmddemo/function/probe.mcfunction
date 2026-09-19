# cmddemo :: probe   (via #guikit:probe, as player). One pair of lines per button.
execute unless entity @s[tag=guikit.m.cmddemo_main] run return 0
data merge storage guikit:p {id:"cmddemo:apple"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"cmddemo:coin"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"cmddemo:sword"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"cmddemo:vip"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"cmddemo:link"}
function guikit:widget/button_probe with storage guikit:p
data merge storage guikit:p {id:"cmddemo:close"}
function guikit:widget/button_probe with storage guikit:p
