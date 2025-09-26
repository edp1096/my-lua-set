$downloadURL = "https://www.angusj.com/resourcehacker/resource_hacker.zip"

# write-output $release.name
# write-output $downloadURL

import-module bitstransfer
new-item -force -ea 0 -itemtype directory -path resource_hacker | out-null
start-bitstransfer -destination resource_hacker.zip -source $downloadURL
tar -xf resource_hacker.zip -C resource_hacker
remove-item -force resource_hacker.zip