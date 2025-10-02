$iupDownloadURL = "https://github.com/edp1096/iup/releases/latest/download/iup-windows-amd64.tar.gz"

# write-output $iupDownloadURL

import-module bitstransfer
start-bitstransfer -destination iup.tar.gz -source $iupDownloadURL

if (Test-Path -Path "iup" -PathType Container) {
    remove-item -force -ea 0 -recurse iup
}

tar -xzf iup.tar.gz -C .

rename-item dist iup
remove-item -force iup.tar.gz
