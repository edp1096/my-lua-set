$uri = "https://nodejs.org/download/release/index.json"
$json = Invoke-WebRequest -UseBasicParsing -Uri $uri | ConvertFrom-Json

$nodejsVersion = ""
for ($i = 0; $i -lt $json.Length; $i++) {
    if ($json[$i].lts -ne $False) {
        $nodejsVersion = $json[$i].version
        break
    }
}

remove-item -r -force -ea 0 nodejs
#new-item -itemtype directory -path nodejs | out-null

import-module bitstransfer
start-bitstransfer -destination nodejs.zip -source https://nodejs.org/dist/$nodejsVersion/node-$nodejsVersion-win-x64.zip
tar -xf nodejs.zip
remove-item -force nodejs.zip
rename-item node-$nodejsVersion-win-x64 nodejs
