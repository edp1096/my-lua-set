$workbenchDesktopMainCSS=".\vscode\resources\app\out\vs\workbench\workbench.desktop.main.css"
$appendContent="`
@font-face{ font-family: 'D2Coding ligature'; src: url('https://cdn.jsdelivr.net/gh/joungkyun/font-d2coding-ligature/D2Coding-ligature.eot?#iefix') format('embedded-opentype'),`
url('https://cdn.jsdelivr.net/gh/joungkyun/font-d2coding-ligature/D2Coding-ligature.woff2') format('woff2'),`
url('https://cdn.jsdelivr.net/gh/joungkyun/font-d2coding-ligature/D2Coding-ligature.woff') format('woff'),`
url('https://cdn.jsdelivr.net/gh/joungkyun/font-d2coding-ligature/D2Coding-ligature.ttf') format('truetype'); font-weight: normal; font-style: normal;`
}`
@import url('http://fonts.cdnfonts.com/css/cascadia-code');"

Add-Content -path $workbenchDesktopMainCSS -value $appendContent
