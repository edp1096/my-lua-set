$defoldDownloadURL = "https://github.com/defold/defold/releases/latest/download/Defold-x86_64-win32.zip"

import-module bitstransfer
new-item -force -ea 0 -itemtype directory -path defold | out-null
start-bitstransfer -destination defold.zip -source $defoldDownloadURL
tar -xf defold.zip -C .

remove-item -force defold.zip
