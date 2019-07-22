$ArticlesToPublish = Get-Content .\posts\posts.json | ConvertFrom-Json

if(($ArticlesToPublish | Where-Object { $_.posts.action -eq "publish"}).posts.Count -eq 0 ) {
    throw "No articles to publish"
}

if(Test-Path -Path .\publish) { Remove-Item -Path .\publish -Recurse -Force }
New-Item -Name publish -ItemType Directory
New-Item -Path .\publish -Name "posts" -ItemType Directory

Copy-Item -Path ".\Format-Gists.ps1" -Destination ".\publish" -Force
Copy-Item -Path ".\Format-Articles.ps1" -Destination ".\publish" -Force
Copy-Item -Path ".\Format-Images.ps1" -Destination ".\publish" -Force
Copy-Item -Path ".\Publish-Article.ps1" -Destination ".\publish" -Force
Copy-Item -Path ".\PublishTo-Blog.ps1" -Destination ".\publish" -Force
Copy-Item -Path ".\fileTypes.json" -Destination ".\publish" -Force
Copy-Item -Path ".\blog.tests.ps1" -Destination ".\publish" -Force

$ArticlesToPublish | Where-Object { $_.posts.action -eq "publish"} | ConvertTo-Json -Depth 3 | Out-File .\publish\posts\posts.json

($ArticlesToPublish | Where-Object { $_.posts.action -eq "publish"}).posts.folder | ForEach-Object {
    Copy-Item -Path .\posts\$_ -Destination .\publish\posts -Recurse
}