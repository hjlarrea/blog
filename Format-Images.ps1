[cmdletbinding()]
param(
    [parameter(Mandatory=$true)][string]$Path
)

$post = Get-Content -Path $Path
$postFolder = Split-Path $Path -Parent | Split-Path -Leaf

0..(($post.Length)-1) | ForEach-Object {
    if($post[$_] -match "^!\[") {
        $imageLink = $post[$_].split(".")
        $newImageLink = $imageLink[0] + "https://raw.githubusercontent.com/hjlarrea/blog/master/posts/" + $postFolder + $imageLink[1] + "." + $imageLink[2]
        $post[$_] = $newImageLink
    }
}

Set-Content -Path $Path -Value $post