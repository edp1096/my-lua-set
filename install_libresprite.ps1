$librespriteDownloadURL = "https://github.com/LibreSprite/LibreSprite/releases/latest/download/libresprite-development-windows-x86_64.zip"

import-module bitstransfer
new-item -force -ea 0 -itemtype directory -path libresprite | out-null
start-bitstransfer -destination libresprite.zip -source $librespriteDownloadURL
tar -xf libresprite.zip -C .

remove-item -force libresprite.zip
